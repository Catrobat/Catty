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

final class BrightnessSensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor = BrightnessSensor.self
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
    }
    
    override func tearDown() {
        self.spriteObject = nil
    }
    
    func testDefaultRawValue() {
        spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.defaultRawValue, sensor.rawValue(for: spriteObject))
    }
    
    func testRawValue() {
        spriteNode.ciBrightness = -1.0
        XCTAssertEqual(-1.0, sensor.rawValue(for: spriteObject))
        
        spriteNode.ciBrightness = 1.0
        XCTAssertEqual(1.0, sensor.rawValue(for: spriteObject))
        
        spriteNode.ciBrightness = 0.5
        XCTAssertEqual(0.5, sensor.rawValue(for: spriteObject))
    }
    
    func testSetRawValue() {
        let expectedRawValue = sensor.convertToRaw(userInput: 0.5, for: spriteObject)
        sensor.setRawValue(userInput: 0.5, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.ciBrightness), accuracy: 0.001)
    }
    
    func testConvertToStandardized() {
        // test minimum value
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -1.0, for: spriteObject))
        
        // test maximum value
        XCTAssertEqual(200, sensor.convertToStandardized(rawValue: 1.0, for: spriteObject))
        
        // test mean value
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 0.0, for: spriteObject))
        
        // test lower than minimum value
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -2.5, for: spriteObject))
        
        // test bigger than maximum value
        XCTAssertEqual(200, sensor.convertToStandardized(rawValue: 22.0, for: spriteObject))
        
        // test random value
        XCTAssertEqual(175, sensor.convertToStandardized(rawValue: 0.75, for: spriteObject))
    }
    
    func testConvertToRaw() {
        // test minimum value
        XCTAssertEqual(-1, sensor.convertToRaw(userInput: 0.0, for: spriteObject))
        
        // test maximum value
        XCTAssertEqual(1, sensor.convertToRaw(userInput: 200.0, for: spriteObject))
        
        // test mean value
        XCTAssertEqual(0, sensor.convertToRaw(userInput: 100.0, for: spriteObject))
        
        // test lower than minimum value
        XCTAssertEqual(-1, sensor.convertToRaw(userInput: -10.0, for: spriteObject))
        
        // test bigger than maximum value
        XCTAssertEqual(1, sensor.convertToRaw(userInput: 280.0, for: spriteObject))
        
        // test random value
        XCTAssertEqual(-0.17, sensor.convertToRaw(userInput: 83.0, for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_BRIGHTNESS", sensor.tag)
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
