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

import XCTest

@testable import Pocket_Code

final class DateMonthSensorMock: DateMonthSensor {
    var mockDate = Date()

    override func date() -> Date {
        return mockDate
    }
}

final class DateMonthSensorTest: XCTestCase {

    var sensor: DateMonthSensorMock!

    override func setUp() {
        super.setUp()
        sensor = DateMonthSensorMock()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("DATE_MONTH", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        /* test one digit */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 5, day: 3, hour: 10))!
        XCTAssertEqual(5, Int(sensor.rawValue()))

        /* test two digits */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2017, month: 12, day: 16, hour: 17))!
        XCTAssertEqual(12, Int(sensor.rawValue()))

        /* test edge case - almost the beginning of the next month */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 10, day: 31, hour: 23))!
        XCTAssertEqual(10, Int(sensor.rawValue()))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(10, sensor.convertToStandardized(rawValue: 10))
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
