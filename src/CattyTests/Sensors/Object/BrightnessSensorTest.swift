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
    var sensor: BrightnessSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = BrightnessSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testDefaultRawValue() {
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(BrightnessSensor.defaultRawValue, sensor.rawValue(for: self.spriteObject))
    }
    
    func testRawValue() {
        self.spriteNode.ciBrightness = -1.0
        XCTAssertEqual(-1.0, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.ciBrightness = 1.0
        XCTAssertEqual(1.0, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.ciBrightness = 0.5
        XCTAssertEqual(0.5, sensor.rawValue(for: self.spriteObject))
    }
    
    func testConvertToStandardized() {
        // test minimum value
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -1.0))
        
        // test maximum value
        XCTAssertEqual(200, sensor.convertToStandardized(rawValue: 1.0))
        
        // test mean value
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 0.0))
        
        // test lower than minimum value
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -2.5))
        
        // test bigger than maximum value
        XCTAssertEqual(200, sensor.convertToStandardized(rawValue: 22.0))
        
        // test random value
        XCTAssertEqual(175, sensor.convertToStandardized(rawValue: 0.75))
    }
    
    func testConvertToRaw() {
        // test minimum value
        XCTAssertEqual(-1, sensor.convertToRaw(standardizedValue: 0.0))
        
        // test maximum value
        XCTAssertEqual(1, sensor.convertToRaw(standardizedValue: 200.0))
        
        // test mean value
        XCTAssertEqual(0, sensor.convertToRaw(standardizedValue: 100.0))
        
        // test lower than minimum value
        XCTAssertEqual(-1, sensor.convertToRaw(standardizedValue: -10.0))
        
        // test bigger than maximum value
        XCTAssertEqual(1, sensor.convertToRaw(standardizedValue: 280.0))
        
        // test random value
        XCTAssertEqual(-0.17, sensor.convertToRaw(standardizedValue: 83.0))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_BRIGHTNESS", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}