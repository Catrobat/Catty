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

enum FormulaEditorSection {
    case functions(position: Int, subsection: FunctionSubsection)
    case logic(position: Int, subsection: LogicSubsection)
    case sensors(position: Int, subsection: SensorSubsection)
    case object(position: Int, subsection: ObjectSubsection)
}

extension FormulaEditorSection: Equatable {
    static func == (left: FormulaEditorSection, right: FormulaEditorSection) -> Bool {
        switch (left, right) {
        case (let .sensors(positionLeft), let .sensors(positionRight)):
            return positionLeft == positionRight

        case (let .functions(positionLeft), let .functions(positionRight)):
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
        case let .sensors(position, _):
            return position

        case let .functions(position, _):
            return position

        case let .logic(position, _):
            return position

        case let .object(position, _):
            return position
        }
    }

    func subsection() -> FormulaEditorSubsection {
        switch self {
        case let .functions(_, subsection):
            return subsection

        case let .object(position: _, subsection: subsection):
            return subsection

        case let .logic(position: _, subsection: subsection):
            return subsection

        case let .sensors(position: _, subsection: subsection):
            return subsection

        }
    }

}
