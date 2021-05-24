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

class TrueFunction: ZeroParameterDoubleFunction {
    static var tag = "TRUE"
    static var name = kUIFEFunctionTrue
    static var defaultValue = 1.0
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = true
    static let position = 20

    func tag() -> String {
        type(of: self).tag
    }

    func value() -> Double {
        1.0
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.logic(position: type(of: self).position, subsection: .logical)]
    }
}
