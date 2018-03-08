/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
    override internal func peripheral(_ peri: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.discoveredCharacteristics(peri, service: service, error: error as NSError?)
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        
        for c in (characteristics) {
            
            switch c.uuid {
            case rxCharacteristicUUID():
                print(self, "didDiscoverCharacteristicsForService", "\(service.description) : RX")
                rxCharacteristic = c
                cbPeripheral.setNotifyValue(true, for: c)
                break
            case txCharacteristicUUID():
                print(self, "didDiscoverCharacteristicsForService", "\(service.description) : TX")
                txCharacteristic = c
                break
            default:
//                printLog(self, "didDiscoverCharacteristicsForService", "Found Characteristic: Unknown")
                break
            }
            
        }

        if let characteristics = service.characteristics {
            if txCharacteristic == nil {
                for c in characteristics {
                    if ((c.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) > 0 || (c.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0) {
                        txCharacteristic = c
                        break
                    }
                }
            }
            if rxCharacteristic == nil{
                for c in characteristics {
                    if ((c.properties.rawValue & CBCharacteristicProperties.read.rawValue) > 0) {
                        rxCharacteristic = c
    //                    cbPeripheral.setNotifyValue(true, forCharacteristic: c)
                    }
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
    
    internal func checkValue(_ value:Int)->Int {
        if (value < 0) {
            return 0;
        }
        if (value > 255) {
            return 255;
        }
        
        return (value);
    }
    
    internal func convertAnalogPin(_ analogPinNumber:Int) -> Int {
        let pin: UInt8 = UInt8(checkValue(analogPinNumber))
        switch (pin) {
        case 14:
            return 0
        case 15:
            return 1
        case 16:
            return 2
        case 17:
            return 3
        case 18:
            return 4
        case 19:
            return 5
        default:
            return 100
        }
    }
    
    //MARK: receive Data
    override internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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
    func sendData(_ data: Data) {
        // send data to peripheral
        guard let txCharacteristic = txCharacteristic else {
            print(self, "writeRawData", "Unable to write data without txcharacteristic")
            return
        }
        
        let writeType: CBCharacteristicWriteType
        if (txCharacteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
            writeType = .withoutResponse
        } else if ((txCharacteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0) {
            writeType = .withResponse
        } else {
            print(self, "writeRawData", "Unable to write data without characteristic write property")
            return
        }
        
        //send data in lengths of <= 20 bytes
        let dataLength = data.count
        let limit = 20
        
        //Below limit, send as-is
        if dataLength <= limit {
            cbPeripheral.writeValue(data, for: txCharacteristic, type: writeType)
        } else {
            //Above limit, send in lengths <= 20 bytes
            var len = limit
            var loc = 0
            var idx = 0 //for debug
            
            while loc < dataLength {
                
                let rmdr = dataLength - loc
                if rmdr <= len {
                    len = rmdr
                }
                
                let newData = data.subdata(in: loc..<loc+len)
//                println("\(self.classForCoder.description()) writeRawData : packet_\(idx) : \(newData.hexRepresentationWithSpaces(true))")
                cbPeripheral.writeValue(newData, for: txCharacteristic, type: writeType)
                
                loc += len
                idx += 1
            }
        }
    }
    
    //MARK: Firmata delegate
    func didReceiveDigitalMessage(_ pin:Int,value:Int){
        print(pin,value)
    }
    
    func didReceiveDigitalPort(_ port:Int, portData:[Int]) {
        print(port,portData)
    }

    func didReceiveAnalogMessage(_ pin:Int,value:Int){
        print(pin,value)
    }
    
    func firmwareVersionReceived(_ name:String){
        print(name)
    }

    func protocolVersionReceived(_ name:String){
        print(name)
    }

    func stringDataReceived(_ message:String){
        print(message)
    }
    
    func didUpdateAnalogMapping(_ analogMapping:NSMutableDictionary){
        print(analogMapping)
    }
    
    func didUpdateCapability(_ pins: [[Int:Int]]) {
        print(pins)
    }
}
