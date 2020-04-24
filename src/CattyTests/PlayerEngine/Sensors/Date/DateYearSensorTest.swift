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

import XCTest

@testable import Pocket_Code

final class DateYearSensorMock: DateYearSensor {
    var mockDate = Date()

    override func date() -> Date {
        mockDate
    }
}

final class DateYearSensorTest: XCTestCase {

    var sensor: DateYearSensorMock!

    override func setUp() {
        super.setUp()
        sensor = DateYearSensorMock()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("DATE_YEAR", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        /* test during the year */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2017, month: 6, day: 7, hour: 10))!
        XCTAssertEqual(2017, Int(sensor.rawValue()))

        /* test edge case - almost the beginning of the next year  */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 12, day: 31, hour: 23))!
        XCTAssertEqual(2018, Int(sensor.rawValue()))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
