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
        sensor = DateDaySensorMock()
    }
    
    override func tearDown() {
        sensor = nil
    }
    
    func testTag() {
        XCTAssertEqual("DATE_DAY", sensor.tag())
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testRawValue() {
        /* test one digit */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 4, day: 6, hour: 5))!
        XCTAssertEqual(6, Int(sensor.rawValue()))
        
        /* test two digits */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 22, hour: 7))!
        XCTAssertEqual(22, Int(sensor.rawValue()))
        
        /* test edge case - almost the beginning of the next day */
        self.sensor.mockDate = Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 18, hour: 23))!
        XCTAssertEqual(18, Int(sensor.rawValue()))
    }
    
    func testStandardizedValue() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(10, sensor.convertToStandardized(rawValue: 10))
    }
   
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
