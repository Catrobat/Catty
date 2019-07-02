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

class MultOperatorTest: XCTestCase {

    var op: MultOperator!

    override func setUp() {
        super.setUp()
        op = MultOperator()
    }

    override func tearDown() {
        op = nil
        super.tearDown()
    }

    func testValue() {
        XCTAssertEqual(0, op.value(left: 0 as AnyObject, right: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(0.6, op.value(left: 1.2 as AnyObject, right: 0.5 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(-1, op.value(left: 1 as AnyObject, right: -1.0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(-1, op.value(left: "1" as AnyObject, right: -1.0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.5, op.value(left: -1.5 as AnyObject, right: "-1.0" as AnyObject), accuracy: Double.epsilon)
        XCTAssertTrue(op.value(left: 1 as AnyObject, right: "a" as AnyObject).isNaN)
        XCTAssertTrue(op.value(left: "a" as AnyObject, right: "b" as AnyObject).isNaN)
        XCTAssertEqual(-50449.5, op.value(left: 999 as AnyObject, right: -50.5 as AnyObject), accuracy: Double.epsilon)
    }

    func testPriority() {
        XCTAssertEqual(type(of: op).priority, DivideOperator.priority)
        XCTAssertGreaterThan(type(of: op).priority, PlusOperator.priority)
        XCTAssertGreaterThan(type(of: op).priority, MinusOperator.priority)
        XCTAssertGreaterThan(type(of: op).priority, AndOperator.priority)
    }

    func testFormulaEditorSections() {
        XCTAssertEqual(0, op.formulaEditorSections().count)
    }
}
