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
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String {        
        // both parameters are string
        if let firstText = firstParameter as? String,
            let secondText = secondParameter as? String {
            return firstText + secondText
        }
        
        // both parameters are numbers
        if let firstNumber = firstParameter as? Double,
            let secondNumber = secondParameter as? Double {
            if floor(firstNumber) == firstNumber && floor(secondNumber) == secondNumber {
                return String(Int(firstNumber)) + String(Int(secondNumber))
            }
            if floor(firstNumber) == firstNumber && floor(secondNumber) != secondNumber {
                return String(Int(firstNumber)) + String(secondNumber)
            }
            if floor(firstNumber) != firstNumber && floor(secondNumber) == secondNumber {
                return String(firstNumber) + String(Int(secondNumber))
            }
            if floor(firstNumber) != firstNumber && floor(secondNumber) != secondNumber {
                return String(firstNumber) + String(secondNumber)
            }
        }
        
        // first parameter string, second parameter number
        if let firstText = firstParameter as? String,
            let secondNumber = secondParameter as? Double {
            if floor(secondNumber) == secondNumber {
                return firstText + String(Int(secondNumber))
            } else {
                return firstText + String(secondNumber)
            }
        }
        
        // first parameter number, second parameter string
        if let firstNumber = firstParameter as? Double,
            let secondText = secondParameter as? String {
            if floor(firstNumber) == firstNumber {
                return String(Int(firstNumber)) + secondText
            } else {
                return String(firstNumber) + secondText
            }
        }
        
        return type(of: self).defaultValue
    }
    
    static func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: position)
    }
}
