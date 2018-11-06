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

class JoinFunctionTest: XCTestCase {

    var function: JoinFunction!

    override func setUp() {
        function = JoinFunction()
    }

    override func tearDown() {
        function = nil
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil))
    }

    func testValue() {
        XCTAssertEqual("right " + "now", function.value(firstParameter: "right " as AnyObject, secondParameter: "now" as AnyObject))
        XCTAssertEqual("" + "", function.value(firstParameter: "" as AnyObject, secondParameter: "" as AnyObject))
        XCTAssertEqual("Vann" + "Tile", function.value(firstParameter: "Vann" as AnyObject, secondParameter: "Tile" as AnyObject))

        XCTAssertEqual("21 Pilots", function.value(firstParameter: 21 as AnyObject, secondParameter: " Pilots" as AnyObject))
        XCTAssertEqual("21.5 Pilots", function.value(firstParameter: 21.5 as AnyObject, secondParameter: " Pilots" as AnyObject))

        XCTAssertEqual("2130", function.value(firstParameter: 21 as AnyObject, secondParameter: 30 as AnyObject))
        XCTAssertEqual("210.5", function.value(firstParameter: 21 as AnyObject, secondParameter: 0.5 as AnyObject))

        XCTAssertEqual("XCode 9", function.value(firstParameter: "XCode " as AnyObject, secondParameter: 9 as AnyObject))
        XCTAssertEqual("XCode 9.4", function.value(firstParameter: "XCode " as AnyObject, secondParameter: 9.4 as AnyObject))
        XCTAssertEqual("limit inf", function.value(firstParameter: "limit " as AnyObject, secondParameter: Double.infinity as AnyObject))
    }

    func testFirstParameter() {
        XCTAssertEqual(.string(defaultValue: "hello "), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "world"), function.secondParameter())
    }

    func testTag() {
        XCTAssertEqual("JOIN", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("join", type(of: function).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertTrue(type(of: function).isIdempotent)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.math(position: type(of: function).position), function.formulaEditorSection())
    }
}
