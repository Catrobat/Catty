/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class CompassDirectionSensor: DeviceDoubleSensor {

    static let tag = "COMPASS_DIRECTION"
    static let name = kUIFESensorCompass
    static let defaultRawValue = 0.0
    static let position = 180
    static let requiredResource = ResourceType.compass

    let getLocationManager: () -> LocationManager?

    init(locationManagerGetter: @escaping () -> LocationManager?) {
        self.getLocationManager = locationManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(landscapeMode: Bool) -> Double {
        guard let compassSensor = self.getLocationManager() else { return type(of: self).defaultRawValue }
        guard let compassSensorHeading = compassSensor.heading?.magneticHeading else { return type(of: self).defaultRawValue }

        if !landscapeMode {
            return compassSensorHeading
        } else {
            return compassSensorHeading + 90.0
        }
    }

    func convertToStandardized(rawValue: Double) -> Double {
        if rawValue <= 180 {
            return -rawValue
        } else {
            return 360 - rawValue
        }
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .device)]
    }
}
