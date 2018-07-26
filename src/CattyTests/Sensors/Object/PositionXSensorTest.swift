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

    let screenWidth = 500
    let screenHeight = 500
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    let sensor = PositionXSensor.self

    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        self.spriteNode.mockedScene = CBScene(size: CGSize(width: screenWidth, height: screenHeight))
    }

    override func tearDown() {
        self.spriteObject = nil
    }

    func testDefaultRawValue() {
        spriteNode.mockedPosition = CGPoint(x: 12, y: 34)
        XCTAssertNotEqual(sensor.rawValue(for: spriteObject), sensor.defaultRawValue, accuracy: 0.0001)
        
        spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.rawValue(for: spriteObject), sensor.defaultRawValue, accuracy: 0.0001)
    }
    
    func testRawValue() {
        // test point inside the screen, positive X value
        spriteNode.mockedPosition = CGPoint(x: 12, y: 34)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), 12, accuracy: 0.0001)
        
        // test point inside the screen, negative X value
        spriteNode.mockedPosition = CGPoint(x: -55, y: 34)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), -55, accuracy: 0.0001)
        
        // test middle of the screen
        spriteNode.mockedPosition = CGPoint(x: 0, y: 0)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), 0, accuracy: 0.0001)
        
        // test right edge of the screen iPhone 8 Plus
        spriteNode.mockedPosition = CGPoint(x: 187, y: 100)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), 187, accuracy: 0.0001)
        
        // test left edge of the screen iPhone 8 Plus
        spriteNode.mockedPosition = CGPoint(x: -187, y: 100)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), -187, accuracy: 0.0001)
        
        // test outside of the screen
        spriteNode.mockedPosition = CGPoint(x: 10000, y: 30)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), 10000, accuracy: 0.0001)
        
        // test float value
        spriteNode.mockedPosition = CGPoint(x: 20.22, y: 44)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), 20.22, accuracy: 0.0001)
        
        // test random point
        let random_x = drand48() * 100
        spriteNode.mockedPosition = CGPoint(x: random_x, y: 34)
        XCTAssertEqual(sensor.rawValue(for: spriteObject), random_x, accuracy: 0.0001)
    }
    
    func testSetRawValue() {
        let expectedRawValue = sensor.convertToRaw(userInput: 10, for: spriteObject)
        sensor.setRawValue(userInput: 10, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.position.x), accuracy: 0.001)
    }
    
    func testConvertToStandardized() {
        // random
        XCTAssertEqual(Double(10 - screenWidth / 2), sensor.convertToStandardized(rawValue: 10, for: spriteObject))
        
        // center
        XCTAssertEqual(Double(250 - screenWidth / 2), sensor.convertToStandardized(rawValue: 250, for: spriteObject))
        
        // left
        XCTAssertEqual(Double(63 - screenWidth / 2), sensor.convertToStandardized(rawValue: 63, for: spriteObject))
        
        // right
        XCTAssertEqual(Double(437 - screenWidth / 2), sensor.convertToStandardized(rawValue: 437, for: spriteObject))
    }
    
    func testConvertToRaw() {
        // random
        XCTAssertEqual(Double(10 + screenWidth / 2), sensor.convertToRaw(userInput: 10, for: spriteObject))
        
        // center
        XCTAssertEqual(Double(0 + screenWidth / 2), sensor.convertToRaw(userInput: 0, for: spriteObject))
        
        // left
        XCTAssertEqual(Double(-187 + screenWidth / 2), sensor.convertToRaw(userInput: -187, for: spriteObject))
        
        // right
        XCTAssertEqual(Double(187 + screenWidth / 2), sensor.convertToRaw(userInput: 187, for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_X", sensor.tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, sensor.requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: spriteObject))
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.object(position: sensor.position), sensor.formulaEditorSection(for: spriteObject))
    }
    
}
