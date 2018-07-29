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

class PowFunction: DoubleParameterFunction {
    static var tag = "POW"
    static var name = "pow"
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 10
    
    static func firstParameter() -> FunctionParameter {
        return .number(defaultValue: 0)
    }
    
    static func secondParameter() -> FunctionParameter {
        return .number(defaultValue: 0)
    }
    
    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double {
        return 0.0
    }
    /*func value(parameter: AnyObject?) -> Double {
        guard let degree = parameter as? Double else { return type(of: self).defaultValue }
        return sin(Util.degree(toRadians: degree))
    }*/
    
    static func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: position)
    }
}
