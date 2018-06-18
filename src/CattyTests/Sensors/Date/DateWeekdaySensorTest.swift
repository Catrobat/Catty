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

final class DateWeekdaySensorMock: DateWeekdaySensor {
    var mockDate: Date = Date()
    
    override func date() -> Date {
        return mockDate
    }
}

final class DateWeekdaySensorTest: XCTestCase {
    
    var sensor: DateWeekdaySensorMock!
    
    override func setUp() {
        self.sensor = DateWeekdaySensorMock()
    }
    
    override func tearDown() {
        self.sensor = nil
    }
    
    func testTag() {
        XCTAssertEqual("DATE_WEEKDAY", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testRawValue() {
        // Monday
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1529280000)
        XCTAssertEqual(1, Int(sensor.rawValue()))
        
        // Sunday
        self.sensor.mockDate = Date.init(timeIntervalSince1970: 1529193600)
        XCTAssertEqual(7, Int(sensor.rawValue()))
    }
    
    func testStandardizedValue() {
        XCTAssertEqual(sensor.rawValue(), sensor.standardizedValue())
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
