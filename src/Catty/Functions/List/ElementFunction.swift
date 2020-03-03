/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class ElementFunction: DoubleParameterFunction {
    static var tag = "LIST_ITEM"
    static var name = "element"
    static var defaultValue = "" as AnyObject
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = false
    static let position = 40

    func tag() -> String {
        return type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        return .number(defaultValue: 1)
    }

    func secondParameter() -> FunctionParameter {
        return .list(defaultValue: "list name")
    }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject {
        guard let elementNumber = firstParameter as? Int,
            let list = secondParameter as? UserVariable,
            let elements = list.value as? [AnyObject] else {
                return type(of: self).defaultValue
        }

        if elements.isEmpty || elementNumber <= 0 || elementNumber > elements.count {
            return type(of: self).defaultValue
        }

        let index = elements.index(elements.startIndex, offsetBy: elementNumber - 1)
        return elements[index]
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        return [.math(position: (type(of: self).position))]
    }
}
