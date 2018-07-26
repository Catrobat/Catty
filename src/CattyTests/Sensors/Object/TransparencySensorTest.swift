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

final class TransparencySensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    let sensor = TransparencySensor.self
    
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
        spriteNode.alpha = 0.0
        XCTAssertEqual(0, sensor.rawValue(for: spriteObject))
        
        spriteNode.alpha = 1.0
        XCTAssertEqual(1.0, sensor.rawValue(for: spriteObject))
        
        spriteNode.alpha = 0.5
        XCTAssertEqual(0.5, sensor.rawValue(for: spriteObject))
    }
    
    func testSetRawValue() {
        let expectedRawValue = sensor.convertToRaw(userInput: 50, for: spriteObject)
        sensor.setRawValue(userInput: 50, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.alpha), accuracy: 0.001)
    }
    
    func testConvertToStandarized() {
        // test minimum value of transparency on iOS
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 1.0, for: spriteObject))
        
        // test maximum value of transparency on iOS
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 0.0, for: spriteObject))
        
        // test mean value of transparency on iOS
        XCTAssertEqual(50, sensor.convertToStandardized(rawValue: 0.5, for: spriteObject))
        
        // test lower than minimum value of transparency on iOS
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 2.5, for: spriteObject))
        
        // test bigger than maximum value of transparency on iOS
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: -22.0, for: spriteObject))
        
        // test random value
        XCTAssertEqual(87.5, sensor.convertToStandardized(rawValue: 0.125, for: spriteObject))
    }
    
    func testConvertToRaw() {
        // test minimum value of transparency on Android
        XCTAssertEqual(1.0, sensor.convertToRaw(userInput: 0.0, for: spriteObject))
        
        // test maximum value of transparency on Android
        XCTAssertEqual(0.0, sensor.convertToRaw(userInput: 100.0, for: spriteObject))
        
        // test mean value of transparency on Android
        XCTAssertEqual(0.5, sensor.convertToRaw(userInput: 50.0, for: spriteObject))
        
        // test lower than minimum value of transparency on Android
        XCTAssertEqual(1.0, sensor.convertToRaw(userInput: -10.0, for: spriteObject))
        
        // test bigger than maximum value of transparency on Android
        XCTAssertEqual(0.0, sensor.convertToRaw(userInput: 180.0, for: spriteObject))
        
        // test random value of transparency on Android
        XCTAssertEqual(0.34, sensor.convertToRaw(userInput: 66.0, for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_GHOSTEFFECT", sensor.tag)
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
