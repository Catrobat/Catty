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

final class BackgroundNameSensorTest: XCTestCase {
    
    var spriteObject: SpriteObjectMock!
    var spriteNode: CBSpriteNodeMock!
    let sensor = BackgroundNameSensor.self
    
    override func setUp() {
        self.spriteObject = SpriteObjectMock()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
    }
    
    override func tearDown() {
        self.spriteObject = nil
    }
    
    func testDefaultRawValue() {
        spriteNode.currentLook = nil
        XCTAssertEqual(sensor.defaultStringValue, sensor.rawValue(for: spriteObject))
        
        spriteNode = nil
        XCTAssertEqual(sensor.defaultStringValue, sensor.rawValue(for: spriteObject))
    }
    
    func testRawValue() {
        spriteObject.lookList = [Look(name: "first", andPath: "test1.png"),
                                 Look(name: "second", andPath: "test2.png"),
                                 Look(name: "third", andPath: "test3.png")]
        
        spriteNode.currentLook = (spriteObject.lookList[0] as! Look)
        XCTAssertEqual("first", sensor.rawValue(for: spriteObject))
        
        spriteNode.currentLook = (spriteObject.lookList[1] as! Look)
        XCTAssertEqual("second", sensor.rawValue(for: spriteObject))
        
        spriteNode.currentLook = (spriteObject.lookList[2] as! Look)
        XCTAssertEqual("third", sensor.rawValue(for: spriteObject))
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual("Starry night", sensor.convertToStandardized(rawValue: "Starry night", for: spriteObject))
        XCTAssertEqual("Gallifrey", sensor.convertToStandardized(rawValue: "Gallifrey", for: spriteObject))
        XCTAssertEqual("Milky Way", sensor.convertToStandardized(rawValue: "Milky Way", for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("OBJECT_BACKGROUND_NAME", sensor.tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, sensor.requiredResource)
    }
    
    func testShowInFormulaEditor() {
        spriteObject.background = true
        XCTAssertTrue(sensor.showInFormulaEditor(for: spriteObject))
        
        spriteObject.background = false
        XCTAssertFalse(sensor.showInFormulaEditor(for: spriteObject))
    }
    
    func testFormulaEditorSection() {
        spriteObject.background = false
        XCTAssertEqual(.hidden, sensor.formulaEditorSection(for: spriteObject))
        
        spriteObject.background = true
        XCTAssertEqual(.object(position: sensor.position), sensor.formulaEditorSection(for: spriteObject))
    }
}
