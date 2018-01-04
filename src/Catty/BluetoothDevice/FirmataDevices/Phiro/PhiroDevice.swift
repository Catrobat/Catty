/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

private let PIN_SPEAKER_OUT:Int = 3;

private let PIN_RGB_RED_LEFT:Int = 4;
private let PIN_RGB_GREEN_LEFT:Int = 5;
private let PIN_RGB_BLUE_LEFT:Int = 6;

private let PIN_RGB_RED_RIGHT:Int = 7;
private let PIN_RGB_GREEN_RIGHT:Int = 8;
private let PIN_RGB_BLUE_RIGHT:Int = 9;

private let PIN_LEFT_MOTOR_BACKWARD:Int = 10;
private let PIN_LEFT_MOTOR_FORWARD:Int = 11;

private let PIN_RIGHT_MOTOR_FORWARD:Int = 12;
private let PIN_RIGHT_MOTOR_BACKWARD:Int = 13;

private let MIN_PWM_PIN:Int = 3;
private let MAX_PWM_PIN:Int = 13;

public let PIN_SENSOR_SIDE_RIGHT:Int = 0;
public let PIN_SENSOR_FRONT_RIGHT:Int = 1;
public let PIN_SENSOR_BOTTOM_RIGHT:Int = 2;
public let PIN_SENSOR_BOTTOM_LEFT:Int = 3;
public let PIN_SENSOR_FRONT_LEFT:Int = 4;
public let PIN_SENSOR_SIDE_LEFT:Int = 5;

private let MIN_SENSOR_PIN:Int = 0;
private let MAX_SENSOR_PIN:Int = 5;

@objc
class Phiro: FirmataDevice,PhiroProtocol {
    private let PHIRO_UUID:CBUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB")
    private static let tag:String = "Phiro";
    
