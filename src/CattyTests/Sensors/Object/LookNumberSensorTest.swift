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

final class LookNumberSensorTest: XCTestCase {
    
    var spriteObject: SpriteObjectMock!
    var spriteNode: CBSpriteNodeMock!
    var sensor: LookNumberSensor!
    
    override func setUp() {
        self.spriteObject = SpriteObjectMock()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        
        self.sensor = LookNumberSensor()
    }
    
    override func tearDown() {
        self.spriteObject = nil
        self.sensor = nil
    }
    
    func testDefaultRawValue() {
        self.spriteNode.currentLook = nil
        XCTAssertEqual(LookNumberSensor.defaultRawValue, self.sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode = nil
        XCTAssertEqual(LookNumberSensor.defaultRawValue, self.sensor.rawValue(for: self.spriteObject))
        
    }
    
    func testRawValue() {
        self.spriteObject.lookList = [Look(name: "first", andPath: "test1.png"),
                                      Look(name: "second", andPath: "test2.png"),
                                      Look(name: "third", andPath: "test3.png")]
        
        self.spriteNode.currentLook = (self.spriteObject.lookList[0] as! Look)
        XCTAssertEqual(0, self.sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.currentLook = (self.spriteObject.lookList[1] as! Look)
        XCTAssertEqual(1, self.sensor.rawValue(for: self.spriteObject))
        
        self.spriteNode.currentLook = (self.spriteObject.lookList[2] as! Look)
        XCTAssertEqual(2, self.sensor.rawValue(for: self.spriteObject))
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(1, self.sensor.convertToStandardized(rawValue: 0))
        XCTAssertEqual(2, self.sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(3, self.sensor.convertToStandardized(rawValue: 2))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_LOOK_NUMBER", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        spriteObject.background = true
        XCTAssertFalse(sensor.showInFormulaEditor(for: self.spriteObject))
        
        spriteObject.background = false
        XCTAssertTrue(sensor.showInFormulaEditor(for: self.spriteObject))
    }
}
