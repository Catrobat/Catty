/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

import BluetoothHelper
import CoreBluetooth
import Foundation

@objc enum BluetoothDeviceID: Int {
    case arduino
    case phiro
}

@objc
open class BluetoothService: NSObject {

    static let swiftSharedInstance = BluetoothService()

    // the sharedInstance class method can be reached from ObjC
    @objc open class func sharedInstance() -> BluetoothService {
        BluetoothService.swiftSharedInstance
    }

    var digitalSemaphoreArray: [DispatchSemaphore] = []
    var analogSemaphoreArray: [DispatchSemaphore] = []

    @objc var phiro: PhiroDevice?
    @objc var arduino: ArduinoDevice?
    @objc weak var selectionManager: BluetoothDevicesTableViewController?
    @objc weak var stagePresenter: StagePresenterViewController?
    @objc var connectionTimer: Timer?

    @objc func setDigitalSemaphore(_ semaphore: DispatchSemaphore) {
        digitalSemaphoreArray.append(semaphore)
    }

    @objc func signalDigitalSemaphore(_ check: Bool) {
        if !digitalSemaphoreArray.isEmpty {
            digitalSemaphoreArray.remove(at: 0)
        }
        if check == true {
            if !digitalSemaphoreArray.isEmpty {
                let sema = digitalSemaphoreArray[0]
                digitalSemaphoreArray.remove(at: 0)
                sema.signal()
            }
        }

    }

    @objc func setAnalogSemaphore(_ semaphore: DispatchSemaphore) {
        analogSemaphoreArray.append(semaphore)
    }

    @objc open func signalAnalogSemaphore() {
        if !analogSemaphoreArray.isEmpty {
            let sema = analogSemaphoreArray[0]
            analogSemaphoreArray.remove(at: 0)
            sema.signal()
        }

    }

    @objc func getSemaphore() -> DispatchSemaphore {
        DispatchSemaphore(value: 0)
    }

    @objc func getSensorPhiro() -> PhiroDevice? {
        guard let senorPhiro = phiro else {
            return nil
        }
        return senorPhiro
    }

    @objc func getSensorArduino() -> ArduinoDevice? {
        guard let senorArduino = arduino else {
            return nil
        }
        return senorArduino
    }

    @objc open func disconnect() {
        self.phiro?.disconnect()
        self.arduino?.disconnect()
        self.phiro = nil
        self.arduino = nil
    }

    // MARK: Bluetooth Connection

    @objc func connectDevice(_ peri: Peripheral) {

        let future = peri.connect(10, timeoutRetries: 2, disconnectRetries: 0, connectionTimeout: Double(4))
        future.onSuccess {peripheral, connectionEvent in

            switch connectionEvent {
            case .connected:
                self.updateKnownDevices(peripheral.id)
                guard let manager = self.selectionManager else {
                    return
                }
                manager.deviceConnected(peripheral)
                manager.updateWhenActive()
            case .disconnected:
                if let stage = self.stagePresenter {
                    stage.connectionLost()
                }
                //                peripheral.reconnect()
                CentralManager.sharedInstance.stopScanning()
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
                guard let manager = self.selectionManager else {
                    return
                }
                manager.updateWhenActive()
            case .timeout:
                peripheral.reconnect()
            case .forcedDisconnected:
                if let stage = self.stagePresenter {
                    stage.connectionLost()
                }
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
            case .failed:
                CentralManager.sharedInstance.disconnectAllPeripherals()
                CentralManager.sharedInstance.removeAllPeripherals()
                print("Fail")
                self.connectionFailure()
            case .giveUp:
                peripheral.disconnect()
                print("GiveUp")
                self.giveUpFailure()
            }
        }
        future.onFailure {error in
            print("Fail \(error)")
            self.connectionFailure()
        }

    }

    @objc func updateKnownDevices(_ id: UUID) {
        let userdefaults = UserDefaults.standard
        if var stringArray = userdefaults.array(forKey: "KnownBluetoothDevices") as? [String] {
            if !stringArray.contains(id.uuidString) {
                stringArray.append(id.uuidString)
                userdefaults.set(stringArray, forKey: "KnownBluetoothDevices")
            }

        } else {
            var array = [String]()
            array.append(id.uuidString)
            userdefaults.set(array, forKey: "KnownBluetoothDevices")

        }
        userdefaults.synchronize()
    }

    @objc func removeKnownDevices() {
        let userdefaults = UserDefaults.standard
        userdefaults.set([NSString](), forKey: "KnownBluetoothDevices")
    }

