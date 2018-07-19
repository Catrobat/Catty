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

final class LayerSensorTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: LayerSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = LayerSensor()
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
        // background like on Android
        self.spriteNode.zPosition = -1
        XCTAssertEqual(-1, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        // background raw on iOS
        self.spriteNode.zPosition = 0
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
        
        // third layer
        self.spriteNode.zPosition = 3
        XCTAssertEqual(3, self.sensor.rawValue(for: spriteObject), accuracy: 0.0001)
    }
    
    func testConvertToStandarized() {
        // background
        XCTAssertEqual(-1, self.sensor.convertToStandardized(rawValue: 0), accuracy: 0.001)
        
        // objects
        XCTAssertEqual(1, self.sensor.convertToStandardized(rawValue: 1), accuracy: 0.001)
        XCTAssertEqual(2, self.sensor.convertToStandardized(rawValue: 2), accuracy: 0.001)
    }
    
    func testConvertToRaw() {
        // can not be set for background
        XCTAssertEqual(1, self.sensor.convertToRaw(userInput: -1), accuracy: 0.001)
        XCTAssertEqual(1, self.sensor.convertToRaw(userInput: 0), accuracy: 0.001)
        
        // objects
        XCTAssertEqual(3, self.sensor.convertToRaw(userInput: 3), accuracy: 0.001)
        XCTAssertEqual(4, self.sensor.convertToRaw(userInput: 4), accuracy: 0.001)
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_LAYER", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}
