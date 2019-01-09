/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc class BrightnessSensor: NSObject, ObjectDoubleSensor {

    @objc static let tag = "OBJECT_BRIGHTNESS"
    static let name = kUIFEObjectBrightness
    @objc static let defaultRawValue = 0.0
    static let position = 20
    static let requiredResource = ResourceType.noResources

    func tag() -> String {
        return type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else { return BrightnessSensor.defaultRawValue }
        return Double(spriteNode.ciBrightness)
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        let rawValue = self.convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.ciBrightness = CGFloat(rawValue)
    }

    // f:[-1, 1] -> [0, 200]
    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {

        if rawValue >= 1 {
            return 200.0
        } else if rawValue <= -1 {
            return 0.0
        }

        return 100 * rawValue + 100
    }

    // f:[0, 200] -> [-1, 1]
    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {

        if userInput >= 200 {
            return 1.0
        } else if userInput <= 0 {
            return -1.0
        }

        return (userInput - 100) / 100
    }

    func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        return .object(position: type(of: self).position)
    }
}
