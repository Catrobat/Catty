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

class MultiFingerTouchedFunctionTests: XCTestCase {
    
    var touchManager: TouchManagerMock!
    var function: MultiFingerTouchedFunction!
    
    let screenWidth = 500
    let screenHeight = 500
    
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    
    override func setUp() {
        touchManager = TouchManagerMock()
        function = MultiFingerTouchedFunction { [weak self] in self?.touchManager }
        
        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteNode.mockedScene = SceneBuilder(program: ProgramMock(width:CGFloat(screenWidth), andHeight: CGFloat(screenHeight))).build()
    }
    
    override func tearDown() {
        touchManager = nil
        function = nil
        spriteNode = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: nil), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: 0 as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: 1 as AnyObject), accuracy: 0.0001)
        
        function = MultiFingerTouchedFunction { nil }
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: 1 as AnyObject), accuracy: 0.0001)
    }
    
    func testValue() {
        let firstTouch = CGPoint(x: 15, y: 20)
        let secondTouch = CGPoint(x: 30, y: 45)
        touchManager.touches = [firstTouch]
        
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: 0 as AnyObject), accuracy: 0.0001)
        
        touchManager.isScreenTouched = false
        XCTAssertEqual(0.0, function.value(parameter: 1 as AnyObject), accuracy: 0.0001)
        
        touchManager.isScreenTouched = true
        XCTAssertEqual(1.0, function.value(parameter: 1 as AnyObject), accuracy: 0.0001)
        
        touchManager.touches = [firstTouch, secondTouch]
        XCTAssertEqual(0.0, function.value(parameter: 1 as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(1.0, function.value(parameter: 2 as AnyObject), accuracy: 0.0001)
        
        touchManager.isScreenTouched = false
        XCTAssertEqual(0.0, function.value(parameter: 2 as AnyObject), accuracy: 0.0001)
    }
    
    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 1), function.firstParameter())
    }
    
    func testTag() {
        XCTAssertEqual("MULTI_FINGER_TOUCHED", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual(kUIFESensorFingerTouched, type(of: function).name)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: function).requiredResource)
    }
    
    func testIsIdempotent() {
        XCTAssertFalse(type(of: function).isIdempotent)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: function).position), function.formulaEditorSection())
    }
}
