/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc extension FormulaElement {

    func isVariableUsed(_ variable: UserVariable) -> Bool {
        if (type == ElementType.USER_VARIABLE) && (value == variable.name) {
            return true
        }
        if (self.rightChild != nil) && (rightChild.isVariableUsed(variable)) {
            return true
        }
        if (self.leftChild != nil) && (leftChild.isVariableUsed(variable)) {
            return true
        }
        return false
    }

    func isListUsed(_ list: UserList) -> Bool {
        if (type == ElementType.USER_LIST) && (value == list.name) {
            return true
        }
        if (self.rightChild != nil) && (rightChild.isListUsed(list)) {
            return true
        }
        if (self.leftChild != nil) && (leftChild.isListUsed(list)) {
            return true
        }
        return false
    }
}
