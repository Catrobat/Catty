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

final class InclinationXSensorTest: XCTestCase {

    var motionManager: MotionManagerMock!
    var sensor: InclinationXSensor!

    override func setUp() {
        self.motionManager = MotionManagerMock()
        self.sensor = InclinationXSensor { [weak self] in self?.motionManager }
    }

    override func tearDown() {
        self.sensor = nil
        self.motionManager = nil
    }

    func testDefaultRawValue() {
        let sensor = InclinationXSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        // test maximum value
        self.motionManager.attitude = (roll: Double.pi, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue(), Double.pi, accuracy: 0.0001)
        
        // test minimum value
        self.motionManager.attitude = (roll: -Double.pi, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue(), -Double.pi, accuracy: 0.0001)
        
        // test no inclination
        self.motionManager.attitude = (roll: 0, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue(), 0, accuracy: 0.0001)
        
        // tests inside the range
        self.motionManager.attitude = (roll: Double.pi/2, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue(), Double.pi/2, accuracy: 0.0001)
        
        self.motionManager.attitude = (roll: -Double.pi/3, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue(), -Double.pi/3, accuracy: 0.0001)
    }
    
    // does not depend on the orientation of the screen (left/right, up/down)
    func testConvertToStandardized() {
        // test no inclination
        XCTAssertEqual(sensor.convertToStandardized(rawValue: 0), 0, accuracy: 0.0001)
        
        // test screen half left
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi/4), 45, accuracy: 0.0001)
        
        // test screen half right
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi/4), -45, accuracy: 0.0001)
        
        // test screen left
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi/2), 90, accuracy: 0.0001)
        
        // test screen right
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi/2), -90, accuracy: 0.0001)
        
        // test screen left, then down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi), 180, accuracy: 0.0001)
        
        // test screen right, then down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi), -180, accuracy: 0.0001)
    }
    
    func testTag() {
        XCTAssertEqual("X_INCLINATION", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.deviceMotion, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: 50), type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}
