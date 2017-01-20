/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

import CoreBluetooth
import BluetoothHelper

class FirmataDelegateMock: FirmataDelegate {
    var callbackInvolved = false
    var data:NSData = NSData()
    var receivedString:String = ""
    var receivedPin:Int = 0
    var receivedPort:Int = 0
    var receivedPortData:[Int] = [Int](count:1, repeatedValue: 0)
    var receivedValue:Int = 0
    var analogMapping = NSMutableDictionary()
    var capabilityQuery = [[Int:Int]]()
    let testfirmata = Firmata()
    
    init() {
        testfirmata.delegate = self;
    }
    
    func resetCallback () {
        callbackInvolved = false
        data = NSData()
        receivedString = ""
        receivedPin = 0
        receivedValue = 0
        receivedPort = 0
        receivedPortData = [Int](count:1, repeatedValue: 0)
    }
    
    //MARK: Callbacks
    func sendData(newData: NSData){
        callbackInvolved = true
        data = newData
    }
    func didReceiveAnalogMessage(pin:Int,value:Int){
        receivedPin = pin
        receivedValue = value
        callbackInvolved = true
    }
    
    func didReceiveDigitalMessage(pin:Int,value:Int){
        receivedPin = pin
        receivedValue = value
        callbackInvolved = true
    }
    func firmwareVersionReceived(name:String){
        receivedString = name
        callbackInvolved = true
    }
    func protocolVersionReceived(name:String){
        receivedString = name
        callbackInvolved = true
    }
    //    func I2cMessageReceived(message:String)
    func stringDataReceived(message:String){
        receivedString = message
        callbackInvolved = true
    }
    func didReceiveDigitalPort(port:Int, portData:[Int]){
        callbackInvolved = true
        receivedPort = port
        receivedPortData = portData
    }
    func didUpdateAnalogMapping(mapping:NSMutableDictionary){
        callbackInvolved = true
        analogMapping = mapping
    }
    func didUpdateCapability(pins:[[Int:Int]]){
        callbackInvolved = true
        capabilityQuery = pins
    }

}

class FirmataMock:Firmata{
    
    var receivedPin:UInt8 = 0
    var receivedPort:UInt8 = 0
    var receivedValue:UInt8 = 0
    var receivedPinMode:PinMode = .Unknown
    var receivedString:String = ""
    var receivedPinState:PinState = .Low
    var receivedBool:Bool = false
    
    
    override func writePinMode(newMode:PinMode, pin:UInt8){
        receivedPin = pin
        receivedPinMode = newMode
    }
    override func reportVersion(){
        //tested in FirmataTests
    }
    override func reportFirmware(){
        //tested in FirmataTests
    }
    override func analogMappingQuery(){
        //tested in FirmataTests
    }
    override func capabilityQuery(){
        //tested in FirmataTests
    }
    override func pinStateQuery(pin:UInt8){
        receivedPin = pin
    }
    override func servoConfig(pin:UInt8,minPulse:UInt8,maxPulse:UInt8){
        receivedPin = pin
    }
    override func stringData(string:String){
        receivedString = string
    }
    override func samplingInterval(intervalMilliseconds:UInt8){
        
    }
    override func writePWMValue(value:UInt8, pin:UInt8){
        receivedPin = pin
        receivedValue = value
    }
    override func writePinState(newState: PinState, pin:UInt8){
        receivedPin = pin
        receivedPinState = newState
    }
    override func setAnalogValueReportingforPin(pin:UInt8, enabled:Bool){
        receivedPin = pin
        receivedBool = enabled
    }
    override func setDigitalStateReportingForPin(digitalPin:UInt8, enabled:Bool){
        receivedPin = digitalPin
        receivedBool = enabled
    }
    override func setDigitalStateReportingForPort(port:UInt8, enabled:Bool){
        receivedPort = port
        receivedBool = enabled
    }
    override func receiveData(data:NSData){
        //tested in FirmataTests
    }
}

class PeripheralMock: CBPeripheral {
    
    var dataToSend:NSData = NSData()
    init(test:Bool){
        //HACK
    }
    
    override func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        dataToSend = data
    }
}

class CharacteristicMock: CBCharacteristic {
    
    init(test:Bool){
        //HACK
//        self.properties = CBCharacteristicProperties(CBCharacteristicProperties.WriteWithoutResponse.rawValue)
    
    }
    
    override internal var properties: CBCharacteristicProperties {
        return CBCharacteristicProperties(rawValue: CBCharacteristicProperties.WriteWithoutResponse.rawValue)
    }

}

class ArduinoTestMock: ArduinoPropertyProtocol {
    internal var totalPins = 3
    internal var analogMapping = NSMutableDictionary(objects: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)], forKeys: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)])
    internal var pinsArray = [[String:Any]]()
    
    internal let arduinoHelper:ArduinoHelper = ArduinoHelper()
}
