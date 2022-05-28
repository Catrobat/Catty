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

@objc extension NSDate {
    private var sameDayDateFormatter: DateFormatter {
        let someDayDateFormatter = DateFormatter()
        someDayDateFormatter.dateFormat = "yyyy-MM-dd"
        return someDayDateFormatter
    }

    private var humanFriendlyTodayDateFormatter: DateFormatter {
        let humanFriendlyTodayDateFormatter = DateFormatter()
        humanFriendlyTodayDateFormatter.dateFormat = "HH:mm"
        return humanFriendlyTodayDateFormatter
    }

    private var humanFriendlyDateFormatter: DateFormatter {
        let humanFriendlyDateFormatter = DateFormatter()
        humanFriendlyDateFormatter.dateFormat = "LLL d, yyyy"
        return humanFriendlyDateFormatter
    }

    func isSameDay(_ date: NSDate) -> Bool {
        let dateFormatter = sameDayDateFormatter
        if let ownDate = dateFormatter.date(from: dateFormatter.string(from: self as Date)) {
            if let date = dateFormatter.date(from: dateFormatter.string(from: date as Date)) {
             return ownDate.compare(date) == .orderedSame
            }
        }
        return false
    }

    func isToday() -> Bool {
        self.isSameDay(NSDate())
    }

    func isYesterday() -> Bool {
        self.isSameDay(NSDate(timeIntervalSinceNow: -(60.0 * 60.0 * 24.0)))
    }

    func humanFriendlyFormattedString() -> String {
        if isToday() {
            return "\(kLocalizedToday) \(humanFriendlyTodayDateFormatter.string(from: self as Date))"
        } else if isYesterday() {
            return kLocalizedYesterday
        }
        return humanFriendlyDateFormatter.string(from: self as Date)
    }
}
