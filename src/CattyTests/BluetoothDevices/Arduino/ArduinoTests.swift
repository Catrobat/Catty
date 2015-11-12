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
import CoreBluetooth
import BluetoothHelper
@testable import Pocket_Code

class peripheralMock: CBPeripheral {
    init(test:Bool){
        //HACK
    }
    
    override func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
}

class ArduinoTestMock: ArduinoPropertyProtocol {
    internal var totalPins = 3
    internal var analogMapping = NSMutableDictionary(objects: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)], forKeys: [NSNumber(unsignedChar:0),NSNumber(unsignedChar:1),NSNumber(unsignedChar:2),NSNumber(unsignedChar:3)])
    internal var pinsArray = [[String:Any]]()
    
    internal let arduinoHelper:ArduinoHelper = ArduinoHelper()
}

class ArduinoTests: XCTestCase {
    
    var mock = ArduinoTestMock()
    var arduinoTest = ArduinoDevice(peripheral: Peripheral(cbPeripheral:peripheralMock(test: true), advertisements:[String:String](), rssi: 0))
    
    override func setUp( ) {
        super.setUp()
        mock = ArduinoTestMock()
        setPinsArray()
        arduinoTest.firmata = FirmataMock()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        arduinoTest.setDigitalArduinoPin(4, pinValue: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[4], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    func testSetDigitalPin4To0() {
        arduinoTest.setDigitalArduinoPin(4, pinValue: 0)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[4], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    func testSetDigitalPin4To5() {
        arduinoTest.setDigitalArduinoPin(4, pinValue: 5)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[4], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    func testSetDigitalPin4ToMinus3() {
        arduinoTest.setDigitalArduinoPin(4, pinValue: -3)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[4], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.Low , "PinState is wrong")
    }
    // pwm pin
    func testSetPWMPin3To1() {
        arduinoTest.setPWMArduinoPin(3, value: 25)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[3], 25 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25,"PinValue is wrong")
    }
    func testSetPWMPin3ToMinus20() {
        arduinoTest.setPWMArduinoPin(3, value: -20)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[3], 0 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0,"PinValue is wrong")
    }
    
    func testSetPWMPin3To278() {
        arduinoTest.setPWMArduinoPin(3, value: 278)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[3], 255 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255,"PinValue is wrong")
    }
    
    //check mapping
    func testSetDigitalPin0WithMapping (){
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setDigitalArduinoPin(0, pinValue: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[0], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    
    func testSetDigitalPin1WithMapping (){
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setDigitalArduinoPin(1, pinValue: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[0], 0 , "Pin is wrong")
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
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setDigitalArduinoPin(2, pinValue: 34)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[2], 0 , "Pin is wrong")
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
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setDigitalArduinoPin(3, pinValue: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[3], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Output , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedPinState, PinState.High , "PinState is wrong")
    }
    
    func testSetPWMPin1WithMapping () {
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setPWMArduinoPin(1, value: 1)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[1], 1 , "Pin is wrong")
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 1 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 1,"PinValue is wrong")
    }
    
    func testSetPWMPin2WithMapping () {
        arduinoTest.pinsArray = mock.pinsArray
        arduinoTest.setPWMArduinoPin(2, value: 25)
        XCTAssertEqual(arduinoTest.arduinoHelper.digitalValues[2], 0 , "Pin is wrong")
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
        fakeArduinoHelper()
        let value = arduinoTest.getDigitalArduinoPin(0)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[0], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[0][0], "Value is wrong")
    }
    
    func testGetDigitalArduinoPin4 () {
        fakeArduinoHelper()
        let value = arduinoTest.getDigitalArduinoPin(4)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[4], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[0][4], "Value is wrong")
    }
    
    func testGetDigitalArduinoPin12 () {
        fakeArduinoHelper()
        let value = arduinoTest.getDigitalArduinoPin(12)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12 , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.digitalValues[12], "Value is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.portValues[1][4], "Value is wrong")
    }
    
    func testGetAnalogArduinoPin0 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogArduinoPin(0)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 0 , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin0, "Value is wrong")
    }
    
    func testGetAnalogArduinoPin4 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogArduinoPin(4)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 4 , "Pin is wrong")
        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin4, "Value is wrong")
    }
    
    func testGetAnalogArduinoPin7 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogArduinoPin(7)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 7 , "Pin is wrong")
        XCTAssertEqual(Int(value), 0, "Value is wrong")

    }
    func testGetAnalogPin0 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogPin(0)

        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin0, "Value is wrong")
    }
    
    func testGetAnalogPin4 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogPin(4)

        XCTAssertEqual(Int(value), mock.arduinoHelper.analogPin4, "Value is wrong")
    }
    
    func testGetAnalogPin7 () {
        fakeArduinoHelper()
        let value = arduinoTest.getAnalogPin(7)

        XCTAssertEqual(Int(value), 0, "Value is wrong")
        
    }
    
    func testReportAnalog () {
        arduinoTest.reportSensorData(true)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Input , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, true , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Reporting is wrong")
    }
    
    func testStopReportAnalog () {
        arduinoTest.reportSensorData(true)
        arduinoTest.reportSensorData(false)
        guard let firmataMock = arduinoTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Input , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Pin is wrong")
    }
    
    func testResetArduino () {
        arduinoTest.resetArduino()
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
        arduinoTest.didUpdateCapability(pins)
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
}
