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

final class FingerYSensorTest: XCTestCase {
    
    var touchManager: TouchManagerMock!
    var sensor: FingerYSensor!
    
    let screenWidth = 500
    let screenHeight = 500
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    
    override func setUp() {
        self.touchManager = TouchManagerMock()
        self.sensor = FingerYSensor { [weak self] in self?.touchManager }
        
        self.spriteObject = SpriteObject()
        self.spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        self.spriteNode.mockedScene = CBScene(size: CGSize(width: screenWidth, height: screenHeight))
    }
    
    override func tearDown() {
        self.sensor = nil
        self.touchManager = nil
        self.spriteNode = nil
    }
    
    func testDefaultRawValue() {
        let sensor = FingerYSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        self.touchManager.lastTouch = CGPoint(x: 105, y: 201)
        XCTAssertEqual(201, self.sensor.rawValue())
        
        self.touchManager.lastTouch = CGPoint(x: 45, y: -13)
        XCTAssertEqual(-13, self.sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        self.touchManager.lastTouch = CGPoint(x: 200, y: 200) // a random point to mock the screen touching
        
        XCTAssertEqual(Double(screenHeight/2), self.sensor.convertToStandardized(rawValue: 0, for: spriteObject))
        XCTAssertEqual(Double(screenHeight/2) - 100, self.sensor.convertToStandardized(rawValue: 100, for: spriteObject))
        XCTAssertEqual(Double(screenHeight/2) - 333, self.sensor.convertToStandardized(rawValue: 333, for: spriteObject))
        XCTAssertEqual(Double(screenHeight/2) + 333, self.sensor.convertToStandardized(rawValue: -333, for: spriteObject))
    }
    
    func testTag() {
        XCTAssertEqual("FINGER_Y", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}
