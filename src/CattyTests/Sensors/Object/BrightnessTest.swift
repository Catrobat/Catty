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

final class BrightnessTest: XCTestCase {
    
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
        XCTAssertEqual(2, sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.mockedBrightness = -2
        XCTAssertEqual(-2, sensor.rawValue(for: self.spriteObject))
    }
    
    func testStandardizedValue() {
        
    }
    
    func testConvertRawToStandarized() {
        // test minimum value
        self.spriteNode.mockedBrightness = -1.0
        XCTAssertEqual(0, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test maximum value
        self.spriteNode.mockedBrightness = 1.0
        XCTAssertEqual(100, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test mean value
        self.spriteNode.mockedBrightness = 0.0
        XCTAssertEqual(50, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test lower than minimum value
        self.spriteNode.mockedBrightness = -2.5
        XCTAssertEqual(0, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test bigger than maximum value
        self.spriteNode.mockedBrightness = 22
        XCTAssertEqual(100, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test random value
        self.spriteNode.mockedBrightness = 0.75
        XCTAssertEqual(87.5, BrightnessSensor.convertRawToStandarized(rawValue: Double(self.spriteNode.mockedBrightness!)))
        
    }
    
    func testConvertStandardizedToRaw() {
        // test minimum value
        self.spriteNode.mockedBrightness = 0
        XCTAssertEqual(-1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test maximum value
        self.spriteNode.mockedBrightness = 100
        XCTAssertEqual(1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test mean value
        self.spriteNode.mockedBrightness = 50
        XCTAssertEqual(0, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test lower than minimum value
        self.spriteNode.mockedBrightness = -10
        XCTAssertEqual(-1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test bigger than maximum value
        self.spriteNode.mockedBrightness = 180
        XCTAssertEqual(1, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
        
        // test random value
        self.spriteNode.mockedBrightness = 83
        XCTAssertEqual(0.66, BrightnessSensor.convertStandarizedToRaw(standardizedValue: Double(self.spriteNode.mockedBrightness!)))
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
