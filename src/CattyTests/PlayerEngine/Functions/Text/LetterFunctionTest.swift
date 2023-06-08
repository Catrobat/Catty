/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class LetterFunctionTest: XCTestCase {

    var function: LetterFunction!

    override func setUp() {
        super.setUp()
        function = LetterFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "hello" as AnyObject))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: 10 as AnyObject))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil))
    }

    func testValue() {
        // string
        var text = "amazing"
        var number = 3
        var index = text.index(text.startIndex, offsetBy: number - 1)
        XCTAssertEqual(String(text[index]), function.value(firstParameter: number as AnyObject, secondParameter: text as AnyObject))
        XCTAssertEqual(String(text[index]), function.value(firstParameter: 2 + 1 as AnyObject, secondParameter: text as AnyObject))

        text = "great!"
        number = 6
        index = text.index(text.startIndex, offsetBy: number - 1)
        XCTAssertEqual(String(text[index]), function.value(firstParameter: number as AnyObject, secondParameter: text as AnyObject))

        // numbers
        let textNumber = 100
        text = String(textNumber)
        number = 2
        index = text.index(text.startIndex, offsetBy: number - 1)
        XCTAssertEqual(String(text[index]), function.value(firstParameter: number as AnyObject, secondParameter: textNumber as AnyObject))

        // infinity
        text = "inf"
        number = 1
        index = text.index(text.startIndex, offsetBy: number - 1)
        XCTAssertEqual(String(text[index]), function.value(firstParameter: number as AnyObject, secondParameter: Double.infinity as AnyObject))

        // outside of boundaries test
        text = "hello"
        number = 10
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: number as AnyObject, secondParameter: text as AnyObject))

        text = "summer"
        number = -2
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: number as AnyObject, secondParameter: text as AnyObject))
    }

    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 1), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "hello world"), function.secondParameter())
    }

    func testTag() {
        XCTAssertEqual("LETTER", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionLetter, type(of: function).name)
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
