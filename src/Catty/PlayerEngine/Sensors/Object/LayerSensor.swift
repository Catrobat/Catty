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

@objc class LayerSensor: NSObject, ObjectSensor, ReadWriteSensor {

    static let tag = "OBJECT_LAYER"
    static let name = kUIFEObjectLayer
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.noResources

    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return type(of: self).defaultRawValue
        }
        return Double(spriteNode.zIndex)
    }

    func convertToStandardized(rawValue: Double) -> Double {
        if rawValue == 0 {
            // for background
            return -1
        }
        return rawValue
    }
    
    func convertToRaw(userInput: Double) -> Double {
        if userInput < 1 {
            // can not be set for background
            return 1
        }
        return userInput
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
}
