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


class FirmataDevice:BluetoothDevice,FirmataDelegate {
    var firmata:Firmata = Firmata()
    
    var rxUUID: CBUUID { get { return CBUUID.init(string: "713D0002-503E-4C75-BA94-3148F18D941E") } }
    var txUUID: CBUUID { get { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") } }
    
    var rxCharacteristic:CBCharacteristic?
    var txCharacteristic:CBCharacteristic?

    //MARK: Init
    override init(peripheral: Peripheral) {
        super.init(peripheral: peripheral)
        setFirmata()
    }
    func setFirmata() {
        firmata.delegate = self
    }
    
    //MARK: override BluetoothDevice
    internal override func getName() -> String{
        return "FirmataDevice"
    }
    
    //MARK: dicovered Characteristics
    override internal func peripheral(peri: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        self.discoveredCharacteristics(peri, service: service, error: error)
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        
        for c in (characteristics) {
            
            switch c.UUID {
            case rxCharacteristicUUID():
                print(self, "didDiscoverCharacteristicsForService", "\(service.description) : RX")
                rxCharacteristic = c
                cbPeripheral.setNotifyValue(true, forCharacteristic: rxCharacteristic!)
                break
            case txCharacteristicUUID():
                print(self, "didDiscoverCharacteristicsForService", "\(service.description) : TX")
                txCharacteristic = c
                break
            default:
                //                    printLog(self, "didDiscoverCharacteristicsForService", "Found Characteristic: Unknown")
                break
            }
            
        }
        
        if txCharacteristic == nil{
            for c in (service.characteristics!) {
                if((c.properties.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue) > 0 || (c.properties.rawValue & CBCharacteristicProperties.Write.rawValue) > 0){
                    txCharacteristic = c
                    
                    break
                }
            }
        }
        if rxCharacteristic == nil{
            for c in (service.characteristics!) {
                if((c.properties.rawValue & CBCharacteristicProperties.Read.rawValue) > 0){
                    rxCharacteristic = c
                    //                    cbPeripheral.setNotifyValue(true, forCharacteristic: c)
                }
            }
        }
        firmata.analogMappingQuery()
        
    }
    
    func rxCharacteristicUUID()->CBUUID{
        return rxUUID
    }
    func txCharacteristicUUID()->CBUUID{
        return txUUID
    }
    
    //MARK: Helper
    
    internal func checkValue(value:Int)->Int {
        if (value < 0) {
            return 0;
        }
        if (value > 255) {
            return 255;
        }
        
        return (value);
    }
    
    //MARK: receive Data
    override internal func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //        super.peripheral(peripheral, didUpdateValueForCharacteristic: characteristic, error: error)
        print("readValue")
        if (characteristic == self.rxCharacteristic){
            guard let data = characteristic.value else {
                return
            }
            self.firmata.receiveData(data)
        }
    }
    
    //MARK: SendData
    func sendData(data: NSData) {
        //Send data to peripheral
        
        if (txCharacteristic == nil){
            print(self, "writeRawData", "Unable to write data without txcharacteristic")
            return
        }
        
        var writeType:CBCharacteristicWriteType
        
        if (txCharacteristic!.properties.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue) != 0 {
            
            writeType = CBCharacteristicWriteType.WithoutResponse
            
        }
            
        else if ((txCharacteristic!.properties.rawValue & CBCharacteristicProperties.Write.rawValue) != 0){
            
            writeType = CBCharacteristicWriteType.WithResponse
        }
            
        else{
            print(self, "writeRawData", "Unable to write data without characteristic write property")
            return
        }
        
        //send data in lengths of <= 20 bytes
        let dataLength = data.length
        let limit = 20
        
        //Below limit, send as-is
        if dataLength <= limit {
            cbPeripheral.writeValue(data, forCharacteristic: txCharacteristic!, type: writeType)
        }
            
            //Above limit, send in lengths <= 20 bytes
        else {
            
            var len = limit
            var loc = 0
            var idx = 0 //for debug
            
            while loc < dataLength {
                
                let rmdr = dataLength - loc
                if rmdr <= len {
                    len = rmdr
                }
                
                let range = NSMakeRange(loc, len)
                var newBytes = [UInt8](count: len, repeatedValue: 0)
                data.getBytes(&newBytes, range: range)
                let newData = NSData(bytes: newBytes, length: len)
                //                    println("\(self.classForCoder.description()) writeRawData : packet_\(idx) : \(newData.hexRepresentationWithSpaces(true))")
                cbPeripheral.writeValue(newData, forCharacteristic: txCharacteristic!, type: writeType)
                
                loc += len
                idx += 1
            }
        }
        
    }
    
    //MARK: Firmata delegate
    func didReceiveDigitalMessage(pin:Int,value:Int){
        print(pin,value)
    }
    
    func didReceiveDigitalPort(port:Int, portData:[Int]) {
        print(port,portData)
    }
    func didReceiveAnalogMessage(pin:Int,value:Int){
        print(pin,value)
    }
    
    func firmwareVersionReceived(name:String){
        print(name)
    }
    func protocolVersionReceived(name:String){
        print(name)
    }
    func stringDataReceived(message:String){
        print(message)
    }
    
    func didUpdateAnalogMapping(analogMapping:NSMutableDictionary){
        print(analogMapping)
    }
    
    func didUpdateCapability(pins: [[Int:Int]]) {
        print(pins)
    }

    
}

