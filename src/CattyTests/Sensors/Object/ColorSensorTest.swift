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

final class ColorSensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor = ColorSensor.self
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
    }
    
    override func tearDown() {
        self.spriteObject = nil
    }
    
    func testDefaultRawValue() {
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.defaultRawValue, sensor.rawValue(for: spriteObject), accuracy: 0.0001)
    }
    
    func testRawValue() {
        self.spriteNode.ciHueAdjust = 0.0
        XCTAssertEqual(0, sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        self.spriteNode.ciHueAdjust = -60
        XCTAssertEqual(-60, sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        self.spriteNode.ciHueAdjust = 210
        XCTAssertEqual(210, sensor.rawValue(for: spriteObject), accuracy: 0.0001)
    }
    
    func testSetRawValue() {
        let expectedRawValue = sensor.convertToRaw(userInput: 50, for: spriteObject)
        sensor.setRawValue(userInput: 50, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.ciHueAdjust), accuracy: 0.001)
    }
    
    func testConvertToStandarized() {
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: Double.pi, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(199.99, sensor.convertToStandardized(rawValue: 1.9999 * Double.pi, for: spriteObject), accuracy: 0.0001)
    }
    
    func testConvertToRaw() {
        XCTAssertEqual(0, sensor.convertToRaw(userInput: 0, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi, sensor.convertToRaw(userInput: 100, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi / 4, sensor.convertToRaw(userInput: 25, for: spriteObject), accuracy: 0.0001)
        
        // outside the range
        XCTAssertEqual(0, sensor.convertToRaw(userInput: 200, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi / 2, sensor.convertToRaw(userInput: 250, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(0, sensor.convertToRaw(userInput: 400, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi, sensor.convertToRaw(userInput: -100, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi, sensor.convertToRaw(userInput: -300, for: spriteObject), accuracy: 0.0001)
        
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_COLOR", sensor.tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, sensor.requiredResource)
    }
   
    func testFormulaEditorSection() {
        XCTAssertEqual(.object(position: sensor.position), sensor.formulaEditorSection(for: spriteObject))
    }
}
