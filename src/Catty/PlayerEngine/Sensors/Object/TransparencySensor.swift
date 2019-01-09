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

@objc class TransparencySensor: NSObject, ObjectDoubleSensor {

    @objc static let tag = "OBJECT_GHOSTEFFECT"
    static let name = kUIFEObjectTransparency
    @objc static let defaultRawValue = 1.0
    static let position = 10
    static let requiredResource = ResourceType.noResources

    func tag() -> String {
        return type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return TransparencySensor.defaultRawValue
        }

        return Double(spriteNode.alpha)
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        let rawValue = self.convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.alpha = CGFloat(rawValue)
    }

    /*  on iOS, the transparency function is descending:
     1.0 - no transparency
     0.0 - maximum transaprency

     on Android the transparency function is ascending:
     0.0 - no transparency
     100.0 - maximum transparency

     And they also have different ranges and scales.
     */

    // f:[0, 1] -> [0, 100]
    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {

        if rawValue >= 1 {
            return 0.0 // maximum transparency
        }
        if rawValue <= 0 {
            return 100.0 // no transparency
        }
        return 100 - 100 * rawValue
    }

    // f:[0, 100] -> [0, 1]
    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {

        if userInput >= 100 {
            return 0.0 // maximum transparency
        }
        if userInput <= 0 {
            return 1.0 // no transparency
        }
        return (100 - userInput) / 100
    }

    func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        return .object(position: type(of: self).position)
    }
}
