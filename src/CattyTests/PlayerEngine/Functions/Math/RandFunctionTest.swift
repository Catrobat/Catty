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

class RandFunctionTest: XCTestCase {

    var function: RandFunction!

    override func setUp() {
        super.setUp()
        function = RandFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: nil), accuracy: Double.epsilon)
    }

    func testValue() {
        let firstCall = function.value(firstParameter: 10 as AnyObject, secondParameter: 100 as AnyObject)
        XCTAssertGreaterThanOrEqual(firstCall, 10)
        XCTAssertLessThanOrEqual(firstCall, 100)
        XCTAssertEqual(Double(Int(firstCall)), firstCall, accuracy: Double.epsilon)

        let secondCall = function.value(firstParameter: 100 as AnyObject, secondParameter: 10 as AnyObject)
        XCTAssertGreaterThanOrEqual(secondCall, 10)
        XCTAssertLessThanOrEqual(firstCall, 100)
        XCTAssertEqual(Double(Int(secondCall)), secondCall, accuracy: Double.epsilon)

        // there are 1 / [(max - min) + 1] ^ 2 chances of having the same number twice
        XCTAssertNotEqual(firstCall, secondCall)

        let float = function.value(firstParameter: 10.5 as AnyObject, secondParameter: 20.8 as AnyObject)
        XCTAssertGreaterThanOrEqual(float, 10.5)
        XCTAssertLessThanOrEqual(float, 20.8)
        XCTAssertNotEqual(Double(Int(float)), float)
    }

    func testValueBetweenZeroAndOne() {
        var results = [Double]()

        for _ in 1..<50 {
            let value = function.value(firstParameter: 0 as AnyObject, secondParameter: 1 as AnyObject)
            results.append(value)
        }

        XCTAssertEqual(2, Set(results).count)
        XCTAssertTrue(results.contains(0))
        XCTAssertTrue(results.contains(1))
    }

    func testValueBetweenZeroAndTwo() {
        var results = [Double]()

        for _ in 1..<50 {
            let value = function.value(firstParameter: 0 as AnyObject, secondParameter: 2 as AnyObject)
            results.append(value)
        }

        XCTAssertEqual(3, Set(results).count)
        XCTAssertTrue(results.contains(0))
        XCTAssertTrue(results.contains(1))
        XCTAssertTrue(results.contains(2))
    }

    func testValueWithNegativeAndPositiveParameter() {
        var result = function.value(firstParameter: -350 as AnyObject, secondParameter: 350 as AnyObject)
        XCTAssertGreaterThanOrEqual(result, -350)
        XCTAssertLessThanOrEqual(result, 350)

        result = function.value(firstParameter: 350 as AnyObject, secondParameter: -350 as AnyObject)
        XCTAssertGreaterThanOrEqual(result, -350)
        XCTAssertLessThanOrEqual(result, 350)
        XCTAssertEqual(Double(Int(result)), result, accuracy: Double.epsilon)
    }

    func testValueWithSmallParameterRange() {
        var result = function.value(firstParameter: -0.2 as AnyObject, secondParameter: 2 as AnyObject)
        XCTAssertGreaterThanOrEqual(result, -0.2)
        XCTAssertLessThanOrEqual(result, 2)

        result = function.value(firstParameter: 0.22 as AnyObject, secondParameter: 0.44 as AnyObject)
        XCTAssertGreaterThanOrEqual(result, 0.22)
        XCTAssertLessThanOrEqual(result, 0.44)

        result = function.value(firstParameter: 0.5 as AnyObject, secondParameter: 1 as AnyObject)
        XCTAssertGreaterThanOrEqual(result, 0.5)
        XCTAssertLessThanOrEqual(result, 1)
        XCTAssertNotEqual(Double(Int(result)), result, accuracy: Double.epsilon)
    }

    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 1), function.firstParameter())
    }

    func testSecondParameter() {
        XCTAssertEqual(.number(defaultValue: 6), function.secondParameter())
    }

    func testTag() {
        XCTAssertEqual("RAND", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("random", type(of: function).name)
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
