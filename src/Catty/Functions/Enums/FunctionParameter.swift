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

enum FunctionParameter {
    case number(defaultValue: Double)
    case string(defaultValue: String)
    case list(defaultValue: String)

    func defaultValueString() -> String {
        switch self {
        case let .number(defaultValue):
            return defaultValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", defaultValue) : String(defaultValue)
        case let .string(defaultValue):
            return defaultValue
        case let .list(defaultValue):
            return defaultValue
        }
    }

    func defaultValueForFunctionSignature() -> String {
        switch self {
        case .number:
            return defaultValueString()
        case .string:
            return "'" + defaultValueString() + "'"
        case .list:
            return "*" + defaultValueString() + "*"
        }
    }
}

extension FunctionParameter: Equatable {
    static func == (left: FunctionParameter, right: FunctionParameter) -> Bool {
        switch (left, right) {
        case (let .number(defaultValueLeft), let .number(defaultValueRight)):
            return defaultValueLeft == defaultValueRight

        case (let .string(defaultValueLeft), let .string(defaultValueRight)):
            return defaultValueLeft == defaultValueRight

        case (let .list(defaultValueLeft), let .list(defaultValueRight)):
            return defaultValueLeft == defaultValueRight

        default:
            return false
        }
    }
}
