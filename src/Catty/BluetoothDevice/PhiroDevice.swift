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

import Foundation
import CoreBluetooth
import BluetoothHelper


//MARK:PHIRO

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

public class Phiro: ArduinoDevice {
    private let PHIRO_UUID:CBUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB")
    private static let tag:String = "Phiro";
    
    private let rxUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") // TODO
    private let txUUID = CBUUID.init(string: "00001101-0000-1000-8000-00805F9B34FB") // TODO
    
    private let phiroHelper:PhiroHelper = PhiroHelper()
    
    //MARK: actions
    
    public func playTone(toneFrequency:NSInteger,duration:NSInteger){
        //TODO
    }
    
    public func moveLeftMotorForward(speed:Int){
        self.sendAnalogFirmataMessage(PIN_LEFT_MOTOR_FORWARD, value: self.percentToSpeed(speed))
    }
    
    public func moveLeftMotorBackward(speed:Int){
        self.sendAnalogFirmataMessage(PIN_LEFT_MOTOR_BACKWARD, value: self.percentToSpeed(speed))
    }
    
    public func moveRightMotorForward(speed:Int){
        self.sendAnalogFirmataMessage(PIN_RIGHT_MOTOR_FORWARD, value: self.percentToSpeed(speed))
    }
    
    public func moveRightMotorBackward(speed:Int){
        self.sendAnalogFirmataMessage(PIN_RIGHT_MOTOR_FORWARD, value: self.percentToSpeed(speed))
    }
    
    public func stopLeftMotor(){
        self.moveLeftMotorForward(0)
        self.moveLeftMotorBackward(0)
    }
    
    public func stopRightMotor(){
        self.moveRightMotorForward(0)
        self.moveRightMotorBackward(0)
    }
    
    public func stopAllMotors(){
        self.stopLeftMotor()
        self.stopRightMotor()
    }
    
    private func percentToSpeed(percent:Int) -> Int{
        if (percent <= 0) {
            return 0;
        }
        if (percent >= 100) {
            return 255;
        }
        
        return (Int) (Double(percent) * 2.55);
    }
    
    public func setLeftRGBLightColor(red:Int,green:Int,blue:Int){
        let redChecked = self.checkRGBValue(red);
        let greenChecked = self.checkRGBValue(green);
        let blueChecked = self.checkRGBValue(blue);
        
        self.sendAnalogFirmataMessage(PIN_RGB_RED_LEFT, value: redChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_GREEN_LEFT, value: greenChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_BLUE_LEFT, value: blueChecked)
    }
    
    public func setRightRGBLightColor(red:Int,green:Int,blue:Int){
        let redChecked = self.checkRGBValue(red);
        let greenChecked = self.checkRGBValue(green);
        let blueChecked = self.checkRGBValue(blue);
        
        self.sendAnalogFirmataMessage(PIN_RGB_RED_RIGHT, value: redChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_GREEN_RIGHT, value: greenChecked)
        self.sendAnalogFirmataMessage(PIN_RGB_BLUE_RIGHT, value: blueChecked)
    }
    
    private func checkRGBValue(value:Int)->Int{
        if (value > 255) {
            return 255;
        }
        
        if (value < 0) {
            return 0;
        }
        
        return value;
    }

    public func resetPins(){
        stopAllMotors()
        setLeftRGBLightColor(0, green: 0, blue: 0)
        setRightRGBLightColor(0, green: 0, blue: 0)
        playTone(0, duration: 0)
    }
    
    public func getSensorValue(sensor:NSInteger)->NSInteger{
        return 0
    }
    
    public func sendAnalogFirmataMessage(pin:Int,value:Int){
        firmata.writePWMValue(UInt8(value), pin: UInt8(pin))
    }
    

    // MARK: Sensor Values
    
    public func getFrontLeftSensor() -> NSInteger {
        return phiroHelper.frontLeftSensor;
    }
    
    public func getFrontRightSensor() -> NSInteger {
        return phiroHelper.frontRightSensor;
    }
    
    public func getSideLeftSensor() -> NSInteger {
        return phiroHelper.sideLeftSensor;
    }
    
    public func getSideRightSensor() -> NSInteger {
        return phiroHelper.sideRightSensor;
    }
    
    public func getBottomLeftSensor() -> NSInteger {
        return phiroHelper.bottomLeftSensor;
    }
    
    public func getBottomRightSensor() -> NSInteger {
        return phiroHelper.bottomRightSensor;
    }
    
    
    // MARK: override
    
    override public func getName()->NSString{
        return "Phiro"
    }
    
    override public func getBluetoothDeviceUUID()->CBUUID{
        return PHIRO_UUID
    }
    
    override func didReceiveAnalogMessage(pin:Int,value:Int){
        
    }
    
    override func didReceiveDigitalMessage(pin:Int,value:Int){
        // Not used
    }
    
    override func didReceiveDigitalPort(port:Int, portData:[Int]) {
        // Not used
    }
    
    
    
}



class PhiroHelper {
    private var frontLeftSensor = 0;
    private var frontRightSensor = 0;
    private var sideLeftSensor = 0;
    private var sideRightSensor = 0;
    private var bottomLeftSensor = 0;
    private var bottomRightSensor = 0;
    
    
    
    func didReceiveAnalogMessage(pin:Int,value:Int){
        switch (pin) {
        case PIN_SENSOR_SIDE_RIGHT:
            sideRightSensor = value
            break
        case PIN_SENSOR_FRONT_RIGHT:
            frontRightSensor = value
            break
        case PIN_SENSOR_BOTTOM_RIGHT:
            bottomRightSensor = value
            break
        case PIN_SENSOR_BOTTOM_LEFT:
            bottomLeftSensor = value
            break
        case PIN_SENSOR_FRONT_LEFT:
            frontLeftSensor = value
            break
        case PIN_SENSOR_SIDE_LEFT:
            sideLeftSensor = value
            break
            
        default: break
            //NOT USED SENSOR
        }
        
    }
}