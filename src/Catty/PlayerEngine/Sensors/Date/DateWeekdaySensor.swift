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

class DateWeekdaySensor: DateSensor {

    static let tag = "DATE_WEEKDAY"
    static let name = kUIFESensorDateWeekday
    static let defaultRawValue = 0.0
    static let position = 130
    static let requiredResource = ResourceType.noResources

    func date() -> Date {
        Date()
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue() -> Double {
        Double(Calendar.current.component(.weekday, from: self.date()))
    }

    func convertToStandardized(rawValue: Double, landscapeMode: Bool) -> Double {
        var weekday = rawValue
        if weekday == 1.0 { //Sunday
            weekday = 7
        } else {
            weekday -= 1
        }
        return Double(weekday)
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.device(position: type(of: self).position)]
    }
}
