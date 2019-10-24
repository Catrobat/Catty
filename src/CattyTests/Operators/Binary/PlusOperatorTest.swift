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

class PlusOperatorTest: XCTestCase {

    var op: PlusOperator!

    override func setUp() {
        super.setUp()
        op = PlusOperator()
    }

    override func tearDown() {
        op = nil
        super.tearDown()
    }

    func testValue() {
        XCTAssertEqual(0, op.value(left: 0 as AnyObject, right: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1, op.value(left: 1.0 as AnyObject, right: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, op.value(left: 1 as AnyObject, right: -1.0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, op.value(left: "1" as AnyObject, right: -1.0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(-2.5, op.value(left: -1.5 as AnyObject, right: "-1.0" as AnyObject), accuracy: Double.epsilon)
        XCTAssertTrue(op.value(left: 1 as AnyObject, right: "a" as AnyObject).isNaN)
        XCTAssertTrue(op.value(left: "a" as AnyObject, right: "b" as AnyObject).isNaN)
        XCTAssertEqual(948.5, op.value(left: 999 as AnyObject, right: -50.5 as AnyObject), accuracy: Double.epsilon)
    }

    func testPriority() {
        XCTAssertLessThan(type(of: op).priority, MultOperator.priority)
        XCTAssertLessThan(type(of: op).priority, DivideOperator.priority)
        XCTAssertGreaterThan(type(of: op).priority, AndOperator.priority)
        XCTAssertEqual(type(of: op).priority, MinusOperator.priority)
    }

    func testFormulaEditorSections() {
        XCTAssertEqual(0, op.formulaEditorSections().count)
    }
}
