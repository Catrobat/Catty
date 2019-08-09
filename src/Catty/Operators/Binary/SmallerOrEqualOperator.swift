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

@objc class SmallerOrEqualOperator: NSObject, BinaryLogicalOperator {

    @objc static var tag = "SMALLER_OR_EQUAL"
    static var name = "≤"
    static var priority = 4
    static var position = 4

    func value(left: AnyObject, right: AnyObject) -> Bool {
        let leftDouble = doubleParameter(object: left)
        let rightDouble = doubleParameter(object: right)

        return doubleParameter(leftDouble, isSmallerThan: rightDouble) || doubleParameter(leftDouble, isEqualTo: rightDouble)
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        return [.logic(position: type(of: self).position)]
    }
}
