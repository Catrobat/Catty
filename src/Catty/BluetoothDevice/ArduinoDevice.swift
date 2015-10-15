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

private let PIN_ANALOG_0:Int = 0;
private let PIN_ANALOG_1:Int = 1;
private let PIN_ANALOG_2:Int = 2;
private let PIN_ANALOG_3:Int = 3;
private let PIN_ANALOG_4:Int = 4;
private let PIN_ANALOG_5:Int = 5;

private let PORT_DIGITAL_0:Int = 0;
private let PORT_DIGITAL_1:Int = 1;

private let MIN_PWM_PIN_GROUP_1:Int = 3;
private let MAX_PWM_PIN_GROUP_1:Int = 3;
private let MIN_PWM_PIN_GROUP_2:Int = 5;
private let MAX_PWM_PIN_GROUP_2:Int = 6;
private let MIN_PWM_PIN_GROUP_3:Int = 9;
private let MAX_PWM_PIN_GROUP_3:Int = 11;

private let MIN_ANALOG_SENSOR_PIN:Int = 0;
private let MAX_ANALOG_SENSOR_PIN:Int = 5;


@objc public class ArduinoDevice:BluetoothDevice,FirmataDelegate {
    
    private let Arduino_UUID:CBUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB")
    private static let tag:String = "Arduino";

    private let rxUUID = CBUUID.init(string: "713D0002-503E-4C75-BA94-3148F18D941E") // TODO
    private let txUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") // TODO
    
    var rxCharacteristic:CBCharacteristic?
    var txCharacteristic:CBCharacteristic?
    
    let digitalQueue:dispatch_queue_t = dispatch_queue_create("arduino.request.digital", DISPATCH_QUEUE_SERIAL)
    let analogQueue:dispatch_queue_t = dispatch_queue_create("arduino.request.analog", DISPATCH_QUEUE_SERIAL)
    
    var digitalValue:Int = 0
    var analogValue:Double = 0
    
    let firmata:Firmata = Firmata()
    public let arduinoHelper:ArduinoHelper = ArduinoHelper()
    
    public func setFirmata() {
        firmata.delegate = self
    }
    
    
    
    override init(cbPeripheral: CBPeripheral, advertisements: [String : String], rssi: Int, test: Bool) {
        super.init(cbPeripheral: cbPeripheral, advertisements: advertisements, rssi: rssi, test: test)
        setFirmata()
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
    
    //MARK: receive Data
//    
    override public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
//        super.peripheral(peripheral, didUpdateValueForCharacteristic: characteristic, error: error)
        print("readValue")
        if (characteristic == self.rxCharacteristic){
            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let data = characteristic.value else {
                    //ERROR
                    return
                }
                self.firmata.receiveData(data)
//            })
            
        }
    }

    
    
    //MARK: Arduino Functions
    func setDigitalArduinoPin(digitalPinNumber:UInt8, pinValue:Int){
        if(pinValue > 0){
            firmata.writePinMode(PinMode.Output, pin: digitalPinNumber)
            firmata.writePinState(PinState.High, pin: digitalPinNumber)
            setPortValue(Int(digitalPinNumber), value: 1)
        } else {
            firmata.writePinMode(PinMode.Output, pin: digitalPinNumber)
            firmata.writePinState(PinState.Low, pin: digitalPinNumber)
            setPortValue(Int(digitalPinNumber), value: 0)
        }
        
    }
    
