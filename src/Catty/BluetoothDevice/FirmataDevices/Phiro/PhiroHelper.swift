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

@objc class PhiroHelper: NSObject {
    var frontLeftSensor:Int = 0;
    var frontRightSensor:Int = 0;
    var sideLeftSensor:Int = 0;
    var sideRightSensor:Int = 0;
    var bottomLeftSensor:Int = 0;
    var bottomRightSensor:Int = 0;
    
    func didReceiveAnalogMessage(_ pin:Int,value:Int){
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
    
    @objc static func sensorTags() -> [String] {
        var tags = [String]()
        
        for sensor in CBSensorManager.shared.phiroSensors() {
            tags.append(type(of: sensor).tag)
        }
        
        return tags
    }
    
    @objc static func defaultTag() -> String {
        return self.defaultSensor().tag
    }
    
    @objc static func pinNumber(tag: String) -> Int {
        guard let sensor = sensor(tag: tag) else { return defaultSensor().pinNumber }
        return type(of: sensor).pinNumber
    }
    
    @objc static func tag(pinNumber: Int) -> String {
        guard let sensor = sensor(pinNumber: pinNumber) else { return defaultSensor().tag }
        return type(of: sensor).tag
    }
    
    static func sensor(tag: String) -> PhiroSensor? {
        for sensor in CBSensorManager.shared.phiroSensors() {
            if type(of: sensor).tag == tag {
                return sensor
            }
        }
        return nil
    }
    
    static func sensor(pinNumber: Int) -> PhiroSensor? {
        for sensor in CBSensorManager.shared.phiroSensors() {
            if type(of: sensor).pinNumber == pinNumber {
                return sensor
            }
        }
        return nil
    }
    
    static func defaultSensor() -> PhiroSensor.Type {
        return PhiroFrontLeftSensor.self
    }
}
