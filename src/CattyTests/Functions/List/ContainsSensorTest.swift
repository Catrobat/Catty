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

class ContainsFunctionTest: XCTestCase {
    
    var function: ContainsFunction!
    var spriteObjectMock: SpriteObjectMock!
    
    override func setUp() {
        self.function = ContainsFunction()
        self.spriteObjectMock = SpriteObjectMock()
    }
    
    override func tearDown() {
        self.function = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "list name" as AnyObject, secondParameter: "invalidParameter" as AnyObject, spriteObject: SpriteObject()), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 100 as AnyObject, secondParameter: 2 as AnyObject, spriteObject: SpriteObject()), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil, spriteObject: SpriteObject()), accuracy: 0.0001)
    }
    
    func testValue() {
        let listName = "elements"
        self.spriteObjectMock.program.objectList = [1, 2, 3]
        // add list name
        
        XCTAssertEqual(1.0, function.value(firstParameter: listName as AnyObject, secondParameter: 2 as AnyObject, spriteObject: spriteObjectMock), accuracy: 0.0001)
        XCTAssertEqual(1.0, function.value(firstParameter: listName as AnyObject, secondParameter: 3 as AnyObject, spriteObject: spriteObjectMock), accuracy: 0.0001)
        XCTAssertEqual(0.0, function.value(firstParameter: listName as AnyObject, secondParameter: 10 as AnyObject, spriteObject: spriteObjectMock), accuracy: 0.0001)
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.string(defaultValue: "*list name*"), type(of: function).firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.number(defaultValue: 1), type(of: function).secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("CONTAINS", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("contains", type(of: function).name)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }
    
    func testIsIdempotent() {
        XCTAssertFalse(type(of: function).isIdempotent)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.math(position: type(of: function).position), type(of: function).formulaEditorSection())
    }
}
