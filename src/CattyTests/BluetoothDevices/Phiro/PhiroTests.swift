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
class PhiroTests: XCTestCase {
    
    var phiroTest = Phiro(peripheral: Peripheral(cbPeripheral:peripheralMock(test: true), advertisements:[String:String](), rssi: 0))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        phiroTest.firmata = FirmataMock()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func fakePhiroHelper() {
        phiroTest.phiroHelper.didReceiveAnalogMessage(0, value: 0)
        phiroTest.phiroHelper.didReceiveAnalogMessage(1, value: 10)
        phiroTest.phiroHelper.didReceiveAnalogMessage(2, value: 20)
        phiroTest.phiroHelper.didReceiveAnalogMessage(3, value: 30)
        phiroTest.phiroHelper.didReceiveAnalogMessage(4, value: 50)
        phiroTest.phiroHelper.didReceiveAnalogMessage(5, value: 200)
    }
    
    

    //MARK: Motor tests
    func testMoveMotorLeftForward10() {
        phiroTest.moveLeftMotorForward(10)
//        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25 , "PinValue is wrong")

    }
    func testMoveMotorLeftForward260() {
        phiroTest.moveLeftMotorForward(260)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
        
    }
    func testMoveMotorLeftForwardMinus10() {
        phiroTest.moveLeftMotorForward(-10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
        
    }
    
    func testMoveMotorLeftBackward10() {
        phiroTest.moveLeftMotorBackward(10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25 , "PinValue is wrong")
        
    }
    func testMoveMotorLeftBackward260() {
        phiroTest.moveLeftMotorBackward(260)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
        
    }
    func testMoveMotorLeftBackwardMinus10() {
        phiroTest.moveLeftMotorBackward(-10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
        
    }
    
    func testMoveMotorRightForward10() {
        phiroTest.moveRightMotorForward(10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25 , "PinValue is wrong")
        
    }
    func testMoveMotorRightForward260() {
        phiroTest.moveRightMotorForward(260)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
        
    }
    func testMoveMotorRightForwardMinus10() {
        phiroTest.moveRightMotorForward(-10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
        
    }
    
    func testMoveMotorRightBackward10() {
        phiroTest.moveRightMotorBackward(10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25 , "PinValue is wrong")
        
    }
    func testMoveMotorRightBackward260() {
        phiroTest.moveRightMotorBackward(260)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
        
    }
    func testMoveMotorRightBackwardMinus10() {
        phiroTest.moveRightMotorBackward(-10)
        //        XCTAssertEqual(phiroTest.phiroHelper , 1 , "Pin is wrong")
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
        
    }
    
    func testStopLeftMotor () {
        phiroTest.stopLeftMotor()
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    
    func testStopRightMotor () {
        phiroTest.stopRightMotor()
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    
    func testStopMotors () {
        phiroTest.stopAllMotors()
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    
    //MARK: light tests
    
    func testLightLeftOFF () {
        phiroTest.setLeftRGBLightColor(0, green: 0, blue: 0)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    
    func testLightRightOFF () {
        phiroTest.setRightRGBLightColor(0, green: 0, blue: 0)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    func testLightLeft () {
        phiroTest.setLeftRGBLightColor(50, green: 50, blue: 50)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 50 , "PinValue is wrong")
    }
    
    func testLightRight () {
        phiroTest.setRightRGBLightColor(50, green: 50, blue: 50)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 50 , "PinValue is wrong")
    }
    func testLightLeftWrongInput () {
        phiroTest.setLeftRGBLightColor(350, green: 350, blue: 350)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
    }
    
    func testLightRightWrongInput () {
        phiroTest.setRightRGBLightColor(350, green: 350, blue: 350)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
    }
    //MARK: TONE tests
    func testPlayTone () {
        phiroTest.playTone(450, duration: 2.0)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255 , "PinValue is wrong")
    }
    
    //MARK: Reset test
    func testPhiroReset () {
        phiroTest.resetPins()
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3 , "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.PWM , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0 , "PinValue is wrong")
    }
    
    //MARK: Sensor reporting
    func testReportSensors() {
        phiroTest.reportSensorData(true)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Input , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, true , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Reporting is wrong")
    }
    
    func testStopReportSensors() {
        phiroTest.reportSensorData(true)
        phiroTest.reportSensorData(false)
        guard let firmataMock = phiroTest.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, PinMode.Input , "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, false , "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5 , "Pin is wrong")
    }
    
    //MARK: get SensorValues
    
    func testGetPhiroSensor0 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(0)
        XCTAssertEqual(sensorValue, 0 , "SensorValue is wrong")
    }
    func testGetPhiroSensor1 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(1)
        XCTAssertEqual(sensorValue, 10 , "SensorValue is wrong")
    }
    func testGetPhiroSensor2 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(2)
        XCTAssertEqual(sensorValue,20 , "SensorValue is wrong")
    }
    func testGetPhiroSensor3 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(3)
        XCTAssertEqual(sensorValue, 30 , "SensorValue is wrong")
    }
    func testGetPhiroSensor4 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(4)
        XCTAssertEqual(sensorValue, 50 , "SensorValue is wrong")
    }
    func testGetPhiroSensor5 () {
        fakePhiroHelper()
        let sensorValue = phiroTest.getSensorValue(5)
        XCTAssertEqual(sensorValue, 200 , "SensorValue is wrong")
    }
    

}
