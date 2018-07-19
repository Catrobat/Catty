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

final class RotationSensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: RotationSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = RotationSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testDefaultRawValue() {
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(for: self.spriteObject))
    }
    
    func testRawValue() {
        // head up
        self.spriteNode.zRotation = 90
        XCTAssertEqual(90, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        // head down
        self.spriteNode.zRotation = -90
        XCTAssertEqual(-90, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        // head to the right
        self.spriteNode.zRotation = 180
        XCTAssertEqual(180, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        // head to the left
        self.spriteNode.zRotation = 0
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
    }
    
    /*func testConvertToStandarized() {
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        XCTAssertEqual(90, self.sensor.convertToStandardized(rawValue: 90), accuracy: 0.0001)
        XCTAssertEqual(-45, self.sensor.convertToStandardized(rawValue: -45), accuracy: 0.0001)
    }
    
    func testConvertToRaw() {
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        XCTAssertEqual(-90, self.sensor.convertToStandardized(rawValue: -90), accuracy: 0.0001)
        XCTAssertEqual(135, self.sensor.convertToStandardized(rawValue: 135), accuracy: 0.0001)
    } */
    
    func testTag() {
        XCTAssertEqual("OBJECT_ROTATION", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}
