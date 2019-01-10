/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

protocol Operator {

    // Name for formula editor
    static var name: String { get }

    // Tag for serialization
    static var tag: String { get }

    // Priority for interpretation (higher priority gets interpreted first)
    static var priority: Int { get }

    // Sections to show in formula editor and the position within each section
    func formulaEditorSections() -> [FormulaEditorSection]
}

extension Operator {

    func doubleParameter(object: AnyObject) -> Double {
        if let double = object as? Double {
            return double
        } else if let int = object as? Int {
            return Double(int)
        } else if let string = object as? String {
            guard let double = Double(string) else { return 0 }
            return double
        }
        return 0
    }
}

protocol UnaryOperator: Operator {
    func value(parameter: AnyObject) -> Double
}

protocol BinaryOperator: Operator {
    func value(left: AnyObject, right: AnyObject) -> Double
}

protocol UnaryLogicalOperator: Operator {
    func value(parameter: AnyObject) -> Bool
}

protocol BinaryLogicalOperator: Operator {
    func value(left: AnyObject, right: AnyObject) -> Bool
}
