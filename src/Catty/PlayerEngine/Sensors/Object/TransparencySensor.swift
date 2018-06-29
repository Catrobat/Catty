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

class TransparencySensor: ObjectSensor {
    
    static let tag = "OBJECT_GHOSTEFFECT"
    static let name = kUIFEObjectTransparency
    static let defaultValue = 0.0
    static let requiredResource = ResourceType.noResources
    
    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return TransparencySensor.defaultValue
        }
        return Double(spriteNode.alpha)
    }
    
    func standardizedValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return TransparencySensor.defaultValue
        }
        return TransparencySensor.convertRawToStandarized(rawValue: Double(spriteNode.alpha))
    }
    
    // f:[-1, 1] -> [0, 100]
    static func convertRawToStandarized(rawValue: Double) -> Double {
        
        if rawValue >= 1 {
            return 100.0
        } else if rawValue <= -1 {
            return 0.0
        }
        
        return 50 * rawValue + 50
    }
    
    // f:[0, 100] -> [-1, 1]
    static func convertStandarizedToRaw(standardizedValue: Double) -> Double {
        
        if standardizedValue >= 100 {
            return 1.0
        } else if standardizedValue <= 0 {
            return -1.0
        }
        
        return (standardizedValue - 50) / 50
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
}
