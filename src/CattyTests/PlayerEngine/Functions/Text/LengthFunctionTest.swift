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

class LengthFunctionTest: XCTestCase {

    var function: LengthFunction!

    override func setUp() {
        super.setUp()
        function = LengthFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: nil), accuracy: Double.epsilon)
    }

    func testValue() {
        var text = "Live not on evil deed, live not on evil."
        XCTAssertEqual(Double(text.count), function.value(parameter: text as AnyObject), accuracy: Double.epsilon)

        text = "palindrome"
        XCTAssertEqual(Double(text.count), function.value(parameter: text as AnyObject), accuracy: Double.epsilon)

        text = ""
        XCTAssertEqual(Double(text.count), function.value(parameter: text as AnyObject), accuracy: Double.epsilon)

        let number = 100
        XCTAssertEqual(Double(String(number).count), function.value(parameter: number as AnyObject), accuracy: Double.epsilon)

        text = "inf"
        XCTAssertEqual(Double(text.count), function.value(parameter: Double.infinity as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.string(defaultValue: "hello world"), function.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("LENGTH", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionLength, type(of: function).name)
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
