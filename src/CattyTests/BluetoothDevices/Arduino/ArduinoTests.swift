/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
import CoreBluetooth
import BluetoothHelper
@testable import Pocket_Code

class ArduinoTests: XCTestCase {
    
    var mock = ArduinoTestMock()
    var arduinoTest = ArduinoDevice(peripheral: Peripheral(cbPeripheral:PeripheralMock(test: true), advertisements:[String:String](), rssi: 0))
    
    override func setUp( ) {
        super.setUp()
        mock = ArduinoTestMock()
        setPinsArray()
        arduinoTest.firmata = FirmataMock()
    }
    
    func setPinsArray() {
        var pinArray = [[String:Any]]()
        /////
        // Pin 0 Digital - > .Output
        // Pin 1 Digital - > .PWM
        // Pin 2 Digital - > .Input
        // Pin 3 Digital - > .Input & .Output
        // Pin 4 Analog  - > .Input
        // Pin 5 Analog  - > .Analog
        /////
        var pin0 : [Int:Int] = [Int:Int]()
        pin0[1] = 1
        let pin1 : [Int:Int] = [3:3]
        let pin2 : [Int:Int] = [0:0]
        var pin3 : [Int:Int] = [Int:Int]()
        pin3[0] = 0
        pin3[1] = 1
        let pin4 : [Int:Int] = [0:0]
        let pin5 : [Int:Int] = [2:2]
        let pins = [pin0,pin1,pin2,pin3,pin4,pin5]
        var k = 0;
        for (var i = 0; i < 6 ; i++)
        {
            let modes:[Int:Int] = pins[i]
            
            var pin:[String:Any] = [String:Any]()
            
            if(i<5){
                pin["name"] = "D\(i)"
            }else{
                pin["name"] = "A\(k)"
                k++
            }
            pin["modes"] = modes
            pin["firmatapin"] = i
            pinArray.append(pin)
        }
        mock.pinsArray = pinArray
    }
    
