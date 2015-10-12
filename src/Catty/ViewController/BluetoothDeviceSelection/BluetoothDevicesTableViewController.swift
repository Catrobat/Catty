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
import BluetoothHelper
import CoreBluetooth


class BluetoothDevicesTableViewController:UITableViewController {
    override func viewDidLoad() {
        self.tableView.backgroundColor = UIColor.backgroundColor()
    }
    
    
    func updateWhenActive() {
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
    }
    
    weak var delegate : BluetoothPopupVC?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let peri :Peripheral = CentralManager.sharedInstance.peripherals[indexPath.row];
        if peri.state == CBPeripheralState.Connected {
            self.deviceConnected(peri)
            return
        }
        let future = peri.connect(10, timeoutRetries: 10, disconnectRetries: 5, connectionTimeout: Double(10))
        future.onSuccess {(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                self.deviceConnected(peripheral)
                self.updateWhenActive()
            case .Disconnected:
                peripheral.reconnect()
                self.updateWhenActive()
            case .Timeout:
                peripheral.reconnect()
                self.updateWhenActive()
            case .ForcedDisconnected:
                self.updateWhenActive()
            case .Failed:
                print("Fail")
            case .GiveUp:
                peripheral.disconnect()
                self.updateWhenActive()
            }
        }
        future.onFailure {error in
            print("Fail \(error)")
        }
        
    }
    
    func deviceConnected(peripheral:Peripheral){
        if(delegate!.deviceArray!.count > 0){
            if(delegate!.deviceArray![0] == BluetoothDeviceID.phiro.rawValue){
                setPhiro(peripheral)
            } else if (delegate!.deviceArray![0] == BluetoothDeviceID.arduino.rawValue){
                setArduino(peripheral)
            }
        }

    }
    
    func setPhiro(peripheral:Peripheral){
        BluetoothService.swiftSharedInstance.phiro = peripheral as? Phiro
        guard let _ = BluetoothService.swiftSharedInstance.phiro else{
            print("test")
            return
        }
    }
    
    func setArduino(peripheral:Peripheral){
        let arduino:ArduinoDevice = ArduinoDevice(cbPeripheral: peripheral.cbPeripheral, advertisements: peripheral.advertisements, rssi: peripheral.rssi, test: true)
        
        if peripheral.services.count > 0 {
            for service in peripheral.services{
                if service.characteristics.count > 0 {
//                    _:[Characteristic] = service.characteristics;
//                    self.setLED(characteristics, service: service)
//                    self.checkStart()
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
                var token: dispatch_once_t = 0
                charFuture.onSuccess{service in
                    guard service.characteristics.count > 0 else {
                        return
                    }
                    if(arduino.txCharacteristic != nil && arduino.rxCharacteristic != nil){
                        dispatch_once(&token) { () -> Void in
                            self.checkStart()
                        }
                    }
//                    let characteristics:[Characteristic] = service.characteristics;
//                    self.setLED(characteristics, service: service)
                }
            }
            
        }

        BluetoothService.swiftSharedInstance.arduino = arduino
        guard let _ = BluetoothService.swiftSharedInstance.arduino else{
            print("test")
            return
        }
    }
    
    func checkStart(){
        delegate!.deviceArray!.removeAtIndex(0)
        if(delegate!.deviceArray!.count > 0){
            delegate!.setHeader()
            return
        }
        startScene()
    }
    
    
    func startScene(){
        let central = CentralManager.sharedInstance
        if central.isScanning {
            central.stopScanning()
        }

        delegate!.startScene()
    }

}