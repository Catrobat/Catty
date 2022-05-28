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

import XCTest

@testable import Pocket_Code

final class NSDateExtensionTests: XCTestCase {

    let timeIntervalInSeconsFor1Day: TimeInterval = (60 * 60) * 24

    func testIsSameDay() {
        let today = NSDate()
        var nextDay = NSDate(timeInterval: timeIntervalInSeconsFor1Day, since: today as Date)
        XCTAssertFalse(today.isSameDay(nextDay))

        nextDay = NSDate()
        XCTAssertTrue(today.isSameDay(nextDay))
    }

    func testIsToday() {
        let today = NSDate()
        let nextDay = NSDate(timeInterval: timeIntervalInSeconsFor1Day, since: today as Date)
        XCTAssertFalse(nextDay.isToday())
        XCTAssertTrue(today.isToday())
    }

    func testIsYesterday() {
        let today = NSDate()
        let previousDay = NSDate(timeInterval: -timeIntervalInSeconsFor1Day, since: today as Date)
        XCTAssertFalse(today.isYesterday())
        XCTAssertTrue(previousDay.isYesterday())
    }

    func testHumanFriendlyFormattedString() {
        var date = NSDate()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let time = formatter.string(from: date as Date)
        var humanFriendlyFormattedString = "\(kLocalizedToday) \(time)"

        XCTAssertEqual(humanFriendlyFormattedString, date.humanFriendlyFormattedString())

        date = NSDate(timeInterval: -timeIntervalInSeconsFor1Day, since: Date())
        humanFriendlyFormattedString = kLocalizedYesterday

        XCTAssertEqual(humanFriendlyFormattedString, date.humanFriendlyFormattedString())

        let newYearsDay2020 = NSDate(timeIntervalSince1970: 1577844000)
        XCTAssertEqual(kLocalizedJan + " 1, 2020", newYearsDay2020.humanFriendlyFormattedString())
    }
}
