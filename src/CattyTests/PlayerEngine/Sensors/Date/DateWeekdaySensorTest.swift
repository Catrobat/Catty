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

final class DateWeekdaySensorMock: DateWeekdaySensor {
    var mockDate = Date()

    override func date() -> Date {
        return mockDate
    }
}

final class DateWeekdaySensorTest: XCTestCase {

    var sensor: DateWeekdaySensorMock!

    override func setUp() {
        super.setUp()
        sensor = DateWeekdaySensorMock()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("DATE_WEEKDAY", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        /* test Sunday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 17, hour: 10))!
        XCTAssertEqual(1, Int(sensor.rawValue()))

        /* test Monday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 18, hour: 10))!
        XCTAssertEqual(2, Int(sensor.rawValue()))

        /* test Tuesday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 19, hour: 10))!
        XCTAssertEqual(3, Int(sensor.rawValue()))

        /* test Wednesday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 20, hour: 10))!
        XCTAssertEqual(4, Int(sensor.rawValue()))

        /* test Thursday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 21, hour: 10))!
        XCTAssertEqual(5, Int(sensor.rawValue()))

        /* test Friday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 22, hour: 10))!
        XCTAssertEqual(6, Int(sensor.rawValue()))

        /* test Saturday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 23, hour: 10))!
        XCTAssertEqual(7, Int(sensor.rawValue()))

        /* test edge case - almost the beginning of the next day - Tuesday */
        sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 19, hour: 23))!
        XCTAssertEqual(3, Int(sensor.rawValue()))
    }

    func testConvertToStandardized() {
        /* test Sunday */
        XCTAssertEqual(7, Int(sensor.convertToStandardized(rawValue: 1)))

        /* test Monday */
        XCTAssertEqual(1, Int(sensor.convertToStandardized(rawValue: 2)))

        /* test Tuesday */
        XCTAssertEqual(2, Int(sensor.convertToStandardized(rawValue: 3)))

        /* test Wednesday */
        XCTAssertEqual(3, Int(sensor.convertToStandardized(rawValue: 4)))

        /* test Thursday */
        XCTAssertEqual(4, Int(sensor.convertToStandardized(rawValue: 5)))

        /* test Friday */
        XCTAssertEqual(5, Int(sensor.convertToStandardized(rawValue: 6)))

        /* test Saturday */
        XCTAssertEqual(6, Int(sensor.convertToStandardized(rawValue: 7)))
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
