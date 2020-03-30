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

@objc class ColorSensor: NSObject, ObjectDoubleSensor {

    @objc static let tag = "OBJECT_COLOR"
    static let name = kUIFEObjectColor
    @objc static let defaultRawValue = 0.0
    static let position = 110
    static let requiredResource = ResourceType.noResources

    func tag() -> String {
        type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return self.defaultRawValue
        }
        return Double(spriteNode.ciHueAdjust)
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        let rawValue = self.convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.ciHueAdjust = CGFloat(rawValue)
    }

    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        rawValue * 100 / Double.pi
    }

    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        var valueToConvert = userInput
        let whole = Int(valueToConvert)
        let fraction = valueToConvert.truncatingRemainder(dividingBy: 1)

        if valueToConvert >= 200 {
            valueToConvert = Double(whole % 200) + fraction
        } else if valueToConvert < 0 {
            valueToConvert = 200 - (Double(-whole % 200) + fraction)
            if valueToConvert == 200 {
                valueToConvert = 0
            }
        }
        return valueToConvert / 100 * Double.pi
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.object(position: type(of: self).position)]
    }
}
