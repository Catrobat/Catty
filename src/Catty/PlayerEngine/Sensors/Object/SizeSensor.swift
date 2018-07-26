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

class SizeSensor: ObjectDoubleSensor {

    static let androidToIOSScale = 2.4
    
    static let tag = "OBJECT_SIZE"
    static let name = kUIFEObjectSize
    static let defaultRawValue = 1.0 / androidToIOSScale
    static let requiredResource = ResourceType.noResources

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return self.defaultRawValue
        }
        return Double(spriteNode.xScale)
    }
    
    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        let rawValue = self.convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.xScale = CGFloat(rawValue)
        spriteObject.spriteNode.yScale = CGFloat(rawValue)
    }

    // the sprite on Android is about 2.4 times smaller
    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        return rawValue * (100 * androidToIOSScale)
    }
    
    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        if userInput <= 0 {
            return 0.0     //Android doesn't have negative values for size
        }
        return userInput / (100 * androidToIOSScale)
    }
    
    static func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
    
    static func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        return .object(position: 80)
    }
}
