/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

    override func setUp() {
        super.setUp()
        function = ElementFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "list name" as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 2 as AnyObject, secondParameter: -3 as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: nil, secondParameter: nil) as! String)

        let userVariableNumber = UserList(name: "testName")

        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 2 as AnyObject, secondParameter: userVariableNumber as AnyObject) as! String)
    }

    func testEmptyList() {
        let emptyList = UserList(name: "testName")

        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 0 as AnyObject, secondParameter: emptyList as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 1 as AnyObject, secondParameter: emptyList as AnyObject) as! String)
    }

    func testValue() {
        // number list
        let userListNumber = UserList(name: "myListNumber")
        userListNumber.value.append(1)
        userListNumber.value.append(5)
        userListNumber.value.append(-7)

        XCTAssertEqual(5, function.value(firstParameter: 2 as AnyObject, secondParameter: userListNumber as AnyObject) as! NSNumber)
        XCTAssertEqual(-7, function.value(firstParameter: 3 as AnyObject, secondParameter: userListNumber as AnyObject) as! NSNumber)

        // out of bounds
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 0 as AnyObject, secondParameter: userListNumber as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 4 as AnyObject, secondParameter: userListNumber as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 10 as AnyObject, secondParameter: userListNumber as AnyObject) as! String)

        // string list
        let userListString = UserList(name: "myListString")
        userListString.value.append("a")
        userListString.value.append("b")
        userListString.value.append("c")

        XCTAssertEqual("b", function.value(firstParameter: 2 as AnyObject, secondParameter: userListString as AnyObject) as! String)
        XCTAssertEqual("a", function.value(firstParameter: 1 as AnyObject, secondParameter: userListString as AnyObject) as! String)

        // out of bounds
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: -1 as AnyObject, secondParameter: userListString as AnyObject) as! String)
        XCTAssertEqual(type(of: function).defaultValue as! String, function.value(firstParameter: 10 as AnyObject, secondParameter: userListString as AnyObject) as! String)
    }

    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 1), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.list(defaultValue: "list name"), function.secondParameter())
    }

    func testTag() {
        XCTAssertEqual("LIST_ITEM", type(of: function).tag)
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

    func testFormulaEditorSections() {
        let sections = function.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.math(position: type(of: function).position), sections.first)
    }
}
