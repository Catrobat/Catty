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

    static var defaultSensor = PhiroFrontLeftSensor.self

    var frontLeftSensor: Int = 0
    var frontRightSensor: Int = 0
    var sideLeftSensor: Int = 0
    var sideRightSensor: Int = 0
    var bottomLeftSensor: Int = 0
    var bottomRightSensor: Int = 0

    func didReceiveAnalogMessage(_ pin: Int, value: Int) {
        switch pin {
        case PhiroDevice.pinSensorSideRight:
            sideRightSensor = value
        case PhiroDevice.pinSensorFrontRight:
            frontRightSensor = value
        case PhiroDevice.pinSensorBottomRight:
            bottomRightSensor = value
        case PhiroDevice.pinSensorBottomLeft:
            bottomLeftSensor = value
        case PhiroDevice.pinSensorFrontLeft:
            frontLeftSensor = value
        case PhiroDevice.pinSensorSideLeft:
            sideLeftSensor = value
        default:
            break //NOT USED SENSOR
        }
    }

    @objc static func sensorTags() -> [String] {
        var tags = [String]()

        for sensor in sensors() {
            tags.append(sensor.tag)
        }

        return tags
    }

    @objc static func defaultTag() -> String {
        return defaultSensor.tag
    }

    @objc static func pinNumber(tag: String) -> Int {
        guard let sensor = sensor(tag: tag) else { return defaultSensor.pinNumber }
        return sensor.pinNumber
    }

    @objc static func tag(pinNumber: Int) -> String {
        guard let sensor = sensor(pinNumber: pinNumber) else { return defaultSensor.tag }
        return sensor.tag
    }

    static func sensor(tag: String) -> PhiroSensor.Type? {
        for sensor in sensors() where (sensor.tag == tag) {
            return sensor
        }
        return nil
    }

    static func sensor(pinNumber: Int) -> PhiroSensor.Type? {
        for sensor in sensors() where (sensor.pinNumber == pinNumber) {
            return sensor
        }
        return nil
    }

    static func sensors() -> [PhiroSensor.Type] {
        return [PhiroSideLeftSensor.self,
                PhiroSideRightSensor.self,
                PhiroFrontLeftSensor.self,
                PhiroFrontRightSensor.self,
                PhiroBottomLeftSensor.self,
                PhiroBottomLeftSensor.self]
    }
}