    func getDigitalArduinoPin(digitalPinNumber:UInt8)-> Double {
        dispatch_sync(digitalQueue){
            self.firmata.writePinMode(PinMode.Input, pin: digitalPinNumber)
            self.firmata.reportVersion()
            self.firmata.setDigitalStateReportingForPort(digitalPinNumber / 8, enabled: true)
            print("requestValue")
            let semaphore = BluetoothService.swiftSharedInstance.getSemaphore()
            BluetoothService.swiftSharedInstance.setDigitalSemaphore(semaphore)
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(6 * NSEC_PER_SEC)))
            BluetoothService.swiftSharedInstance.signalDigitalSemaphore(false)
            self.firmata.setDigitalStateReportingForPort(digitalPinNumber / 8, enabled: false)
            self.digitalValue = self.getPortValue(Int(digitalPinNumber))
            print("setValue:\(self.digitalValue)")
        }
        print("setValue after dispatch:\(self.digitalValue)")
        return Double(self.digitalValue)
    }
    
    
    func getAnalogArduinoPin(analogPinNumber:UInt8) -> Double {
        dispatch_sync(digitalQueue){
            self.firmata.writePinMode(PinMode.Input, pin: analogPinNumber)
            self.firmata.setAnalogValueReportingforPin(analogPinNumber, enabled: true)
            let semaphore = BluetoothService.swiftSharedInstance.getSemaphore()
            BluetoothService.swiftSharedInstance.setAnalogSemaphore(semaphore)
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)))
            self.firmata.setAnalogValueReportingforPin(analogPinNumber, enabled: false)
            self.firmata.setDigitalStateReportingForPort(1, enabled: true)
            self.analogValue = self.getAnalogPin(analogPinNumber)
            print(self.analogValue)
        }
        return Double(self.analogValue)
    }
    
    
    func getAnalogPin(analogPinNumber:UInt8) -> Double {

        switch (analogPinNumber) {
        case 0:
            return Double(getAnalogPin0())
        case 1:
            return Double(getAnalogPin1())
        case 2:
            return Double(getAnalogPin2())
        case 3:
            return Double(getAnalogPin3())
        case 4:
            return Double(getAnalogPin4())
        case 5:
            return Double(getAnalogPin5())
        default:
            return 0
        }
    }
    
    func setAnalogArduinoPin(pin:UInt8, value:UInt8) {
        firmata.writePinMode(PinMode.PWM, pin: pin)
        firmata.writePWMValue(value, pin: pin)
    }
    
    func reportFirmwareVersion(){
        firmata.reportFirmware()
    }
    
    //MARK: Helper
    func castValue(value:Int)->Int {
        if (value <= 0) {
            return 0;
        }
        if (value >= 100) {
            return 255;
        }
        
        return (Int) (Double(value) * 2.55);
    }
    
    // MARK: override
    
    override public func getName() -> String{
        return "Arduino"
    }
    
    override public func getBluetoothDeviceUUID()->CBUUID{
        return Arduino_UUID
    }
    
    override public func peripheral(peri: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
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
        
    }
    
    func rxCharacteristicUUID()->CBUUID{
        return rxUUID
    }
    func txCharacteristicUUID()->CBUUID{
        return txUUID
    }
    
    
    //MARK: Firmata delegate
    
    func didReceiveDigitalMessage(pin:Int,value:Int){
        arduinoHelper.didReceiveDigitalMessage(pin, value: value)
    }

    func didReceiveDigitalPort(port:Int, portData:[Int]) {
        arduinoHelper.didReceiveDigitalPort(port, portData: portData)
        BluetoothService.swiftSharedInstance.signalDigitalSemaphore(true)
    }
    func didReceiveAnalogMessage(pin:Int,value:Int){
        arduinoHelper.didReceiveAnalogMessage(pin, value: value)
        BluetoothService.swiftSharedInstance.signalAnalogSemaphore()
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
    
    
    //MARK: setter/getter
    
    public func getAnalogPin0() -> Int {
        return arduinoHelper.analogPin0;
    }
    
    public func getAnalogPin1() -> Int {
        return arduinoHelper.analogPin1;
    }
    
    public func getAnalogPin2() -> Int {
        return arduinoHelper.analogPin2;
    }
    
    public func getAnalogPin3() -> Int {
        return arduinoHelper.analogPin3;
    }
    
    public func getAnalogPin4() -> Int {
        return arduinoHelper.analogPin4;
    }
    
    public func getAnalogPin5() -> Int {
        return arduinoHelper.analogPin5;
    }
    
    public func getPortValue(pin:Int) -> Int {
        let port:Int = pin / 8
        let portPin:Int = pin % 8
        if(arduinoHelper.portValues[port][portPin] == arduinoHelper.digitalValues[pin]){
            print("true")
        }
        return arduinoHelper.digitalValues[pin]
    }
    
    public func setPortValue(pin:Int, value:Int) {
        let port:Int = pin / 8
        let portPin:Int = pin % 8
        arduinoHelper.digitalValues[pin] = value
        arduinoHelper.portValues[port][portPin] = value
    }

    
}


public class ArduinoHelper {
    private var analogPin0 = 0;
    private var analogPin1 = 0;
    private var analogPin2 = 0;
    private var analogPin3 = 0;
    private var analogPin4 = 0;
    private var analogPin5 = 0;
    
    var digitalValues:[Int] = [Int](count: 21, repeatedValue: 0)
    
    var portValues = Array(count: 3, repeatedValue: Array(count: 8, repeatedValue: 0))
    //Helper
    private var previousDigitalPin:UInt8 = 255;
    private var previousAnalogPin:UInt8 = 255;
    
    func didReceiveAnalogMessage(pin:Int,value:Int){
        switch (pin) {
        case 0:
            analogPin0 = value
            break
        case 1:
            analogPin1 = value
            break
        case 2:
            analogPin2 = value
            break
        case 3:
            analogPin3 = value
            break
        case 4:
            analogPin4 = value
            break
        case 5:
            analogPin5 = value
            break
            
        default: break
            //NOT USED SENSOR
        }

    }
    
    func didReceiveDigitalPort(port:Int, portData:[Int]){
        portValues[port] = portData
    }
    
    func didReceiveDigitalMessage(pin:Int,value:Int){
        digitalValues[pin] = value
    }
    
}
