/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import Foundation
import CoreBluetooth
import BluetoothHelper

@objc enum BluetoothDeviceID:Int {
    case arduino
    case phiro
}

public class BluetoothService:NSObject {
//    class var sharedInstance: BluetoothService {
//        struct Static {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: BluetoothService? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = BluetoothService()
//        }
//        return Static.instance!
//    }
//    class var swiftSharedInstance: BluetoothService {
//        struct Singleton {
//            static let instance = BluetoothService()
//        }
//        return Singleton.instance
//    }
    static let swiftSharedInstance = BluetoothService()

    
    // the sharedInstance class method can be reached from ObjC
    @objc public class func sharedInstance() -> BluetoothService {
        return BluetoothService.swiftSharedInstance
    }


    
    var digitalSemaphoreArray:[dispatch_semaphore_t] = []
    var analogSemaphoreArray:[dispatch_semaphore_t] = []
    
    var phiro:Phiro?
    var arduino:ArduinoDevice?
    var selectionManager:BluetoothDevicesTableViewController?
    var scenePresenter:ScenePresenterViewController?
    
    
    func setDigitalSemaphore(semaphore:dispatch_semaphore_t){
        digitalSemaphoreArray.append(semaphore)
    }
    
    func signalDigitalSemaphore(check:Bool){
        if(digitalSemaphoreArray.count > 0){
//            let sema = digitalSemaphoreArray[0]
            digitalSemaphoreArray.removeAtIndex(0)
        }
        if(check == true){
            if(digitalSemaphoreArray.count > 0){
                let sema = digitalSemaphoreArray[0]
                digitalSemaphoreArray.removeAtIndex(0)
                dispatch_semaphore_signal(sema)
                
            }
        }
        
    }
    
    func setAnalogSemaphore(semaphore:dispatch_semaphore_t){
        analogSemaphoreArray.append(semaphore)
    }
    
    @objc public func signalAnalogSemaphore(){
        if(analogSemaphoreArray.count > 0){
            let sema = analogSemaphoreArray[0]
            analogSemaphoreArray.removeAtIndex(0)
            dispatch_semaphore_signal(sema)
        }
        
    }
    
    func getSemaphore()->dispatch_semaphore_t {
        return dispatch_semaphore_create(0)
    }
    
    @objc public func getSensorPhiro() -> Phiro? {
        guard let senorPhiro = phiro else{
            return nil
        }
        return senorPhiro
    }
    
    @objc public func getSensorArduino() -> ArduinoDevice? {
        guard let senorArduino = arduino else{
            return nil
        }
        return senorArduino
    }
    
    @objc public func disconnect() {
        self.phiro?.disconnect()
        self.arduino?.disconnect()
        self.phiro = nil
        self.arduino = nil
    }
    
    
    
    //MARK: Bluetooth Connection
    
    func connectDevice(peri:Peripheral) {
        let future = peri.connect(10, timeoutRetries: 10, disconnectRetries: 5, connectionTimeout: Double(10))
        future.onSuccess {(peripheral, connectionEvent) in

            switch connectionEvent {
            case .Connected:
                guard let manager = self.selectionManager else {
                    return
                }
                self.updateKnownDevices(peripheral.id)
                manager.deviceConnected(peripheral)
                manager.updateWhenActive()
                break
            case .Disconnected:
                if let scene = self.scenePresenter {
                    scene.connectionLost();
                }
//                peripheral.reconnect()
                CentralManager.sharedInstance.stopScanning()
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
                guard let manager = self.selectionManager else {
                    return
                }
                manager.updateWhenActive()
            case .Timeout:
                //feature
                peripheral.reconnect()
            case .ForcedDisconnected:
                if let scene = self.scenePresenter {
                    scene.connectionLost();
                }
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
                break
            case .Failed:
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
                print("Fail")
            case .GiveUp:
                peripheral.disconnect()
//                self.updateWhenActive()
            }
        }
        future.onFailure {error in
            print("Fail \(error)")
        }

    }
    
    func updateKnownDevices(id:NSUUID){
        let userdefaults = NSUserDefaults.standardUserDefaults()
        if let testArray : [AnyObject] = userdefaults.arrayForKey("KnownBleDevices") {
            var objectArray:[NSUUID] = testArray as! [NSUUID]
            if objectArray.contains(id){
                
            }else{
                objectArray.append(id)
                userdefaults.setObject(objectArray, forKey: "KnownBleDevices")
            }
            
        } else {
            var array:[NSUUID] = [NSUUID]()
            array.append(id)
            userdefaults.setObject(array, forKey: "KnownBleDevices")
            
        }
        userdefaults.synchronize()
    }
    
    
    func setArduinoDevice(peripheral:Peripheral){
        
        let arduino:ArduinoDevice = ArduinoDevice(cbPeripheral: peripheral.cbPeripheral, advertisements: peripheral.advertisements, rssi: peripheral.rssi, test: true)
        
        if peripheral.services.count > 0 {
            for service in peripheral.services{
                if service.characteristics.count > 0 {
                    guard let manager = self.selectionManager else {
                        return
                    }
                    BluetoothService.swiftSharedInstance.arduino = arduino
                    manager.checkStart()
                    return
                }
                
            }
            
        }
        
        let future = arduino.discoverAllServices()
        
        future.onSuccess{peripheral in
            guard peripheral.services.count > 0 else {
                //ERROR
                return
            }
            
            let services:[Service] = peripheral.services
            
            for service in services{
                let charFuture = service.discoverAllCharacteristics();
                charFuture.onSuccess{service in
                    guard service.characteristics.count > 0 else {
                        return
                    }
                    if(arduino.txCharacteristic != nil && arduino.rxCharacteristic != nil){
                            guard let manager = self.selectionManager else {
                                return
                            }
                            BluetoothService.swiftSharedInstance.arduino = arduino
                            manager.checkStart()
                            return
                    }
                }
            }
            
        }

    }
    
    func setPhiroDevice(peripheral:Peripheral){
        
        let phiro:Phiro = Phiro(cbPeripheral: peripheral.cbPeripheral, advertisements: peripheral.advertisements, rssi: peripheral.rssi, test: true)
        
        if peripheral.services.count > 0 {
            for service in peripheral.services{
                if service.characteristics.count > 0 {
                    guard let manager = self.selectionManager else {
                        return
                    }
                    BluetoothService.swiftSharedInstance.phiro = phiro
                    manager.checkStart()
                    return
                }
                
            }
            
        }
        
        let future = phiro.discoverAllServices()
        
        future.onSuccess{peripheral in
            guard peripheral.services.count > 0 else {
                //ERROR
                return
            }
            
            let services:[Service] = peripheral.services
            
            for service in services{
                let charFuture = service.discoverAllCharacteristics();
                charFuture.onSuccess{service in
                    guard service.characteristics.count > 0 else {
                        return
                    }
                    if(phiro.txCharacteristic != nil && phiro.rxCharacteristic != nil){
                        guard let manager = self.selectionManager else {
                            return
                        }
                        BluetoothService.swiftSharedInstance.phiro = phiro
                        manager.checkStart()
                        return
                    }
                }
            }
            
        }
        
    }


    
}