/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class LetterFunction: DoubleParameterStringFunction {
    static var tag = "LETTER"
    static var name = "letter"
    static var defaultValue = ""
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 90

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 1)
    }

    func secondParameter() -> FunctionParameter {
        .string(defaultValue: "hello world")
    }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> String {
        guard let number = firstParameter as? Int else {
            return type(of: self).defaultValue
        }

        let text = type(of: self).interpretParameter(parameter: secondParameter)
        if number - 1 < 0 || number - 1 >= text.count {
            return type(of: self).defaultValue
        }
        let index = text.index(text.startIndex, offsetBy: number - 1)
        return String(text[index])
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.functions(position: type(of: self).position, subsection: .texts)]
    }
}
