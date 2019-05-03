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

@objc class LayerSensor: NSObject, ObjectDoubleSensor {

    static let tag = "OBJECT_LAYER"
    static let name = kUIFEObjectLayer
    static let defaultRawValue = 0.0
    static let position = 100
    static let requiredResource = ResourceType.noResources

    func tag() -> String {
        return type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return defaultRawValue(for: spriteObject)
        }
        return Double(spriteNode.zPosition)
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        let rawValue = convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.zPosition = CGFloat(rawValue)
    }

    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        if rawValue == 0 {
            // for background
            return -1
        }
        return rawValue
    }

    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        if userInput < 1 {
            // can not be set for background
            return 1
        }
        return userInput
    }

    static func defaultRawValue(for spriteObject: SpriteObject) -> Double {
        guard let objectList = spriteObject.project?.objectList as? [SpriteObject] else {
            return defaultRawValue
        }

        var zPosition = defaultRawValue
        for object in objectList {
            if object == spriteObject {
                return zPosition
            }
            zPosition += 1
        }

        return defaultRawValue
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        return [.object(position: type(of: self).position)]
    }
}