    func fakeArduinoHelper() {
        mock.arduinoHelper.didReceiveAnalogMessage(0, value: 0)
        mock.arduinoHelper.didReceiveAnalogMessage(1, value: 10)
        mock.arduinoHelper.didReceiveAnalogMessage(2, value: 20)
        mock.arduinoHelper.didReceiveAnalogMessage(3, value: 30)
        mock.arduinoHelper.didReceiveAnalogMessage(4, value: 50)
        mock.arduinoHelper.didReceiveAnalogMessage(5, value: 200)
        mock.arduinoHelper.didReceiveDigitalPort(0, portData: [0,1,200,0,1,1,1,0])
        mock.arduinoHelper.didReceiveDigitalMessage(0, value: 0)
        mock.arduinoHelper.didReceiveDigitalMessage(1, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(2, value: 200)
        mock.arduinoHelper.didReceiveDigitalMessage(3, value: 0)
        mock.arduinoHelper.didReceiveDigitalMessage(4, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(5, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(6, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(1, value: 0)
        mock.arduinoHelper.didReceiveDigitalPort(1, portData: [1,0,1,0,1,0,1,0])
        mock.arduinoHelper.didReceiveDigitalMessage(8, value: 0)
        mock.arduinoHelper.didReceiveDigitalMessage(9, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(10, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(11, value: 0)
        mock.arduinoHelper.didReceiveDigitalMessage(12, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(13, value: 0)
        mock.arduinoHelper.didReceiveDigitalMessage(14, value: 1)
        mock.arduinoHelper.didReceiveDigitalMessage(15, value: 0)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(0, value: 0)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(1, value: 10)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(2, value: 20)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(3, value: 30)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(4, value: 50)
        arduinoTest.arduinoHelper.didReceiveAnalogMessage(5, value: 200)
        arduinoTest.arduinoHelper.didReceiveDigitalPort(0, portData: [0,1,200,0,1,1,1,0])
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(0, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(1, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(2, value: 200)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(3, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(4, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(5, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(6, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(1, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalPort(1, portData: [1,0,1,0,1,0,1,0])
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(8, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(9, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(10, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(11, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(12, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(13, value: 0)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(14, value: 1)
        arduinoTest.arduinoHelper.didReceiveDigitalMessage(15, value: 0)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: ArduinoProtocolTests
    //digitalPin
    func testSetDigitalPin4To1() {
        //Given
        let pin = 4
        let value = 1
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    func testSetDigitalPin4To0() {
        //Given
        let pin = 4
        let value = 0
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    func testSetDigitalPin4To5() {
        //Given
        let pin = 4
        let value = 5
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    func testSetDigitalPin4ToMinus3() {
        //Given
        let pin = 4
        let value = -3
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    // pwm pin
    func testSetPWMPin3To25() {
        //Given
        let pin = 3
        let value = 25
        //When
        arduinoTest.setPWMArduinoPin(pin, value: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin],value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, UInt8(value),"PinValue is wrong")
    }
    func testSetPWMPin3ToMinus20() {
        //Given
        let pin = 3
        let value = -20
        //When
        arduinoTest.setPWMArduinoPin(pin, value: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin],0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0,"PinValue is wrong")
    }
    
    func testSetPWMPin3To278() {
        //Given
        let pin = 3
        let value = 278
        //When
        arduinoTest.setPWMArduinoPin(pin, value: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin],255 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255,"PinValue is wrong")
    }
    
    //check mapping
    func testSetDigitalPin0WithMapping (){
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 0
        let value = 1
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    
    func testSetDigitalPin1WithMapping (){
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 1
        let value = 1
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        //not called -> initial values
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Unknown , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    
    func testSetDigitalPin2WithMapping (){
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 2
        let value = 34
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        //not called -> initial values
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Unknown , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    
    func testSetDigitalPin3WithMapping (){
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 3
        let value = 1
        //When
        arduinoTest.setDigitalArduinoPin(pin, pinValue: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    
    func testSetPWMPin1WithMapping () {
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 1
        let value = 1
        //When
        arduinoTest.setPWMArduinoPin(pin, value: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], value , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin,UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, UInt8(value),"PinValue is wrong")
    }
    
    func testSetPWMPin2WithMapping () {
        //Given
        arduinoTest.pinsArray = mock.pinsArray
        let pin = 2
        let value = 25
        //When
        arduinoTest.setPWMArduinoPin(pin, value: value)
        //Then
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[pin], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Unknown , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0,"PinValue is wrong")
    }
    
    //Test ArduinoProtocol getter
    
    func testGetDigitalArduinoPin0 () {
        //Given
        fakeArduinoHelper()
        let pin = 0
        //When
        let value = arduinoTest.getDigitalArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(5) , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[pin], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[0][pin], "Value is wrong")
    }
    
    func testGetDigitalArduinoPin4 () {
        //Given
        fakeArduinoHelper()
        let pin = 4
        //When
        let value = arduinoTest.getDigitalArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(5) , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[pin], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[0][pin], "Value is wrong")
    }
    
    func testGetDigitalArduinoPin12 () {
        //Given
        fakeArduinoHelper()
        let pin = 12
        //When
        let value = arduinoTest.getDigitalArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(5) , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[pin], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[1][4], "Value is wrong")
    }
    
    func testGetAnalogArduinoPin0 () {
        //Given
        fakeArduinoHelper()
        let pin = 0
        //When
        let value = arduinoTest.getAnalogArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin0, "Value is wrong")
    }
    
    func testGetAnalogArduinoPin4 () {
        //Given
        fakeArduinoHelper()
        let pin = 4
        //When
        let value = arduinoTest.getAnalogArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin4, "Value is wrong")
    }
    
    func testGetAnalogArduinoPin7 () {
        //Given
        fakeArduinoHelper()
        let pin = 7
        //When
        let value = arduinoTest.getAnalogArduinoPin(pin)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, UInt8(pin) , "Pin is wrong")
        XCTAssertEqual(Int(value), 0, "Value is wrong")

    }
    func testGetAnalogPin0 () {
        //Given
        fakeArduinoHelper()
        //When
        let value = arduinoTest.getAnalogPin(0)
        //Then
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin0, "Value is wrong")
    }
    
    func testGetAnalogPin4 () {
        //Given
        fakeArduinoHelper()
        //When
        let value = arduinoTest.getAnalogPin(4)
        //Then
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin4, "Value is wrong")
    }
    
    func testGetAnalogPin7 () {
        //Given
        fakeArduinoHelper()
        //When
        let value = arduinoTest.getAnalogPin(7)
        //Then
        XCTAssertEqual(Int(value), 0, "Value is wrong")
    }
    
    func testReportAnalog () {
        //When
        arduinoTest.reportSensorData(true)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedBool, true , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Reporting is wrong")
    }
    
    func testStopReportAnalog () {
        //Given
        arduinoTest.reportSensorData(true)
        //When
        arduinoTest.reportSensorData(false)
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Pin is wrong")
    }
    
    func testResetArduino () {
        //When
        arduinoTest.resetArduino()
        //Then
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
        //Last Pin set to 0
        XCTAssertEqual(firmataMock.receivedPin, 11 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "Value is wrong")
    }
    
    func testDidUpdateCapability () {
        //Given
        
        /////
        // Pin 0 Digital - > .Output
        // Pin 1 Digital - > .PWM
        // Pin 2 Digital - > .Input
        // Pin 3 Digital - > .Input & .Output
        // Pin 4 Analog  - > .Input
        // Pin 5 Analog  - > .Analog
        /////
        var pin0 : [Int:Int] = [Int:Int]()
        pin0[1] = 1
        let pin1 : [Int:Int] = [3:3]
        let pin2 : [Int:Int] = [0:0]
        var pin3 : [Int:Int] = [Int:Int]()
        pin3[0] = 0
        pin3[1] = 1
        let pin4 : [Int:Int] = [0:0]
        let pin5 : [Int:Int] = [2:2]
        let pins = [pin0,pin1,pin2,pin3,pin4,pin5]
        let analogMapping = NSMutableDictionary()
        analogMapping["test"] = "test"
        analogMapping["test"] = "test"
        arduinoTest.analogMapping = analogMapping
        
        //When
        arduinoTest.didUpdateCapability(pins)
        
        //Then
        var i = 0
        for _ in arduinoTest.pinsArray {
            let arduinoTestPin = arduinoTest.pinsArray[i]
            let mockTestPin = mock.pinsArray[i]
            i++;
            XCTAssertEqual(arduinoTestPin["name"] as? String, mockTestPin["name"] as? String, "Capability-name is wrong")
            XCTAssertEqual(arduinoTestPin["firmatapin"] as? Int, mockTestPin["firmatapin"] as? Int, "Capability-firmataPin is wrong")
            XCTAssertEqual((arduinoTestPin["modes"] as? [Int:Int])!, (mockTestPin["modes"] as? [Int:Int])!, "Capability-mode is wrong")
        }
    }
    
    //MARK: FirmataDevice Sending
    
    func testFirmataDeviceSending () {
        //Given
        let name = "test"
        let data = name.dataUsingEncoding(NSASCIIStringEncoding)
        arduinoTest.txCharacteristic = CharacteristicMock(test: true)
        //When
        arduinoTest.sendData(data!)
        //Then
        guard let peripheralMock = arduinoTest.cbPeripheral as? PeripheralMock else {
            XCTAssert(true)
            return
        }

        XCTAssertEqual(peripheralMock.dataToSend,data,"Data is wrong")
    }
    
    func testFirmataDeviceSending2 () {
        //Given
        let name = "testtesttesttesttesttest"
        let data = name.dataUsingEncoding(NSASCIIStringEncoding)
        arduinoTest.txCharacteristic = CharacteristicMock(test: true)
        //When
        arduinoTest.sendData(data!)
        //Then
        guard let peripheralMock = arduinoTest.cbPeripheral as? PeripheralMock else {
            XCTAssert(true)
            return
        }
        let checkName = "test"
        let checkData = checkName.dataUsingEncoding(NSASCIIStringEncoding)
        XCTAssertEqual(peripheralMock.dataToSend,checkData,"Data is wrong")
    }
    
    //MARK: FirmataDevice Convert Analog
    func testFirmataDeviceConvertAnalog0 () {
        //Given
        let analogPin = 14
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,0,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalog1 () {
        //Given
        let analogPin = 15
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,1,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalog2 () {
        //Given
        let analogPin = 16
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,2,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalog3 () {
        //Given
        let analogPin = 17
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,3,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalog4 () {
        //Given
        let analogPin = 18
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,4,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalog5 () {
        //Given
        let analogPin = 19
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,5,"Convertion is wrong")
    }
    func testFirmataDeviceConvertAnalogWrong () {
        //Given
        let analogPin = 25
        //When
        let check = arduinoTest.convertAnalogPin(analogPin)
        //Then
        XCTAssertEqual(check,100,"Convertion is wrong")
    }
}
