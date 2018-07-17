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
    var sensor: ColorSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = ColorSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testDefaultRawValue() {
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(for: self.spriteObject), accuracy: 0.0001)
    }
    
    func testRawValue() {
        self.spriteNode.ciHueAdjust = 0.0
        XCTAssertEqual(0, sensor.rawValue(for: self.spriteObject), accuracy: 0.0001)
        
        self.spriteNode.ciHueAdjust = 60
        XCTAssertEqual(60, sensor.rawValue(for: self.spriteObject), accuracy: 0.0001)
        
        self.spriteNode.ciHueAdjust = 200
        XCTAssertEqual(200, sensor.rawValue(for: self.spriteObject), accuracy: 0.0001)
    }
    
    func testConvertToStandarized() {
        // dark blue start
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // purple start
        XCTAssertEqual(30, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // pink start
        XCTAssertEqual(50, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // red start
        XCTAssertEqual(80, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // orange start
        XCTAssertEqual(90, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // yellow start
        XCTAssertEqual(105, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // green start
        XCTAssertEqual(130, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // turquoise start
        XCTAssertEqual(160, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // light blue start
        XCTAssertEqual(170, sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        
        // the end of the current color cycle
        XCTAssertEqual(199.99, sensor.convertToStandardized(rawValue: 199.99), accuracy: 0.0001)
        
        // next color cycle
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 200), accuracy: 0.0001)
    }
    
    func testConvertToRaw() {
        
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_COLOR", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}
