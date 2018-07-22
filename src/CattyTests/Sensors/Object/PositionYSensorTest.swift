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

final class PositionYSensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: PositionYSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = PositionYSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testDefaultRawValue() {
        self.spriteNode.mockedPosition = CGPoint(x: 34, y: 12)
        XCTAssertNotEqual(sensor.rawValue(for: self.spriteObject), PositionYSensor.defaultRawValue, accuracy: 0.0001)
        
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.rawValue(for: self.spriteObject), PositionYSensor.defaultRawValue, accuracy: 0.0001)
    }
    
    func testRawValue() {
        // test point inside the screen, positive Y value
        self.spriteNode.mockedPosition = CGPoint(x: 22, y: 33)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 33, accuracy: 0.0001)
        
        // test point inside the screen, negative Y value
        self.spriteNode.mockedPosition = CGPoint(x: 55, y: -78)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), -78, accuracy: 0.0001)
        
        // test middle of the screen
        self.spriteNode.mockedPosition = CGPoint(x: 0, y: 0)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 0, accuracy: 0.0001)
        
        // test top edge of the screen iPhone 8 Plus
        self.spriteNode.mockedPosition = CGPoint(x: 150, y: 333)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 333, accuracy: 0.0001)
        
        // test bottom edge of the screen iPhone 8 Plus
        self.spriteNode.mockedPosition = CGPoint(x: 150, y: -333)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), -333, accuracy: 0.0001)
        
        // test outside of the screen
        self.spriteNode.mockedPosition = CGPoint(x: 25, y: 9999)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 9999, accuracy: 0.0001)
        
        // test float value
        self.spriteNode.mockedPosition = CGPoint(x: 21, y: 15.765)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), 15.765, accuracy: 0.0001)
        
        // test random point
        let random_y = drand48() * 100
        self.spriteNode.mockedPosition = CGPoint(x: 180, y: random_y)
        XCTAssertEqual(self.sensor.rawValue(for: self.spriteObject), random_y, accuracy: 0.0001)
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(10, type(of: sensor).convertToStandardized(rawValue: 10))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_Y", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(type(of: sensor).showInFormulaEditor(for: self.spriteObject))
    }
}
