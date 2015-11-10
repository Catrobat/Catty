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

import XCTest


@testable import Pocket_Code

final class FirmataTest : XCTestCase, FirmataDelegate {
 
    var callbackInvolved = false
    var data:NSData = NSData()
    var receivedString:String = ""
    var receivedPin:Int = 0
    var receivedPort:Int = 0
    var receivedPortData:[Int] = [Int](count:1, repeatedValue: 0)
    var receivedValue:Int = 0
    let testfirmata = Firmata()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testfirmata.delegate = self
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
    }
    func didUpdateCapability(pins:[[Int:Int]]){
        callbackInvolved = true
    }
    
    //MARK: SEND
    func testWritePinModeCallback () {
        resetCallback()
        testfirmata.writePinMode(.Analog, pin: 4)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testReportVersionCallback () {
        resetCallback()
        testfirmata.reportVersion()
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testAnalogMappingQueryCallback () {
        resetCallback()
        testfirmata.analogMappingQuery()
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testPinStateQueryCallback () {
        resetCallback()
        testfirmata.pinStateQuery(4)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testCapabilityQueryCallback () {
        resetCallback()
        testfirmata.capabilityQuery()
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testServoConfigCallback () {
        resetCallback()
        testfirmata.servoConfig(4, minPulse: 1, maxPulse: 4)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testStringDataCallback () {
        resetCallback()
        testfirmata.stringData("test")
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testSamplingIntervalCallback () {
        resetCallback()
        testfirmata.samplingInterval(50)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testWritePWMCallback () {
        resetCallback()
        testfirmata.writePWMValue(20, pin: 4)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testWritePinStateCallback () {
        resetCallback()
        testfirmata.writePinState(.High, pin: 4)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testAnalogValueReportingCallback () {
        resetCallback()
        testfirmata.setAnalogValueReportingforPin(4, enabled: true)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testDigitalStateReportingPinCallback () {
        resetCallback()
        testfirmata.setDigitalStateReportingForPin(4, enabled: true)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testDigitalStateReportingPortCallback () {
        resetCallback()
        testfirmata.setDigitalStateReportingForPort(1, enabled: true)
        
        XCTAssertTrue(callbackInvolved, "Callback not called")
    }
    func testWritePinModeData () {
        resetCallback()
        testfirmata.writePinMode(.Analog, pin: 4)
        let bytes:[UInt8] = [SET_PIN_MODE,4,UInt8(PinMode.Analog.rawValue)]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testReportVersionData () {
        resetCallback()
        testfirmata.reportVersion()
        let bytes:[UInt8] = [REPORT_VERSION]
        let newData:NSData = NSData(bytes: bytes, length: 1)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testAnalogMappingQueryData () {
        resetCallback()
        testfirmata.analogMappingQuery()
        let bytes:[UInt8] = [START_SYSEX,ANALOG_MAPPING_QUERY,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testPinStateQueryData () {
        resetCallback()
        testfirmata.pinStateQuery(4)
        let bytes:[UInt8] = [START_SYSEX,PIN_STATE_QUERY,4,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 4)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testCapabilityQueryData () {
        resetCallback()
        testfirmata.capabilityQuery()
        let bytes:[UInt8] = [START_SYSEX,CAPABILITY_QUERY,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testServoConfigData () {
        resetCallback()
        testfirmata.servoConfig(4, minPulse: 1, maxPulse: 4)
        let bytes:[UInt8] = [START_SYSEX,SERVO_CONFIG,4,1 & 0x7F,1 >> 7,4 & 0x7F,4 >> 7,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 8)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testSamplingIntervalData () {
        resetCallback()
        testfirmata.samplingInterval(50)
        let bytes:[UInt8] = [START_SYSEX,SAMPLING_INTERVAL,50 & 0x7F,50 >> 7 ,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 5)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testWritePWMData () {
        resetCallback()
        testfirmata.writePWMValue(20, pin: 4)
        let bytes:[UInt8] = [ANALOG_MESSAGE+4,20 & 0x7F,20 >> 7]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testWritePinStateData () {
        resetCallback()
        testfirmata.writePinState(.High, pin: 4)
        var portMasks = [UInt8](count: 3, repeatedValue: 0)
        var newMask = UInt8(PinState.High.rawValue * Int(powf(2, Float(4))))
        portMasks[Int(0)] &= ~(1 << 4) //prep the saved mask by zeroing this pin's corresponding bit
        newMask |= portMasks[Int(0)] //merge with saved port state
        portMasks[Int(0)] = newMask
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE+4/8,data1,data2]
        let newData:NSData = NSData(bytes: bytes, length: 4)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testAnalogValueReportingData () {
        resetCallback()
        testfirmata.setAnalogValueReportingforPin(4, enabled: true)
        let bytes:[UInt8] = [REPORT_ANALOG+4,1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testDigitalStateReportingPinData () {
        resetCallback()
        testfirmata.setDigitalStateReportingForPin(4, enabled: true)
        var portMasks = [UInt8](count: 3, repeatedValue: 0)
        var data1:UInt8 = UInt8(portMasks[Int(0)])    //retrieve saved pin mask for port;
        data1 |= 1<<4
        let bytes:[UInt8] = [REPORT_DIGITAL+0,data1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    func testDigitalStateReportingPortData () {
        resetCallback()
        testfirmata.setDigitalStateReportingForPort(1, enabled: true)
        let bytes:[UInt8] = [REPORT_DIGITAL+1,1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        XCTAssertEqual(data, newData, "Send data wrong calculated")
    }
    
    //MARK: Receive

    func testReceiveReportVersion(){
        resetCallback()
        let bytes:[UInt8] = [REPORT_VERSION,1,4]
        let receivedData:NSData = NSData(bytes: bytes, length:3)
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedString, "\(1),\(4)", "Received data wrong calculated")
    }
    
    func testReceiveAnalogMessage(){
        resetCallback()
        let bytes:[UInt8] = [ANALOG_MESSAGE+4,20 & 0x7F,20 >> 7]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedPin, 18, "Received Pin wrong")
        XCTAssertEqual(receivedValue, 20, "Received Value wrong")
    }
    
    func testReceiveDigitalMessage(){
        resetCallback()
        let newMask = UInt8(0)
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE,data1,data2]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedPort, 0, "Received Port wrong")
        XCTAssertEqual(receivedPortData, [0,0,0,0,0,0,0,0], "Received PortData wrong")
    }
    
    func testReceiveDigitalMessage2(){
        resetCallback()
        let newMask = UInt8(PinState.High.rawValue * Int(powf(2, Float(4))))
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE,data1,data2]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedPort, 0, "Received Port wrong")
        XCTAssertEqual(receivedPortData, [0,0,0,0,1,0,0,0], "Received PortData wrong")
    }
    
    func testReceiveFirmware(){
        resetCallback()
        let data1:UInt8 = 23
        let data2:UInt8 = 2
        let name = "test"
        let data3 = name.dataUsingEncoding(NSASCIIStringEncoding)
        let count = data3!.length / sizeof(UInt8)
        var bytes = [UInt8](count: count, repeatedValue: 0)
        data3!.getBytes(&bytes, length:count * sizeof(UInt8))
        var bytestoSend:[UInt8] = [START_SYSEX,REPORT_FIRMWARE,data1,data2]
        for (var i = 0; i < data3!.length; i++){
            let lsb = bytes[i] & 0x7f;
            let append1:UInt8 = lsb
            bytestoSend.append(append1)
        }
        bytestoSend.append(END_SYSEX)
        let receivedData:NSData = NSData(bytes: bytestoSend, length:5+(data3!.length))
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedString, name + " \(23)." + "\(2)", "Received Port wrong")
    }
    
    func testReceiveStringData(){
        resetCallback()
        let name = "test"
        let data3 = name.dataUsingEncoding(NSASCIIStringEncoding)
        let count = data3!.length / sizeof(UInt8)
        var bytes = [UInt8](count: count, repeatedValue: 0)
        data3!.getBytes(&bytes, length:count * sizeof(UInt8))
        var bytestoSend:[UInt8] = [START_SYSEX,STRING_DATA]
        for (var i = 0; i < data3!.length; i++){
            let lsb = bytes[i] & 0x7f;
            let append1:UInt8 = lsb
            bytestoSend.append(append1)
        }

        bytestoSend.append(END_SYSEX)
        let receivedData:NSData = NSData(bytes: bytestoSend, length:3+(data3!.length*2))
        testfirmata.receiveData(receivedData)
        XCTAssertTrue(callbackInvolved, "Callback not called")
        XCTAssertEqual(receivedString, name , "Received Port wrong")
    }
}