    override var rxUUID: CBUUID { get { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") } }
    override var txUUID: CBUUID { get { return CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") } }
    
    internal let phiroHelper:PhiroHelper = PhiroHelper()
    internal var toneTimer:Timer = Timer()
    private var isReportingSensorData = false
    
    // MARK: override
    
    override internal func getName() -> String{
        return "Phiro"
    }
    
    override internal func getBluetoothDeviceUUID()->CBUUID{
        return PHIRO_UUID
    }
    //MARK: Phiro Protocol
    
    func playTone(_ toneFrequency:NSInteger,duration:Double){
        self.sendAnalogFirmataMessage(PIN_SPEAKER_OUT, value: toneFrequency)
        if toneTimer.isValid {
            toneTimer.invalidate()
        }
        toneTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(Phiro.cancelTone), userInfo: nil, repeats: false)
    }
    

    
    func moveLeftMotorForward(_ speed:Int){
        self.sendAnalogFirmataMessage(PIN_LEFT_MOTOR_FORWARD, value: self.percentToSpeed(speed))
    }
    
    func moveLeftMotorBackward(_ speed:Int){
        self.sendAnalogFirmataMessage(PIN_LEFT_MOTOR_BACKWARD, value: self.percentToSpeed(speed))
    }
    
    func moveRightMotorForward(_ speed:Int){
        self.sendAnalogFirmataMessage(PIN_RIGHT_MOTOR_FORWARD, value: self.percentToSpeed(speed))
    }
    
    func moveRightMotorBackward(_ speed:Int){
        self.sendAnalogFirmataMessage(PIN_RIGHT_MOTOR_BACKWARD, value: self.percentToSpeed(speed))
    }
    
    func stopLeftMotor(){
        self.moveLeftMotorForward(0)
        self.moveLeftMotorBackward(0)
    }
    
    func stopRightMotor(){
        self.moveRightMotorForward(0)
        self.moveRightMotorBackward(0)
    }
    
    func stopAllMotors(){
        self.stopLeftMotor()
        self.stopRightMotor()
    }
    
    func setLeftRGBLightColor(_ red:Int,green:Int,blue:Int){
        let redChecked = checkValue(red)
        let greenChecked = checkValue(green)
        let blueChecked = checkValue(blue)
        
        self.sendAnalogFirmataMessage(PIN_RGB_RED_LEFT, value: redChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_GREEN_LEFT, value: greenChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_BLUE_LEFT, value: blueChecked)
    }
    
    func setRightRGBLightColor(_ red:Int,green:Int,blue:Int){
        let redChecked = checkValue(red)
        let greenChecked = checkValue(green);
        let blueChecked = checkValue(blue);
        
        self.sendAnalogFirmataMessage(PIN_RGB_RED_RIGHT, value: redChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_GREEN_RIGHT, value: greenChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_BLUE_RIGHT, value: blueChecked)
    }
    
    //MARK:Helper
    @objc private func cancelTone(){
        self.sendAnalogFirmataMessage(PIN_SPEAKER_OUT, value:0)
        self.toneTimer.invalidate()
        self.toneTimer = Timer()
    }
    
    private func percentToSpeed(_ percent:Int) -> Int{
        if (percent <= 0) {
            return 0;
        }
        if (percent >= 100) {
            return 255;
        }
        
        return (Int) (Double(percent) * 2.55);
    }
    
    private func sendAnalogFirmataMessage(_ pin:Int,value:Int){
        let analogPin:UInt8 = UInt8(checkValue(pin))
        let checkedValue :UInt8 = UInt8(checkValue(value))
        firmata.writePinMode(.pwm, pin: analogPin)
        firmata.writePWMValue(checkedValue, pin: analogPin)
    }

    //MARK: Reset Phiro
    func resetPins(){
        stopAllMotors()
        setLeftRGBLightColor(0, green: 0, blue: 0)
        setRightRGBLightColor(0, green: 0, blue: 0)
        cancelTone()
    }

    //MARK: Report Data
    @objc func reportSensorData(_ report:Bool) {
        if (isReportingSensorData == report) {
            return;
        }
        
        isReportingSensorData = report;
        
        for i in MIN_SENSOR_PIN ... MAX_SENSOR_PIN {
            reportAnalogArduinoPin(i,report: report)
        }
    }
    private func reportAnalogArduinoPin(_ analogPinNumber:Int,report:Bool) {
        let pin: UInt8 = UInt8(checkValue(analogPinNumber))
        self.firmata.writePinMode(.input, pin: pin)
        self.firmata.setAnalogValueReportingforPin(pin, enabled: report)
    }
    
    //MARK: getter
    @objc func getSensorValue(_ sensor:Int) -> Double{
        let value = getAnalogPin(sensor)
        return Double(value)
    }
    
    private func getAnalogPin(_ analogPinNumber: Int) -> Double {
        switch (analogPinNumber) {
        case PIN_SENSOR_FRONT_LEFT:
            return Double(getFrontLeftSensor())
        case PIN_SENSOR_FRONT_RIGHT:
            return Double(getFrontRightSensor())
        case PIN_SENSOR_SIDE_LEFT:
            return Double(getSideLeftSensor())
        case PIN_SENSOR_SIDE_RIGHT:
            return Double(getSideRightSensor())
        case PIN_SENSOR_BOTTOM_LEFT:
            return Double(getBottomLeftSensor())
        case PIN_SENSOR_BOTTOM_RIGHT:
            return Double(getBottomRightSensor())
        default:
            return 0
        }
    }

    // MARK: Sensor Values
    
    private func getFrontLeftSensor() -> Int {
        return phiroHelper.frontLeftSensor;
    }
    
    private func getFrontRightSensor() -> Int {
        return phiroHelper.frontRightSensor;
    }
    
    private func getSideLeftSensor() -> Int {
        return phiroHelper.sideLeftSensor;
    }
    
    private func getSideRightSensor() -> Int {
        return phiroHelper.sideRightSensor;
    }
    
    private func getBottomLeftSensor() -> Int {
        return phiroHelper.bottomLeftSensor;
    }
    
    private func getBottomRightSensor() -> Int {
        return phiroHelper.bottomRightSensor;
    }
    
    
    //MARK:Firmata Delegate override
    override func didReceiveAnalogMessage(_ pin:Int,value:Int){
        print("ANALOG::\(pin):::\(value)")
        let analogPin = convertAnalogPin(pin)
        
        phiroHelper.didReceiveAnalogMessage(analogPin, value: value)
    }

    
}
