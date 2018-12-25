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

@objc class LookNumberSensor: NSObject, ObjectDoubleSensor {

    @objc static let tag = "OBJECT_LOOK_NUMBER"
    static let name = kUIFEObjectLookNumber
    static let defaultRawValue = 0.0
    static let position = 40
    static let requiredResource = ResourceType.noResources

    func tag() -> String {
        return type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else { return LookNumberSensor.defaultRawValue }
        guard let currentLook = spriteNode.currentLook else { return LookNumberSensor.defaultRawValue }
        let index = spriteObject.lookList.index(of: currentLook)
        return Double(index)
    }

    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        return rawValue + 1
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        fatalError("This sensor is read-only")
    }

    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        fatalError("This sensor is read-only")
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        if spriteObject.isBackground() == true {
            return []
        }
        return [.object(position: type(of: self).position)]
    }
}
