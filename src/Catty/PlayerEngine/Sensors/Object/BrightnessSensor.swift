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

@objc class BrightnessSensor: NSObject, ObjectSensor {

    static let tag = "OBJECT_BRIGHTNESS"
    static let name = kUIFEObjectBrightness
    static let defaultValue = 100.0
    static let requiredResource = ResourceType.noResources

    func rawValue(for spriteObject: SpriteObject) -> Double {
        return Double(spriteObject.spriteNode.brightness)
    }

    func standardizedValue(for spriteObject: SpriteObject) -> Double {
        return self.rawValue(for: spriteObject)
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
    
    static func convertRawToStandarized(rawValue: Double) -> Double {
        // TODO check conversion
        return 100 * rawValue;
    }
    
    static func convertStandarizedToRaw(standardizedValue: Double) -> Double {
        // TODO check conversion
        var brightnessValue = standardizedValue / 100
        
        if (brightnessValue > 2) {
            brightnessValue = 1.0;
        }
        else if (brightnessValue < 0){
            brightnessValue = -1.0;
        }
        else{
            brightnessValue -= 1.0;
        }
        
        return brightnessValue
    }
}
