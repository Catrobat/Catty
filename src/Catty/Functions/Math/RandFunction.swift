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

class RandFunction: DoubleParameterFunction {
    static var tag = "RAND"
    static var name = "rand"
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = false
    static let position = 80
    
    static func firstParameter() -> FunctionParameter {
        return .number(defaultValue: 0)
    }
    
    static func secondParameter() -> FunctionParameter {
        return .number(defaultValue: 1)
    }
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double {
        guard let firstValue = firstParameter as? Double,
            let secondValue = secondParameter as? Double else {
                return type(of: self).defaultValue
        }
        var minimum = firstValue
        var maximum = secondValue
        if minimum > maximum {
            let aux = minimum
            minimum = maximum
            maximum = aux
        }
        let random = arc4random() / UInt32.max
        var result = minimum + Double(random) * (maximum - minimum)
        
        if floor(firstValue) == firstValue && floor(secondValue) == secondValue {
            result = round(result)
        }
        return result
    }
    
    static func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: position)
    }
}
