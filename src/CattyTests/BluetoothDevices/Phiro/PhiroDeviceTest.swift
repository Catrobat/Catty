/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

import BluetoothHelper
import CoreBluetooth
@testable import Pocket_Code
import XCTest

class PhiroDeviceTest: XCTestCase {

    var device = PhiroDevice(peripheral: Peripheral(cbPeripheral: PeripheralMock(test: true), advertisements: [String: String](), rssi: 0))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        device.firmata = FirmataMock()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        device.toneTimer.invalidate()
        super.tearDown()
    }

    func fakePhiroHelper() {
        device.phiroHelper.didReceiveAnalogMessage(0, value: 0)
        device.phiroHelper.didReceiveAnalogMessage(1, value: 10)
        device.phiroHelper.didReceiveAnalogMessage(2, value: 20)
        device.phiroHelper.didReceiveAnalogMessage(3, value: 30)
        device.phiroHelper.didReceiveAnalogMessage(4, value: 50)
        device.phiroHelper.didReceiveAnalogMessage(5, value: 200)
    }

    // MARK: Motor tests
    func testMoveMotorLeftForward10() {
        //When
        device.moveLeftMotorForward(10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25, "PinValue is wrong")

    }
    func testMoveMotorLeftForward260() {
        //When
        device.moveLeftMotorForward(260)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")

    }
    func testMoveMotorLeftForwardMinus10() {
        //When
        device.moveLeftMotorForward(-10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 11, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")

    }

    func testMoveMotorLeftBackward10() {
        //When
        device.moveLeftMotorBackward(10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25, "PinValue is wrong")

    }
    func testMoveMotorLeftBackward260() {
        //When
        device.moveLeftMotorBackward(260)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")

    }
    func testMoveMotorLeftBackwardMinus10() {
        //When
        device.moveLeftMotorBackward(-10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")

    }

    func testMoveMotorRightForward10() {
        //When
        device.moveRightMotorForward(10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25, "PinValue is wrong")

    }
    func testMoveMotorRightForward260() {
        //When
        device.moveRightMotorForward(260)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")

    }
    func testMoveMotorRightForwardMinus10() {
        //When
        device.moveRightMotorForward(-10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 12, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")

    }

    func testMoveMotorRightBackward10() {
        //When
        device.moveRightMotorBackward(10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 25, "PinValue is wrong")

    }
    func testMoveMotorRightBackward260() {
        //When
        device.moveRightMotorBackward(260)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")

    }
    func testMoveMotorRightBackwardMinus10() {
        //When
        device.moveRightMotorBackward(-10)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")

    }

    func testStopLeftMotor () {
        //When
        device.stopLeftMotor()
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 10, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }

    func testStopRightMotor () {
        //When
        device.stopRightMotor()
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }

    func testStopMotors () {
        //When
        device.stopAllMotors()
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 13, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }

    // MARK: light tests

    func testLightLeftOFF () {
        //When
        device.setLeftRGBLightColor(0, green: 0, blue: 0)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }

    func testLightRightOFF () {
        //When
        device.setRightRGBLightColor(0, green: 0, blue: 0)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }
    func testLightLeft () {
        //When
        device.setLeftRGBLightColor(50, green: 50, blue: 50)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 50, "PinValue is wrong")
    }

    func testLightRight () {
        //When
        device.setRightRGBLightColor(50, green: 50, blue: 50)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 50, "PinValue is wrong")
    }
    func testLightLeftWrongInput () {
        //When
        device.setLeftRGBLightColor(350, green: 350, blue: 350)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 6, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")
    }

    func testLightRightWrongInput () {
        //When
        device.setRightRGBLightColor(350, green: 350, blue: 350)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 9, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")
    }
    // MARK: TONE tests
    func testPlayTone () {
        //When
        device.playTone(450, duration: 2.0)
        device.toneTimer.invalidate()
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 255, "PinValue is wrong")
    }

    // MARK: Reset test
    func testPhiroReset () {
        //When
        device.resetPins()
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPin, 3, "Pin is wrong")
        XCTAssertEqual(firmataMock.receivedPinMode, .pwm, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedValue, 0, "PinValue is wrong")
    }

    // MARK: Sensor reporting
    func testReportSensors() {
        //When
        device.reportSensorData(true)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, .input, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, true, "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5, "Reporting is wrong")
    }

    func testStopReportSensors() {
        //Given
        device.reportSensorData(true)
        //When
        device.reportSensorData(false)
        //Then
        guard let firmataMock = device.firmata as? FirmataMock else {
            XCTAssert(true)
            return
        }
        XCTAssertEqual(firmataMock.receivedPinMode, .input, "PinMode is wrong")
        XCTAssertEqual(firmataMock.receivedBool, false, "Reporting is wrong")
        XCTAssertEqual(firmataMock.receivedPin, 5, "Pin is wrong")
    }

    // MARK: get SensorValues

    func testGetPhiroSensor0 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(0)
        //Then
        XCTAssertEqual(sensorValue, 0, "SensorValue is wrong")
    }
    func testGetPhiroSensor1 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(1)
        //Then
        XCTAssertEqual(sensorValue, 10, "SensorValue is wrong")
    }
    func testGetPhiroSensor2 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(2)
        //Then
        XCTAssertEqual(sensorValue, 20, "SensorValue is wrong")
    }
    func testGetPhiroSensor3 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(3)
        //Then
        XCTAssertEqual(sensorValue, 30, "SensorValue is wrong")
    }
    func testGetPhiroSensor4 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(4)
        //Then
        XCTAssertEqual(sensorValue, 50, "SensorValue is wrong")
    }
    func testGetPhiroSensor5 () {
        //Given
        fakePhiroHelper()
        //When
        let sensorValue = device.getSensorValue(5)
        //Then
        XCTAssertEqual(sensorValue, 200, "SensorValue is wrong")
    }
}
