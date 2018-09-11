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

final class FingerXSensorTest: XCTestCase {
    
    var touchManager: TouchManagerMock!
    var sensor: FingerXSensor!
    
    let screenWidth = 500
    let screenHeight = 500
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    
    override func setUp() {
        touchManager = TouchManagerMock()
        sensor = FingerXSensor { [weak self] in self?.touchManager }
        
        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteNode.mockedScene = SceneBuilder(program: ProgramMock(width:CGFloat(screenWidth), andHeight: CGFloat(screenHeight))).build()
    }
    
    override func tearDown() {
        sensor = nil
        touchManager = nil
        spriteNode = nil
    }
    
    func testDefaultRawValue() {
        let sensor = FingerXSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        touchManager.lastTouch = CGPoint(x: 15, y: 20)
        XCTAssertEqual(15, sensor.rawValue())
        
        touchManager.lastTouch = CGPoint(x: -130, y: 29)
        XCTAssertEqual(-130, sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        touchManager.lastTouch = CGPoint(x: 100, y: 100) // a random point to mock the screen touching
        
        XCTAssertEqual(Double(0 - screenWidth / 2), sensor.convertToStandardized(rawValue: 0, for: spriteObject))
        XCTAssertEqual(Double(100 - screenWidth / 2), sensor.convertToStandardized(rawValue: 100, for: spriteObject))
        XCTAssertEqual(Double(-187 - screenWidth / 2), sensor.convertToStandardized(rawValue: -187, for: spriteObject))
        XCTAssertEqual(Double(187 - screenWidth / 2), sensor.convertToStandardized(rawValue: 187, for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("FINGER_X", sensor.tag())
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
