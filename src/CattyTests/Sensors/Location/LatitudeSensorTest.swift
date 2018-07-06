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

final class LatitudeSensorTest: XCTestCase {
    
    var locationManager: LocationManagerMock!
    var sensor: LatitudeSensor!
    
    override func setUp() {
        self.locationManager = LocationManagerMock()
        self.sensor = LatitudeSensor { [weak self] in self?.locationManager }
    }
    
    override func tearDown() {
        self.sensor = nil
        self.locationManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = LatitudeSensor { nil }
        XCTAssertEqual(LatitudeSensor.defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        // min value - South Pole
        self.locationManager.latitude = -90
        XCTAssertEqual(-90, self.sensor.rawValue())
        
        // max value - North Pole
        self.locationManager.latitude = 90
        XCTAssertEqual(90, self.sensor.rawValue())
        
        // center
        self.locationManager.latitude = 0
        XCTAssertEqual(0, self.sensor.rawValue())
        
        // London
        self.locationManager.latitude = 51.5
        XCTAssertEqual(51.5, self.sensor.rawValue())
        
        // Cape Town
        self.locationManager.latitude = -33.92
        XCTAssertEqual(-33.92, self.sensor.rawValue())
        
        // Munich
        self.locationManager.latitude = 48.13
        XCTAssertEqual(48.13, self.sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        self.locationManager.latitude = 100
        XCTAssertEqual(self.sensor.rawValue(), self.sensor.convertToStandardized(rawValue: self.locationManager.latitude!))
    }
    
    func testTag() {
        XCTAssertEqual("LATITUDE", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}

