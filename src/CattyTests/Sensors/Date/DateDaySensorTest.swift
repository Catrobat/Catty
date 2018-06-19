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

final class DateDaySensorMock: DateDaySensor {
    var mockDate: Date = Date()
    
    override func date() -> Date {
        return mockDate
    }
}

final class DateDaySensorTest: XCTestCase {
    
    var sensor: DateDaySensorMock!
    
    override func setUp() {
        self.sensor = DateDaySensorMock()
    }
    
    override func tearDown() {
        self.sensor = nil
    }
    
    func testTag() {
        XCTAssertEqual("DATE_DAY", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testRawValue() {
        /* test one digit */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1528243200)
        XCTAssertEqual(6, Int(sensor.rawValue()))
        
        /* test two digits */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1534914000)
        XCTAssertEqual(22, Int(sensor.rawValue()))
        
        /* test edge case - almost the beginning of the next day - 18/06/2018 23:00 */
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1529362800)
        XCTAssertEqual(18, Int(sensor.rawValue()))
    }
    
    func testStandardizedValue() {
        XCTAssertEqual(sensor.rawValue(), sensor.standardizedValue())
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
