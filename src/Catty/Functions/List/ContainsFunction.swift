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

class ContainsFunction: DoubleParameterDoubleFunctionWithSpriteObject {
    static var tag = "CONTAINS"
    static var name = "contains"
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = false
    static let position = 260
    
    static func firstParameter() -> FunctionParameter {
        return .string(defaultValue: "*list name*")
    }
    
    static func secondParameter() -> FunctionParameter {
        return .number(defaultValue: 1)
    }
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> Double {
        guard let listName = firstParameter as? String else {
                return type(of: self).defaultValue
        }
        
        let list = spriteObject.program.variables.getUserListNamed(listName, for: spriteObject)
        if list == nil || list?.value == nil {
            return type(of: self).defaultValue
        }
        
        guard let elements = list?.value as? [AnyObject] else {
            return type(of: self).defaultValue
        }
        
        if elements.contains(where: { self.parameterMatch(firstParam: $0, secondParam: secondParameter) }) {
            return 1.0
        }
        return 0.0
    }
    
    private func parameterMatch(firstParam: AnyObject?, secondParam: AnyObject?) -> Bool {
        // check if first is string and second is string -> compare
        // check if first is number and second is number -> compare
        // check if first is number and second is string -> compare
        // check if first is string and second is number -> compare
        
        return false // TODO
    }
    
    static func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: position)
    }
}
