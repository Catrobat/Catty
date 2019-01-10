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

import XCTest

@testable import Pocket_Code

final class TimeHourSensorMock: TimeHourSensor {
    var mockDate = Date()

    override func date() -> Date {
        return mockDate
    }
}

final class TimeHourSensorTest: XCTestCase {

    var sensor: TimeHourSensorMock!

    override func setUp() {
        super.setUp()
        sensor = TimeHourSensorMock()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("TIME_HOUR", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        /* test one digit */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 6, hour: 7))!
        XCTAssertEqual(7, Int(sensor.rawValue()))

        /* test two digits */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2017, month: 8, day: 10, hour: 16))!
        XCTAssertEqual(16, Int(sensor.rawValue()))

        /* test edge case - almost the beginning of the next day */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 22, hour: 23))!
        XCTAssertEqual(23, Int(sensor.rawValue()))

    }

    func testConvertToStandardized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(10, sensor.convertToStandardized(rawValue: 10))
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
