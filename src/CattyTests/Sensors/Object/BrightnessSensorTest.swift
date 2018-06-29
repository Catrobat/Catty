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
    
    func testDefaultValue() {
        self.spriteObject.spriteNode = nil
        XCTAssertEqual(sensor.rawValue(for: self.spriteObject), BrightnessSensor.defaultValue)
        XCTAssertEqual(sensor.standardizedValue(for: self.spriteObject), BrightnessSensor.defaultValue)
    }
    
    func testRawValue() {
        self.spriteNode.mockedBrightness = -1.0
        XCTAssertEqual(-1.0, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.mockedBrightness = 1.0
        XCTAssertEqual(1.0, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.mockedBrightness = 0.5
        XCTAssertEqual(0.5, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.mockedBrightness = 2
        XCTAssertEqual(1, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.mockedBrightness = -2
        XCTAssertEqual(-1, sensor.rawValue(for: self.spriteObject))
    }
    
    func testStandardizedValue() {
        self.spriteNode.mockedBrightness = 0.78
        XCTAssertEqual(sensor.standardizedValue(for: spriteObject), BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
    }
    
    func testConvertRawToStandarized() {
        // test minimum value
        XCTAssertEqual(0, BrightnessSensor.convertRawToStandarized(rawValue: -1.0))
        
        // test maximum value
        XCTAssertEqual(100, BrightnessSensor.convertRawToStandarized(rawValue: 1.0))
        
        // test mean value
        XCTAssertEqual(50, BrightnessSensor.convertRawToStandarized(rawValue: 0.0))
        
        // test lower than minimum value
        XCTAssertEqual(0, BrightnessSensor.convertRawToStandarized(rawValue: -2.5))
        
        // test bigger than maximum value
        XCTAssertEqual(100, BrightnessSensor.convertRawToStandarized(rawValue: 22.0))
        
        // test random value
        XCTAssertEqual(87.5, BrightnessSensor.convertRawToStandarized(rawValue: 0.75))
        
    }
    
    func testConvertStandardizedToRaw() {
        // test minimum value
        XCTAssertEqual(-1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: 0.0))
        
        // test maximum value
        XCTAssertEqual(1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: 100.0))
        
        // test mean value
        XCTAssertEqual(0, BrightnessSensor.convertStandarizedToRaw(standardizedValue: 50.0))
        
        // test lower than minimum value
        XCTAssertEqual(-1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: -10.0))
        
        // test bigger than maximum value
        XCTAssertEqual(1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: 180.0))
        
        // test random value
        XCTAssertEqual(0.66, BrightnessSensor.convertStandarizedToRaw(standardizedValue: 83.0))
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
