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

final class TimeSecondSensorMock: TimeSecondSensor {
    var mockDate = Date()

    override func date() -> Date {
        return mockDate
    }
}

final class TimeSecondSensorTest: XCTestCase {

    var sensor: TimeSecondSensorMock!

    override func setUp() {
        super.setUp()
        sensor = TimeSecondSensorMock()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("TIME_SECOND", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        /* test one digit */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1529301965)
        XCTAssertEqual(5, Int(sensor.rawValue()))

        /* test two digits */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1528265185)
        XCTAssertEqual(25, Int(sensor.rawValue()))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
