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

class NumberOfItemsFunction: SingleParameterDoubleFunction {
    
    static var tag = "NUMBER_OF_ITEMS"
    static var name = "number_of_items"
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = false
    static let position = 240
    
    func tag() -> String {
        return type(of: self).tag
    }
    
    func firstParameter() -> FunctionParameter {
        return .list(defaultValue: "list name")
    }
    
    func value(parameter: AnyObject?) -> Double {
        guard let list = parameter as? UserVariable,
              let elements = list.value as? [AnyObject] else {
            return type(of: self).defaultValue
        }
        
        return Double(elements.count)
    }
    
    func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: (type(of: self).position))
    }
}
