/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class PowerFunction: DoubleParameterDoubleFunction {
    static var tag = "POWER"
    static var name = kUIFEFunctionPower
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 130

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 2)
    }

    func secondParameter() -> FunctionParameter {
        .number(defaultValue: 3)
    }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double {
        guard let base = firstParameter as? Double,
            let exponent = secondParameter as? Double else {
                return type(of: self).defaultValue
        }
        return pow(base, exponent)
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.functions(position: type(of: self).position, subsection: .maths)]
    }
}
