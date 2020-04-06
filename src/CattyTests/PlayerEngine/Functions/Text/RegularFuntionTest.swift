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

class RegularFunctionTest: XCTestCase {

    var function: RegularFunction!

    override func setUp() {
        super.setUp()
        function = RegularFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "([0-9]{10})" as AnyObject, secondParameter: "I am a panda" as AnyObject))
    }

    func testValue() {
        XCTAssertEqual("9999999999", function.value(firstParameter: "([0-9]{10})" as AnyObject, secondParameter: "My number is 9999999999" as AnyObject))

        XCTAssertEqual("I am", function.value(firstParameter: "([^ .]+ [^ .]+) a?" as AnyObject, secondParameter: "I am a panda" as AnyObject))

        XCTAssertEqual("I", function.value(firstParameter: "([^ .]+) am? ([a-z]+)" as AnyObject, secondParameter: "I am a panda" as AnyObject))

        XCTAssertEqual("panda", function.value(firstParameter: " a? ([a-z]{5}) ([^ .]+)" as AnyObject, secondParameter: "I am a panda bro" as AnyObject))

        XCTAssertEqual("bro", function.value(firstParameter: " am? a [^ .]+ ([a-z]+)" as AnyObject, secondParameter: "I am a panda bro" as AnyObject))

        XCTAssertEqual("", function.value(firstParameter: " am? a [^ .]+ ([a-z]+)" as AnyObject, secondParameter: "My number is 9999999999" as AnyObject))

        XCTAssertEqual("The value “([0-9]{10}” is invalid.", function.value(firstParameter: "([0-9]{10}" as AnyObject, secondParameter: "My number is 9999999999" as AnyObject))
    }

    func testFirstParameter() {
        XCTAssertEqual(.string(defaultValue: " an? ([^ .]+)"), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "I am a panda"), function.secondParameter())
    }

    func testTag() {
        XCTAssertEqual("REGEX", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("regex", type(of: function).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertTrue(type(of: function).isIdempotent)
    }

    func testFormulaEditorSections() {
        let sections = function.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.math(position: type(of: function).position), sections.first)
    }
}
