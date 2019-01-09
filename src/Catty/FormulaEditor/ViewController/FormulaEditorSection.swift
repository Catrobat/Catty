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

enum FormulaEditorSection {
    case math(position: Int)
    case logic(position: Int)
    case device(position: Int)
    case object(position: Int)
}

extension FormulaEditorSection: Equatable {
    static func == (left: FormulaEditorSection, right: FormulaEditorSection) -> Bool {
        switch (left, right) {
        case (let .device(positionLeft), let .device(positionRight)):
            return positionLeft == positionRight

        case (let .math(positionLeft), let .math(positionRight)):
            return positionLeft == positionRight

        case (let .logic(positionLeft), let .logic(positionRight)):
            return positionLeft == positionRight

        case (let .object(positionLeft), let .object(positionRight)):
            return positionLeft == positionRight

        default:
            return false
        }
    }

    func position() -> Int {
        switch self {
        case let .device(position):
            return position

        case let .math(position):
            return position

        case let .logic(position):
            return position

        case let .object(position):
            return position
        }
    }
}
