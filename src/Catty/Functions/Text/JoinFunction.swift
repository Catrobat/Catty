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

class JoinFunction: DoubleParameterStringFunction {
    static var tag = "JOIN"
    static var name = "join"
    static var defaultValue = ""
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 230
    
    static func firstParameter() -> FunctionParameter {
        return .string(defaultValue: "hello ")
    }
    
    static func secondParameter() -> FunctionParameter {
        return .string(defaultValue: "world")
    }
    
    func interpretParameter(parameter: AnyObject?) -> String? {
        if let text = parameter as? String {
            return text
        }
        if let number = parameter as? Double {
            if floor(number) == number {
                return String(Int(number))
            }
            return String(number)
        }
        return type(of: self).defaultValue
    }
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String {        
        let firstText = interpretParameter(parameter: firstParameter)
        let secondText = interpretParameter(parameter: secondParameter)
        return firstText! + secondText!
    }
    
    static func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: position)
    }
}
