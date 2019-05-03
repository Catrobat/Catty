/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
import Foundation

@objc
class PhiroDevice: FirmataDevice, PhiroProtocol {
    public static let pinSensorSideRight: Int = 0
    public static let pinSensorFrontRight: Int = 1
    public static let pinSensorBottomRight: Int = 2
    public static let pinSensorBottomLeft: Int = 3
    public static let pinSensorFrontLeft: Int = 4
    public static let pinSensorSideLeft: Int = 5

    private let PHIRO_UUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB")
    private static let tag: String = "Phiro"

    private let pinSpeakerOut: Int = 3

    private let pinRGBRedLeft: Int = 4
    private let pinRGBGreenLeft: Int = 5
    private let pinRGBBlueLeft: Int = 6

    private let pinRGBRedRight: Int = 7
    private let pinRGBGreenRight: Int = 8
    private let pinRGBBlueRight: Int = 9

    private let pinLeftMotorBackward: Int = 10
    private let pinLeftMotorForward: Int = 11

    private let pinRightMotorForward: Int = 12
    private let pinRightMotorBackward: Int = 13

    private let minPWMPin: Int = 3
    private let maxPWMPin: Int = 13

    private let minSensorPin: Int = 0
    private let maxSensorPin: Int = 5

    override var rxUUID: CBUUID { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") }
    override var txUUID: CBUUID { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") }

    internal let phiroHelper = PhiroHelper()
    internal var toneTimer = Timer()
    private var isReportingSensorData = false

    // MARK: override

    override internal func getName() -> String {
        return "Phiro"
    }

    override internal func getBluetoothDeviceUUID() -> CBUUID {
        return PHIRO_UUID
    }
    // MARK: Phiro Protocol

    func playTone(_ toneFrequency: NSInteger, duration: Double) {
        self.sendAnalogFirmataMessage(pinSpeakerOut, value: toneFrequency)
        if toneTimer.isValid {
            toneTimer.invalidate()
        }
        toneTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(PhiroDevice.cancelTone), userInfo: nil, repeats: false)
    }

    func moveLeftMotorForward(_ speed: Int) {
        self.sendAnalogFirmataMessage(pinLeftMotorForward, value: self.percentToSpeed(speed))
    }

    func moveLeftMotorBackward(_ speed: Int) {
        self.sendAnalogFirmataMessage(pinLeftMotorBackward, value: self.percentToSpeed(speed))
    }

    func moveRightMotorForward(_ speed: Int) {
        self.sendAnalogFirmataMessage(pinRightMotorForward, value: self.percentToSpeed(speed))
    }

    func moveRightMotorBackward(_ speed: Int) {
        self.sendAnalogFirmataMessage(pinRightMotorBackward, value: self.percentToSpeed(speed))
    }

    func stopLeftMotor() {
        self.moveLeftMotorForward(0)
        self.moveLeftMotorBackward(0)
    }

    func stopRightMotor() {
        self.moveRightMotorForward(0)
        self.moveRightMotorBackward(0)
    }

    func stopAllMotors() {
        self.stopLeftMotor()
        self.stopRightMotor()
    }

    func setLeftRGBLightColor(_ red: Int, green: Int, blue: Int) {
        let redChecked = checkValue(red)
        let greenChecked = checkValue(green)
        let blueChecked = checkValue(blue)

        self.sendAnalogFirmataMessage(pinRGBRedLeft, value: redChecked)
        self.sendAnalogFirmataMessage(pinRGBGreenLeft, value: greenChecked)
        self.sendAnalogFirmataMessage(pinRGBBlueLeft, value: blueChecked)
    }

    func setRightRGBLightColor(_ red: Int, green: Int, blue: Int) {
        let redChecked = checkValue(red)
        let greenChecked = checkValue(green)
        let blueChecked = checkValue(blue)

        self.sendAnalogFirmataMessage(pinRGBRedRight, value: redChecked)
        self.sendAnalogFirmataMessage(pinRGBGreenRight, value: greenChecked)
        self.sendAnalogFirmataMessage(pinRGBBlueRight, value: blueChecked)
    }

    // MARK: Helper
    @objc private func cancelTone() {
        self.sendAnalogFirmataMessage(pinSpeakerOut, value: 0)
        self.toneTimer.invalidate()
        self.toneTimer = Timer()
    }

    private func percentToSpeed(_ percent: Int) -> Int {
        if percent <= 0 {
            return 0
        }
        if percent >= 100 {
            return 255
        }

        return (Int) (Double(percent) * 2.55)
    }

    private func sendAnalogFirmataMessage(_ pin: Int, value: Int) {
        let analogPin = UInt8(checkValue(pin))
        let checkedValue = UInt8(checkValue(value))
        firmata.writePinMode(.pwm, pin: analogPin)
        firmata.writePWMValue(checkedValue, pin: analogPin)
    }

    // MARK: Reset Phiro
    func resetPins() {
        stopAllMotors()
        setLeftRGBLightColor(0, green: 0, blue: 0)
        setRightRGBLightColor(0, green: 0, blue: 0)
        cancelTone()
    }

    // MARK: Report Data
    @objc func reportSensorData(_ report: Bool) {
        if isReportingSensorData == report {
            return
        }

        isReportingSensorData = report

        for i in minSensorPin ... maxSensorPin {
            reportAnalogArduinoPin(i, report: report)
        }
    }
    private func reportAnalogArduinoPin(_ analogPinNumber: Int, report: Bool) {
        let pin = UInt8(checkValue(analogPinNumber))
        self.firmata.writePinMode(.input, pin: pin)
        self.firmata.setAnalogValueReportingforPin(pin, enabled: report)
    }

    // MARK: getter
    @objc func getSensorValue(_ pinNumber: Int) -> Double {
        let value = getAnalogPin(pinNumber)
        return Double(value)
    }

    private func getAnalogPin(_ pinNumber: Int) -> Double {
        if pinNumber == type(of: self).pinSensorFrontLeft {
            return Double(getFrontLeftSensor())
        }
        if pinNumber == type(of: self).pinSensorFrontRight {
            return Double(getFrontRightSensor())
        }
        if pinNumber == type(of: self).pinSensorSideLeft {
            return Double(getSideLeftSensor())
        }
        if pinNumber == type(of: self).pinSensorSideRight {
            return Double(getSideRightSensor())
        }
        if pinNumber == type(of: self).pinSensorBottomLeft {
            return Double(getBottomLeftSensor())
        }
        if pinNumber == type(of: self).pinSensorBottomRight {
            return Double(getBottomRightSensor())
        }
        return 0
    }

    // MARK: Sensor Values

    private func getFrontLeftSensor() -> Int {
        return phiroHelper.frontLeftSensor
    }

    private func getFrontRightSensor() -> Int {
        return phiroHelper.frontRightSensor
    }

    private func getSideLeftSensor() -> Int {
        return phiroHelper.sideLeftSensor
    }

    private func getSideRightSensor() -> Int {
        return phiroHelper.sideRightSensor
    }

    private func getBottomLeftSensor() -> Int {
        return phiroHelper.bottomLeftSensor
    }

    private func getBottomRightSensor() -> Int {
        return phiroHelper.bottomRightSensor
    }

    // MARK: Firmata Delegate override
    override func didReceiveAnalogMessage(_ pin: Int, value: Int) {
        print("ANALOG::\(pin):::\(value)")
        let analogPin = convertAnalogPin(pin)

        phiroHelper.didReceiveAnalogMessage(analogPin, value: value)
    }

}
