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

final class InclinationYSensorTest: XCTestCase {
    
    var motionManager: MotionManagerMock!
    var sensor: InclinationYSensor!
    
    override func setUp() {
        self.motionManager = MotionManagerMock()
        self.sensor = InclinationYSensor { [weak self] in self?.motionManager }
    }
    
    override func tearDown() {
        self.sensor = nil
        self.motionManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = InclinationYSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        // test maximum value
        self.motionManager.attitude = (pitch: Double.pi/2, roll: 0)
        XCTAssertEqual(self.sensor.rawValue(), Double.pi/2, accuracy: 0.0001)
        
        // test minimum value
        self.motionManager.attitude = (pitch: -Double.pi/2, roll: 0)
        XCTAssertEqual(self.sensor.rawValue(), -Double.pi/2, accuracy: 0.0001)
        
        // test no inclination
        self.motionManager.attitude = (pitch: 0, roll: 0)
        XCTAssertEqual(self.sensor.rawValue(), 0, accuracy: 0.0001)
        
        // tests inside the range
        self.motionManager.attitude = (pitch: Double.pi/3, roll: 0)
        XCTAssertEqual(self.sensor.rawValue(), Double.pi/3, accuracy: 0.0001)
        
        self.motionManager.attitude = (pitch: -Double.pi/6, roll: 0)
        XCTAssertEqual(self.sensor.rawValue(), -Double.pi/6, accuracy: 0.0001)
    }
    
    func testConvertToStandardizedScreenUp() {
        self.motionManager.zAcceleration = -0.5 // or any other negative value read by acceleration the sensors
        
        // no inclination
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: 0), 0, accuracy: 0.0001)
        
        // half up - home botton down
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: Double.pi/4), 45, accuracy: 0.0001)
        
        // up - face to face to the user
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: Double.pi/2), 90, accuracy: 0.0001)
        
        // half up - home button up
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: -Double.pi/4), -45, accuracy: 0.0001)
    }
    
    func testConvertToStandardizedScreenDown() {
        self.motionManager.zAcceleration = 0.5 //or any other positive value read by the acceleration sensors
        
        // half down - home button down
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: Double.pi/4), 135, accuracy: 0.0001)
        
        // up - with the back to the user
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: -Double.pi/2), -90, accuracy: 0.0001)
        
        // half down - home button up
        XCTAssertEqual(self.sensor.convertToStandardized(rawValue: -Double.pi/4), -135, accuracy: 0.0001)
    }
    
    func testTag() {
        XCTAssertEqual("Y_INCLINATION", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.accelerometer, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