    @objc func setBLEDevice(_ peripheral: Peripheral, type: BluetoothDeviceID) {
        var bluetoothDevice: BluetoothDevice

        switch type {
        case .arduino:
            bluetoothDevice = ArduinoDevice(peripheral: peripheral)
        case .phiro:
            bluetoothDevice = PhiroDevice(peripheral: peripheral)
        }

        //        let arduino:ArduinoDevice = ArduinoDevice(peripheral:peripheral)
        if !peripheral.services.isEmpty {
            for service in peripheral.services where (!service.characteristics.isEmpty) {
                guard let manager = self.selectionManager else {
                    print("SHOULD NEVER HAPPEN")
                    return
                }
                BluetoothService.swiftSharedInstance.arduino = arduino
                manager.checkStart()
                return
            }

        }

        let future = bluetoothDevice.discoverAllServices()

        future.onSuccess {peripheral in
            guard !peripheral.services.isEmpty else {
                self.serviceDiscoveryFailed()
                return
            }

            let services: [Service] = peripheral.services

            for service in services {
                let charFuture = service.discoverAllCharacteristics()
                charFuture.onSuccess {service in
                    guard !service.characteristics.isEmpty else {
                        self.serviceDiscoveryFailed()
                        return
                    }
                    switch type {
                    case .arduino, .phiro:
                        if let firmataDevice = bluetoothDevice as? FirmataDevice, firmataDevice.txCharacteristic != nil && firmataDevice.rxCharacteristic != nil {
                            guard let manager = self.selectionManager else {
                                print("SHOULD NEVER HAPPEN")
                                return
                            }
                            //                            arduino.reportSensorData(true)
                            if let timer = self.connectionTimer {
                                timer.invalidate()
                            }
                            switch type {
                            case .arduino:
                                BluetoothService.swiftSharedInstance.arduino = bluetoothDevice as? ArduinoDevice
                            case .phiro:
                                BluetoothService.swiftSharedInstance.phiro = bluetoothDevice as? PhiroDevice
                            }

                            manager.checkStart()
                            self.selectionManager = nil
                            return
                        }
                    }

                }
                charFuture.onFailure {_ in
                    self.serviceDiscoveryFailed()
                }
            }
        }

        future.onFailure {_ in
            self.serviceDiscoveryFailed()
        }
        connectionTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(BluetoothService.serviceDiscoveryFailed), userInfo: nil, repeats: false)

    }

    @objc func serviceDiscoveryFailed() {
        if let manager = self.selectionManager {
            manager.deviceNotResponding()
        }
        Util.alert(title: klocalizedBluetoothConnectionFailed, text: klocalizedBluetoothNotResponding)
    }

    func giveUpFailure() {
        if let manager = self.selectionManager {
            manager.giveUpConnectionToDevice()
        }
        Util.alert(title: klocalizedBluetoothConnectionLost, text: klocalizedBluetoothDisconnected)
    }

    func connectionFailure() {
        if let manager = self.selectionManager {
            manager.deviceFailedConnection()
        }
        Util.alert(title: klocalizedBluetoothConnectionFailed, text: klocalizedBluetoothCannotConnect)
    }

    //    func setPhiroDevice(peripheral:Peripheral){
    //
    //        let phiro:Phiro = Phiro(peripheral:peripheral)
    //        phiro.reportSensorData(true)
    //        if peripheral.services.count > 0 {
    //            for service in peripheral.services{
    //                if service.characteristics.count > 0 {
    //                    guard let manager = self.selectionManager else {
    //                        return
    //                    }
    //                    BluetoothService.swiftSharedInstance.phiro = phiro
    //                    manager.checkStart()
    //                    return
    //                }
    //
    //            }
    //
    //        }
    //
    //        let future = phiro.discoverAllServices()
    //
    //        future.onSuccess{peripheral in
    //            guard peripheral.services.count > 0 else {
    //                self.serviceDiscoveryFailed()
    //                return
    //            }
    //
    //            let services:[Service] = peripheral.services
    //
    //            for service in services{
    //                let charFuture = service.discoverAllCharacteristics();
    //                charFuture.onSuccess{service in
    //                    guard service.characteristics.count > 0 else {
    //                        self.serviceDiscoveryFailed()
    //                        return
    //                    }
    //                    if(phiro.txCharacteristic != nil && phiro.rxCharacteristic != nil){
    //                        guard let manager = self.selectionManager else {
    //                            return
    //                        }
    ////                        phiro.reportSensorData(true)
    //                        BluetoothService.swiftSharedInstance.phiro = phiro
    //                        manager.checkStart()
    //                        return
    //                    }
    //                    self.serviceDiscoveryFailed()
    //                }
    //                charFuture.onFailure{error in
    //                    self.serviceDiscoveryFailed()
    //                }
    //            }
    //
    //        }
    //
    //        future.onFailure{error in
    //            self.serviceDiscoveryFailed()
    //        }
    //
    //    }

    @objc func resetBluetoothDevice() {

        if let phiroReset = phiro {
            phiroReset.reportSensorData(false)
            phiroReset.resetPins()
        }

        if let arduinoReset = arduino {
            arduinoReset.resetArduino()
        }

    }

    @objc func continueBluetoothDevice() {

        if let phiroReset = phiro {
            phiroReset.reportSensorData(true)
        }

        if let arduinoReset = arduino {
            arduinoReset.reportSensorData(true)
        }

    }

    @objc func pauseBluetoothDevice() {

        if let phiroReset = phiro {
            phiroReset.reportSensorData(false)
        }

        if let arduinoReset = arduino {
            arduinoReset.reportSensorData(false)
        }

    }

}
