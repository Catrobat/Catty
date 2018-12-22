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

protocol CBOperator {

    // Name for formula editor
    static var name: String { get }

    // Tag for serialization
    static var tag: String { get } // TODO instance

    // Priority for interpretation (higher priority gets interpreted first)
    static var priority: Int { get }  // TODO instance

    // Return the section to show sensor in formula editor (FormulaEditorSection) and the position within that section (Int)
    // Use .hidden to not show the sensor at all
    func formulaEditorSection() -> FormulaEditorSection  // TODO array
}

extension CBOperator {

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

protocol UnaryOperator: CBOperator {
    func value(parameter: AnyObject) -> Double
}

protocol BinaryOperator: CBOperator {
    func value(left: AnyObject, right: AnyObject) -> Double
}

protocol UnaryLogicalOperator: CBOperator {
    func value(parameter: AnyObject) -> Bool
}

protocol BinaryLogicalOperator: CBOperator {
    func value(left: AnyObject, right: AnyObject) -> Bool
}
