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

protocol TouchSensor: Sensor {
    
    // The iOS device specific value of the sensor
    func rawValue() -> Double
    
    // Convert the iOS specific value (rawValue) to the Pocket Code standardized sensor value
    func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double
}

extension TouchSensor {
    // The Pocket Code standardized sensor value
    func standardizedValue(for spriteObject: SpriteObject) -> Double {
        let rawValue = self.rawValue()
        return convertToStandardized(rawValue: rawValue, for: spriteObject)
    }
    
    func standardizedRawValue(for spriteObject: SpriteObject) -> Double {
        return convertToStandardized(rawValue: type(of: self).defaultRawValue, for: spriteObject)
    }
}
