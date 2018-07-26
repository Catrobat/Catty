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

@objc class LookNameSensor: NSObject, ObjectStringSensor {
    
    @objc static let tag = "OBJECT_LOOK_NAME"
    static let name = kUIFEObjectLookName
    static let defaultRawValue = 0.0
    static let defaultStringValue = ""
    static let position = 50
    static let requiredResource = ResourceType.noResources

    static func rawValue(for spriteObject: SpriteObject) -> String {
        guard let spriteNode = spriteObject.spriteNode else { return LookNameSensor.defaultStringValue }
        guard let currentLook = spriteNode.currentLook else { return LookNameSensor.defaultStringValue }
        return currentLook.name
    }

    static func convertToStandardized(rawValue: String, for spriteObject: SpriteObject) -> String {
        return rawValue
    }
    
    static func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return !spriteObject.isBackground()
    }
    
    static func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        if spriteObject.isBackground() == true {
            return .hidden
        }
        return .object(position: position)
    }
}
