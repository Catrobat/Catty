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

final class AltitudeSensorTest: XCTestCase {
    
    var locationManager: LocationManagerMock!
    var sensor: AltitudeSensor!
    
    override func setUp() {
        self.locationManager = LocationManagerMock()
        self.sensor = AltitudeSensor { [weak self] in self?.locationManager }
    }
    
    override func tearDown() {
        self.sensor = nil
        self.locationManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = AltitudeSensor { nil }
        XCTAssertEqual(AltitudeSensor.defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        // sea level
        self.locationManager.altitude = 0
        XCTAssertEqual(0, self.sensor.rawValue())
        
        // below sea level
        self.locationManager.altitude = -250
        XCTAssertEqual(-250, self.sensor.rawValue())
        
        // field
        self.locationManager.altitude = 600
        XCTAssertEqual(600, self.sensor.rawValue())
        
        // mountain
        self.locationManager.altitude = 1500
        XCTAssertEqual(1500, self.sensor.rawValue())
        
        // Mt. Everest
        self.locationManager.altitude = 8848
        XCTAssertEqual(8848, self.sensor.rawValue())
        
        // float attitude
        self.locationManager.altitude = 2555.875
        XCTAssertEqual(2555.875, self.sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))
    }
    
    func testTag() {
        XCTAssertEqual("ALTITUDE", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: 110), type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}

