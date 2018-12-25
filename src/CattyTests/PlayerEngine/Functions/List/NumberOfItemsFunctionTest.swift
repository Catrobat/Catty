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

class NumberOfItemsFunctionTest: XCTestCase {

    var function: NumberOfItemsFunction!

    override func setUp() {
        super.setUp()
        function = NumberOfItemsFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: -2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: nil), accuracy: Double.epsilon)

        let userVariable = UserVariable()
        userVariable.isList = true
        userVariable.value = nil

        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: userVariable as AnyObject), accuracy: Double.epsilon)
    }

    func testValue() {

        // number list
        let userVariableNumber = UserVariable()
        userVariableNumber.name = "myListNumber"
        userVariableNumber.isList = true
        userVariableNumber.value = [1, 5, -7]

        XCTAssertEqual(Double(3), function.value(parameter: userVariableNumber as AnyObject), accuracy: Double.epsilon)

        // string list
        let userVariableString = UserVariable()
        userVariableString.name = "myListString"
        userVariableString.isList = true
        userVariableString.value = ["a", "b", "c"]

        XCTAssertEqual(Double(3), function.value(parameter: userVariableString as AnyObject), accuracy: Double.epsilon)

        // empty list
        let userVariableEmpty = UserVariable()
        userVariableEmpty.name = "myListEmpty"
        userVariableEmpty.isList = true
        userVariableEmpty.value = []
        XCTAssertEqual(Double(0), function.value(parameter: userVariableEmpty as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.list(defaultValue: "list name"), function.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("NUMBER_OF_ITEMS", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("number_of_items", type(of: function).name)
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
