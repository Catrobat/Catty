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

class TanFunctionTest: XCTestCase {

    var function: TanFunction!

    override func setUp() {
        super.setUp()
        function = TanFunction()
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
        XCTAssertEqual(tan(Util.degree(toRadians: -10)), function.value(parameter: -10 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(tan(Util.degree(toRadians: 135)), function.value(parameter: 135 as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 45), function.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("TAN", type(of: function).tag)
    }

    func testName() {
        XCTAssertEqual("tan", type(of: function).name)
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
