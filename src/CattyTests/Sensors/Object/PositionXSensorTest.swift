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

final class PositionXSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: PositionXSensor!

    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = PositionXSensor()
    }

    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }

    func testReturnDefaultValue() {
        self.spriteNode.pos = CGPoint(x: 12, y: 34)
        XCTAssertNotEqual(sensor.rawValue(for: self.spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
        
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.rawValue(for: self.spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
        XCTAssertEqual(sensor.standardizedValue(for: self.spriteObject), PositionXSensor.defaultValue, accuracy: 0.0001)
    }
    
    func testRawValue() {
        // test point inside the screen, positive X value
        self.spriteNode.pos = CGPoint(x: 12, y: 34)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 12, accuracy: 0.0001)
        
        // test point inside the screen, negative X value
        self.spriteNode.pos = CGPoint(x: -55, y: 34)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), -55, accuracy: 0.0001)
        
        // test middle of the screen
        self.spriteNode.pos = CGPoint(x: 0, y: 0)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 0, accuracy: 0.0001)
        
        // test right edge of the screen iPhone 8 Plus
        self.spriteNode.pos = CGPoint(x: 187, y: 100)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 187, accuracy: 0.0001)
        
        // test left edge of the screen iPhone 8 Plus
        self.spriteNode.pos = CGPoint(x: -187, y: 100)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), -187, accuracy: 0.0001)
        
        // test outside of the screen
        self.spriteNode.pos = CGPoint(x: 10000, y: 30)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 10000, accuracy: 0.0001)
        
        // test float value
        self.spriteNode.pos = CGPoint(x: 20.22, y: 44)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 20.22, accuracy: 0.0001)
        
        // test random point
        let random_x = drand48() * 100
        self.spriteNode.pos = CGPoint(x: random_x, y: 34)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), random_x, accuracy: 0.0001)
    }
    
    func testStandardizeValue() {
        // test point inside the screen, positive X value
        self.spriteNode.pos = CGPoint(x: 12, y: 34)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), 12, accuracy: 0.0001)
        
        // test point inside the screen, negative X value
        self.spriteNode.pos = CGPoint(x: -55, y: 34)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), -55, accuracy: 0.0001)
        
        // test middle of the screen
        self.spriteNode.pos = CGPoint(x: 0, y: 0)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), 0, accuracy: 0.0001)
        
        // test right edge of the screen iPhone 8 Plus
        self.spriteNode.pos = CGPoint(x: 187, y: 100)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), 187, accuracy: 0.0001)
        
        // test left edge of the screen iPhone 8 Plus
        self.spriteNode.pos = CGPoint(x: -187, y: 100)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), -187, accuracy: 0.0001)
        
        // test outside of the screen
        self.spriteNode.pos = CGPoint(x: 10000, y: 30)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), 10000, accuracy: 0.0001)
        
        // test float value
        self.spriteNode.pos = CGPoint(x: 20.22, y: 44)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), 20.22, accuracy: 0.0001)
        
        // test random point
        let random_x = drand48() * 100
        self.spriteNode.pos = CGPoint(x: random_x, y: 34)
        XCTAssertEqual(self.sensor.standardizedValue(for: self.spriteObject), random_x, accuracy: 0.0001)
    }

    func testTag() {
        XCTAssertEqual("OBJECT_X", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}
