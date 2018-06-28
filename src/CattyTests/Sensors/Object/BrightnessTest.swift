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
    
    func testRawValue() {
        // test minimum value
        self.spriteNode.brightness = -1.0
        XCTAssertEqual(0, self.sensor.rawValue(for: self.spriteObject))
        
        // test maximum value
        self.spriteNode.brightness = 1.0
        XCTAssertEqual(100, self.sensor.rawValue(for: self.spriteObject))
        
        // test mean value
        self.spriteNode.brightness = 0.0
        XCTAssertEqual(50, self.sensor.rawValue(for: self.spriteObject))
        
        // test lower than minimum value
        self.spriteNode.brightness = -2.5
        XCTAssertEqual(0, self.sensor.rawValue(for: self.spriteObject))
        
        // test bigger than maximum value
        self.spriteNode.brightness = 22
        XCTAssertEqual(100, self.sensor.rawValue(for: self.spriteObject))
        
        // test random value
        self.spriteNode.brightness = 0.75
        XCTAssertEqual(87.5, self.sensor.rawValue(for: self.spriteObject))
        
    }
    
    func testStandardizeValue() {
        // test minimum value
        self.spriteNode.brightness = 0
        XCTAssertEqual(87.5, self.sensor.standardizeValue(for: self.spriteObject))
        
        // test maximum value
        self.spriteNode.brightness = 100
        
        // test mean value
        self.spriteNode.brightness = 50
        
        // test lower than minimum value
        self.spriteNode.brightness = -10
        
        // test bigger than maximum value
        self.spriteNode.brightness = 180
        
        // test random value
        self.spriteNode.brightness = 83
    }
}
