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
    var data:Data = Data()
    var receivedString:String = ""
    var receivedPin:Int = 0
    var receivedPort:Int = 0
    var receivedPortData:[Int] = [Int](repeating: 0, count: 1)
    var receivedValue:Int = 0
    var analogMapping = NSMutableDictionary()
    var capabilityQuery = [[Int:Int]]()
    let testfirmata = Firmata()
    
    init() {
        testfirmata.delegate = self;
    }
    
    func resetCallback () {
        callbackInvolved = false
        data = Data()
        receivedString = ""
        receivedPin = 0
        receivedValue = 0
        receivedPort = 0
        receivedPortData = [Int](repeating: 0, count: 1)
    }
    
    //MARK: Callbacks
    func sendData(_ newData: Data){
        callbackInvolved = true
        data = newData
    }
    func didReceiveAnalogMessage(_ pin:Int,value:Int){
        receivedPin = pin
        receivedValue = value
        callbackInvolved = true
    }
    
    func didReceiveDigitalMessage(_ pin:Int,value:Int){
        receivedPin = pin
        receivedValue = value
        callbackInvolved = true
    }
    func firmwareVersionReceived(_ name:String){
        receivedString = name
        callbackInvolved = true
    }
    func protocolVersionReceived(_ name:String){
        receivedString = name
        callbackInvolved = true
    }
    //    func I2cMessageReceived(message:String)
    func stringDataReceived(_ message:String){
        receivedString = message
        callbackInvolved = true
    }
    func didReceiveDigitalPort(_ port:Int, portData:[Int]){
        callbackInvolved = true
        receivedPort = port
        receivedPortData = portData
    }
    func didUpdateAnalogMapping(_ mapping:NSMutableDictionary){
        callbackInvolved = true
        analogMapping = mapping
    }
    func didUpdateCapability(_ pins:[[Int:Int]]){
        callbackInvolved = true
        capabilityQuery = pins
    }

}

class FirmataMock:Firmata{
    
    var receivedPin:UInt8 = 0
    var receivedPort:UInt8 = 0
    var receivedValue:UInt8 = 0
    var receivedPinMode:PinMode = .unknown
    var receivedString:String = ""
    var receivedPinState:PinState = .low
    var receivedBool:Bool = false
    
    
    override func writePinMode(_ newMode:PinMode, pin:UInt8){
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
    override func pinStateQuery(_ pin:UInt8){
        receivedPin = pin
    }
    override func servoConfig(_ pin:UInt8,minPulse:UInt8,maxPulse:UInt8){
        receivedPin = pin
    }
    override func stringData(_ string:String){
        receivedString = string
    }
    override func samplingInterval(_ intervalMilliseconds:UInt8){
        
    }
    override func writePWMValue(_ value:UInt8, pin:UInt8){
        receivedPin = pin
        receivedValue = value
    }
    override func writePinState(_ newState: PinState, pin:UInt8){
        receivedPin = pin
        receivedPinState = newState
    }
    override func setAnalogValueReportingforPin(_ pin:UInt8, enabled:Bool){
        receivedPin = pin
        receivedBool = enabled
    }
    override func setDigitalStateReportingForPin(_ digitalPin:UInt8, enabled:Bool){
        receivedPin = digitalPin
        receivedBool = enabled
    }
    override func setDigitalStateReportingForPort(_ port:UInt8, enabled:Bool){
        receivedPort = port
        receivedBool = enabled
    }
    override func receiveData(_ data:Data){
        //tested in FirmataTests
    }
}

class PeripheralMock: CBPeripheral {
    
    var dataToSend:Data = Data()
    init(test:Bool){
        //HACK
    }
    
    override func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        dataToSend = data
    }
}

class CharacteristicMock: CBCharacteristic {
    
    init(test:Bool){
        //HACK
//        self.properties = CBCharacteristicProperties(CBCharacteristicProperties.WriteWithoutResponse.rawValue)
    
    }
    
    override internal var properties: CBCharacteristicProperties {
        return CBCharacteristicProperties(rawValue: CBCharacteristicProperties.writeWithoutResponse.rawValue)
    }

}

class ArduinoTestMock: ArduinoPropertyProtocol {
    internal var totalPins = 3
    internal var analogMapping = NSMutableDictionary(objects: [NSNumber(value: 0 as UInt8),NSNumber(value: 1 as UInt8),NSNumber(value: 2 as UInt8),NSNumber(value: 3 as UInt8)], forKeys: [NSNumber(value: 0 as UInt8),NSNumber(value: 1 as UInt8),NSNumber(value: 2 as UInt8),NSNumber(value: 3 as UInt8)])
    internal var pinsArray = [[String:Any]]()
    
    internal let arduinoHelper:ArduinoHelper = ArduinoHelper()
}
