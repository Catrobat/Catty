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

class ElementFunctionTest: XCTestCase {
    
    var function: ElementFunction!
    var spriteObjectMock: SpriteObjectMock!
    
    override func setUp() {
        self.function = ElementFunction()
        self.spriteObjectMock = SpriteObjectMock()
    }
    
    override func tearDown() {
        self.function = nil
        self.spriteObjectMock = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "list name" as AnyObject, spriteObject: SpriteObject()))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 2 as AnyObject, secondParameter: -3 as AnyObject, spriteObject: SpriteObject()))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil, spriteObject: SpriteObject()))
    }
    
    func testValue() {
        let program = Program()
        spriteObjectMock.program = program
        
        // number list
        let userVariableNumber = UserVariable()
        userVariableNumber.name = "myListNumber"
        userVariableNumber.isList = true
        program.variables.programListOfLists.add(userVariableNumber)
        program.variables.add(toUserList: userVariableNumber, value: 1)
        program.variables.add(toUserList: userVariableNumber, value: 5)
        program.variables.add(toUserList: userVariableNumber, value: -7)
        
        XCTAssertEqual(String(5), function.value(firstParameter: 2 as AnyObject, secondParameter: userVariableNumber.name as AnyObject, spriteObject: spriteObjectMock))
        XCTAssertEqual(String(-7), function.value(firstParameter: 3 as AnyObject, secondParameter: userVariableNumber.name as AnyObject, spriteObject: spriteObjectMock))
        
        // out of bounds
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 0 as AnyObject, secondParameter: userVariableNumber.name as AnyObject, spriteObject: spriteObjectMock))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 10 as AnyObject, secondParameter: userVariableNumber.name as AnyObject, spriteObject: spriteObjectMock))
        
        // string list
        let userVariableString = UserVariable()
        userVariableString.name = "myListString"
        userVariableString.isList = true
        
        program.variables.programListOfLists.add(userVariableString)
        program.variables.add(toUserList: userVariableString, value: "a")
        program.variables.add(toUserList: userVariableString, value: "b")
        program.variables.add(toUserList: userVariableString, value: "c")
        
        XCTAssertEqual("b", function.value(firstParameter: 2 as AnyObject, secondParameter: userVariableString.name as AnyObject, spriteObject: spriteObjectMock))
        XCTAssertEqual("a", function.value(firstParameter: 1 as AnyObject, secondParameter: userVariableString.name as AnyObject, spriteObject: spriteObjectMock))
        
        // out of bounds
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: -1 as AnyObject, secondParameter: userVariableString.name as AnyObject, spriteObject: spriteObjectMock))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 10 as AnyObject, secondParameter: userVariableString.name as AnyObject, spriteObject: spriteObjectMock))
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 1), type(of: function).firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "*list name*"), type(of: function).secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("ELEMENT", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("element", type(of: function).name)
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
