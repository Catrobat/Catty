/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

import CoreLocation
import CoreMotion

@objc class SensorManager: NSObject, SensorManagerProtocol {

    public static var defaultValueForUndefinedSensor: Double = 0
    private static var sensorMap = [String: Sensor]() // TODO: make instance let
    private let landscapeMode: Bool

    public required init(sensors: [Sensor], landscapeMode: Bool) {
        self.landscapeMode = landscapeMode
        super.init()
        registerSensors(sensorList: sensors)
    }

    private func registerSensors(sensorList: [Sensor]) {
        type(of: self).sensorMap.removeAll()
        sensorList.forEach { type(of: self).sensorMap[$0.tag()] = $0 }
    }

    func formulaEditorItems(for spriteObject: SpriteObject) -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()

        for sensor in self.sensors() {
            items.append(FormulaEditorItem(sensor: sensor, spriteObject: spriteObject))
        }

        return items
    }

    func sensors() -> [Sensor] {
        Array(type(of: self).sensorMap.values)
    }

    func sensor(tag: String) -> Sensor? {
        type(of: self).sensorMap[tag]
    }

    func tag(sensor: Sensor) -> String {
        sensor.tag()
    }

    @objc func exists(tag: String) -> Bool {
        self.sensor(tag: tag) != nil
    }

    @objc func value(tag: String, spriteObject: SpriteObject? = nil) -> AnyObject {
        guard let sensor = sensor(tag: tag) else { return type(of: self).defaultValueForUndefinedSensor as AnyObject }
        var rawValue: AnyObject = type(of: sensor).defaultRawValue as AnyObject

        if let sensor = sensor as? ObjectSensor, let spriteObject = spriteObject {
            if let sensor = sensor as? ObjectDoubleSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            } else if let sensor = sensor as? ObjectStringSensor {
                rawValue = type(of: sensor).standardizedValue(for: spriteObject) as AnyObject
            }
        } else if let sensor = sensor as? TouchSensor, let spriteObject = spriteObject {
            rawValue = sensor.standardizedValue(for: spriteObject) as AnyObject
        } else if let sensor = sensor as? DeviceDoubleSensor {
            rawValue = sensor.standardizedValue(landscapeMode: landscapeMode) as AnyObject
        } else if let sensor = sensor as? DeviceStringSensor {
            rawValue = sensor.standardizedValue(landscapeMode: landscapeMode) as AnyObject
        }
        return rawValue
    }

    @objc static func requiredResource(tag: String) -> ResourceType {
        guard let sensor = sensorMap[tag] else { return .noResources }
        return type(of: sensor).requiredResource
    }

    @objc static func name(tag: String) -> String? {
        guard let sensor = sensorMap[tag] else { return nil }
        return type(of: sensor).name
    }
}
