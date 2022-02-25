/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

class JoinThreeStringsFunctionTest: XCTestCase {

    var function: JoinThreeStringsFunction!

    override func setUp() {
        super.setUp()
        function = JoinThreeStringsFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil, thirdParameter: nil))
    }

    func testValue() {
        XCTAssertEqual("right " + "now" + "test", function.value(firstParameter: "right " as AnyObject, secondParameter: "now" as AnyObject, thirdParameter: "test" as AnyObject))
        XCTAssertEqual("" + "" + "", function.value(firstParameter: "" as AnyObject, secondParameter: "" as AnyObject, thirdParameter: "" as AnyObject))
        XCTAssertEqual("Vann" + "Tile" + "Test", function.value(firstParameter: "Vann" as AnyObject, secondParameter: "Tile" as AnyObject, thirdParameter: "Test" as AnyObject))
    }

    func testFirstParameter() {
        XCTAssertEqual(.string(defaultValue: "hello "), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "world"), function.secondParameter())
    }

    func testThirdParameter() {
        XCTAssertEqual(.string(defaultValue: "!"), function.thirdParameter())
    }

    func testTag() {
        XCTAssertEqual("JOIN3", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionJoin, type(of: function).name)
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
        XCTAssertEqual(.functions(position: type(of: function).position, subsection: .texts), sections.first)
    }
}
