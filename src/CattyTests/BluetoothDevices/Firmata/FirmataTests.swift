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

class FirmataMock: FirmataDelegate {
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

final class FirmataTests : XCTestCase{

    var mock = FirmataMock()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        //Given
        mock = FirmataMock()
    }
    //MARK: SEND
    func testWritePinModeCallback () {
        //When
        mock.testfirmata.writePinMode(.Analog, pin: 4)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testReportVersionCallback () {
        //When
        mock.testfirmata.reportVersion()
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testAnalogMappingQueryCallback () {
        //When
        mock.testfirmata.analogMappingQuery()
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testPinStateQueryCallback () {
        //When
        mock.testfirmata.pinStateQuery(4)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testCapabilityQueryCallback () {
        //When
        mock.testfirmata.capabilityQuery()
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testServoConfigCallback () {
        //When
        mock.testfirmata.servoConfig(4, minPulse: 1, maxPulse: 4)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testStringDataCallback () {
        //When
        mock.testfirmata.stringData("test")
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testSamplingIntervalCallback () {
        //When
        mock.testfirmata.samplingInterval(50)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testWritePWMCallback () {
        //When
        mock.testfirmata.writePWMValue(20, pin: 4)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testWritePinStateCallback () {
        //When
        mock.testfirmata.writePinState(.High, pin: 4)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testAnalogValueReportingCallback () {
        //When
        mock.testfirmata.setAnalogValueReportingforPin(4, enabled: true)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testDigitalStateReportingPinCallback () {
        //When
        mock.testfirmata.setDigitalStateReportingForPin(4, enabled: true)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testDigitalStateReportingPortCallback () {
        //When
        mock.testfirmata.setDigitalStateReportingForPort(1, enabled: true)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
    }
    func testWritePinModeData () {
        //Given
        let bytes:[UInt8] = [SET_PIN_MODE,4,UInt8(PinMode.Analog.rawValue)]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.writePinMode(.Analog, pin: 4)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testReportVersionData () {
        //Given
        let bytes:[UInt8] = [REPORT_VERSION]
        let newData:NSData = NSData(bytes: bytes, length: 1)
        //When
        mock.testfirmata.reportVersion()

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testAnalogMappingQueryData () {
        //Given
        let bytes:[UInt8] = [START_SYSEX,ANALOG_MAPPING_QUERY,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.analogMappingQuery()

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testPinStateQueryData () {
        //Given
        let bytes:[UInt8] = [START_SYSEX,PIN_STATE_QUERY,4,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 4)
        //When
        mock.testfirmata.pinStateQuery(4)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testCapabilityQueryData () {
        //Given
        let bytes:[UInt8] = [START_SYSEX,CAPABILITY_QUERY,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.capabilityQuery()

        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testServoConfigData () {
        //Given
        let bytes:[UInt8] = [START_SYSEX,SERVO_CONFIG,4,1 & 0x7F,1 >> 7,4 & 0x7F,4 >> 7,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 8)
        //When
        mock.testfirmata.servoConfig(4, minPulse: 1, maxPulse: 4)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testSamplingIntervalData () {
        //Given
        let bytes:[UInt8] = [START_SYSEX,SAMPLING_INTERVAL,50 & 0x7F,50 >> 7 ,END_SYSEX]
        let newData:NSData = NSData(bytes: bytes, length: 5)
        //When
        mock.testfirmata.samplingInterval(50)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testWritePWMData () {
        //Given
        let bytes:[UInt8] = [ANALOG_MESSAGE+4,20 & 0x7F,20 >> 7]
        let newData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.writePWMValue(20, pin: 4)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testWritePinStateData () {
        //Given
        var portMasks = [UInt8](count: 3, repeatedValue: 0)
        var newMask = UInt8(PinState.High.rawValue * Int(powf(2, Float(4))))
        portMasks[Int(0)] &= ~(1 << 4) //prep the saved mask by zeroing this pin's corresponding bit
        newMask |= portMasks[Int(0)] //merge with saved port state
        portMasks[Int(0)] = newMask
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE+4/8,data1,data2]
        let newData:NSData = NSData(bytes: bytes, length:3)
        
        //When
        mock.testfirmata.writePinState(.High, pin: 4)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testAnalogValueReportingData () {
        //Given
        let bytes:[UInt8] = [REPORT_ANALOG+4,1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        //When
        mock.testfirmata.setAnalogValueReportingforPin(4, enabled: true)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testDigitalStateReportingPinData () {
        //Given
        var portMasks = [UInt8](count: 3, repeatedValue: 0)
        var data1:UInt8 = UInt8(portMasks[Int(0)])    //retrieve saved pin mask for port;
        data1 |= 1<<4
        let bytes:[UInt8] = [REPORT_DIGITAL+0,data1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        //When
        mock.testfirmata.setDigitalStateReportingForPin(4, enabled: true)

        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    func testDigitalStateReportingPortData () {
        //Given
        let bytes:[UInt8] = [REPORT_DIGITAL+1,1]
        let newData:NSData = NSData(bytes: bytes, length:2)
        //When
        mock.testfirmata.setDigitalStateReportingForPort(1, enabled: true)
        //Then
        XCTAssertEqual(mock.data, newData, "Send data wrong calculated")
    }
    
    //MARK: Receive

    func testReceiveReportVersion(){
        //Given
        let bytes:[UInt8] = [REPORT_VERSION,1,4]
        let receivedData:NSData = NSData(bytes: bytes, length:3)
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedString, "\(1),\(4)", "Received data wrong calculated")
    }
    
    func testReceiveAnalogMessage(){
        //Given
        let bytes:[UInt8] = [ANALOG_MESSAGE+4,20 & 0x7F,20 >> 7]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedPin, 18, "Received Pin wrong")
        XCTAssertEqual(mock.receivedValue, 20, "Received Value wrong")
    }
    
    func testReceiveDigitalMessage(){
        //Given
        let newMask = UInt8(0)
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE,data1,data2]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedPort, 0, "Received Port wrong")
        XCTAssertEqual(mock.receivedPortData, [0,0,0,0,0,0,0,0], "Received PortData wrong")
    }
    
    func testReceiveDigitalMessage2(){
        //Given
        let newMask = UInt8(PinState.High.rawValue * Int(powf(2, Float(4))))
        var data1 = newMask<<1; data1 >>= 1  //remove MSB
        let data2 = newMask >> 7 //use data1's MSB as data2's LSB
        let bytes:[UInt8] = [DIGITAL_MESSAGE,data1,data2]
        let receivedData:NSData = NSData(bytes: bytes, length: 3)
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedPort, 0, "Received Port wrong")
        XCTAssertEqual(mock.receivedPortData, [0,0,0,0,1,0,0,0], "Received PortData wrong")
    }
    
    func testReceiveFirmware(){
        //Given
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
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedString, name + " \(23)." + "\(2)", "Received Port wrong")
    }
    
    func testReceiveStringData(){
        //Given
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
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.receivedString, name , "Received Port wrong")
    }
    
    func testReceiveAnalogMapping(){
        //Given
        let count = 4 / sizeof(UInt8)
        var bytes = [UInt8](count: count, repeatedValue: 0)
        bytes[0] = 0
        bytes[1] = 1
        bytes[2] = 2
        bytes[3] = 3
        let bytestoSend:[UInt8] = [START_SYSEX,ANALOG_MAPPING_RESPONSE,bytes[0],bytes[1],bytes[2],bytes[3],END_SYSEX]
        let receivedData:NSData = NSData(bytes: bytestoSend, length:7)
        
        let givenMapping = NSMutableDictionary(objects: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)], forKeys: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)])
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.analogMapping, givenMapping , "Received Port wrong")
    }
    
    func testReceiveCapabilityQuery(){
        //Given
        let bytestoSend:[UInt8] = [START_SYSEX,CAPABILITY_RESPONSE,0,1,3,1,127,2,2,127,3,0,127,END_SYSEX]
        let receivedData:NSData = NSData(bytes: bytestoSend, length:14)
        var pin1 : [Int:Int] = [Int:Int]()
        pin1[0] = 1
        pin1[3] = 1
        let pin2 : [Int:Int] = [2:2]
        let pin3 : [Int:Int] = [3:0]
        let givenResponse = [pin1,pin2,pin3]
        //When
        mock.testfirmata.receiveData(receivedData)
        //Then
        XCTAssertTrue(mock.callbackInvolved, "Callback not called")
        XCTAssertEqual(mock.capabilityQuery, givenResponse , "Received Port wrong")
    }
}

