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

class LengthFunction: SingleParameterDoubleFunction {

    static var tag = "LENGTH"
    static var name = "length"
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 210

    func tag() -> String {
        return type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        return .string(defaultValue: "hello world")
    }

    func value(parameter: AnyObject?) -> Double {
        let text = type(of: self).interpretParameter(parameter: parameter)
        return Double(text.count)
    }

    func formulaEditorSection() -> FormulaEditorSection {
        return .math(position: type(of: self).position)
    }
}
