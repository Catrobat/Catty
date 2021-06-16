/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

protocol ObjectDoubleSensor: ObjectSensor {

    // The iOS device specific value of the sensor
    static func rawValue(for spriteObject: SpriteObject) -> Double

    // Convert the Pocket Code standardized sensor value to the iOS specific value (rawValue)
    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double

    // Set the iOS specific value of the sensor by converting the user input to a standardized raw value
    static func setRawValue(userInput: Double, for spriteObject: SpriteObject)

    // Convert the iOS specific value (rawValue) to the Pocket Code standardized sensor value
    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double
}

extension ObjectDoubleSensor {
    // The Pocket Code standardized sensor value
    static func standardizedValue(for spriteObject: SpriteObject) -> Double {
        let rawValue = self.rawValue(for: spriteObject)
        return convertToStandardized(rawValue: rawValue, for: spriteObject)
    }

    static func standardizedRawValue(for spriteObject: SpriteObject) -> Double {
        convertToStandardized(rawValue: defaultRawValue, for: spriteObject)
    }
}
