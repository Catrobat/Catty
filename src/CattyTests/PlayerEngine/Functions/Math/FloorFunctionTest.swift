/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

class FloorFunctionTest: XCTestCase {

    var function: FloorFunction!

    override func setUp() {
        super.setUp()
        function = FloorFunction()
    }

    override func tearDown() {
        function = nil
        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: function).defaultValue, function.value(parameter: nil), accuracy: Double.epsilon)
    }

    func testValue() {
        XCTAssertEqual(floor(13.45), function.value(parameter: 13.45 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(floor(-4.66), function.value(parameter: -4.66 as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 0.7), function.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("FLOOR", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("floor", type(of: function).name)
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
