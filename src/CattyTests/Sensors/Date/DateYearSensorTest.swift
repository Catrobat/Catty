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

final class DateYearSensorMock: DateYearSensor {
    var mockDate: Date = Date()
    
    override func date() -> Date {
        return mockDate
    }
}

final class DateYearSensorTest: XCTestCase {
    
    var sensor: DateYearSensorMock!
    
    override func setUp() {
        self.sensor = DateYearSensorMock()
    }
    
    override func tearDown() {
        self.sensor = nil
    }
    
    func testTag() {
        XCTAssertEqual("DATE_YEAR", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testRawValue() {
        /* test during the year */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1497657600)
        XCTAssertEqual(2017, Int(sensor.rawValue()))
        
        /* test edge case - almost the beginning of the next year - 31/12/2018 23:00 */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1546297200)
        XCTAssertEqual(2018, Int(sensor.rawValue()))
    }
    
    func testStandardizedValue() {
        XCTAssertEqual(sensor.rawValue(), sensor.standardizedValue())
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
