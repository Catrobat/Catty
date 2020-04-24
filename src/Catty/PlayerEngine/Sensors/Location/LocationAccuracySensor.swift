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

@objc class LocationAccuracySensor: NSObject, DeviceSensor {

    @objc static let tag = "LOCATION_ACCURACY"
    static let name = kUIFESensorLocationAccuracy
    static let defaultRawValue = 0.0
    static let position = 260
    static let requiredResource = ResourceType.location

    let getLocationManager: () -> LocationManager?

    init(locationManagerGetter: @escaping () -> LocationManager?) {
        self.getLocationManager = locationManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue() -> Double {
        self.getLocationManager()?.location?.horizontalAccuracy ?? type(of: self).defaultRawValue
    }

    func convertToStandardized(rawValue: Double) -> Double {
        if rawValue < 0 {
            return 0
        }
        return rawValue
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.device(position: type(of: self).position)]
    }
}
