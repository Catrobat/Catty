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

class GreaterThanOperatorTest: XCTestCase {

    var op: GreaterThanOperator!

    override func setUp() {
        super.setUp()
        op = GreaterThanOperator()
    }

    override func tearDown() {
        op = nil
        super.tearDown()
    }

    func testValue() {
        XCTAssertFalse(op.value(left: 0 as AnyObject, right: 0 as AnyObject))
        XCTAssertTrue(op.value(left: 9.4 as AnyObject, right: 9.2 as AnyObject))
        XCTAssertFalse(op.value(left: 9.4 as AnyObject, right: 9.5 as AnyObject))
        XCTAssertFalse(op.value(left: -9.4 as AnyObject, right: 9.5 as AnyObject))
        XCTAssertFalse(op.value(left: "a" as AnyObject, right: "b" as AnyObject))
        XCTAssertFalse(op.value(left: -1 as AnyObject, right: "b" as AnyObject))
        XCTAssertTrue(op.value(left: "a" as AnyObject, right: -1 as AnyObject))
        XCTAssertTrue(op.value(left: 1 as AnyObject, right: "b" as AnyObject))
        XCTAssertFalse(op.value(left: 1.0 as AnyObject, right: "1.0" as AnyObject))
        XCTAssertFalse(op.value(left: -1.5 as AnyObject, right: -1.5 as AnyObject))
        XCTAssertTrue(op.value(left: -1.4 as AnyObject, right: -1.5 as AnyObject))
        XCTAssertFalse(op.value(left: -1.5 as AnyObject, right: -1.4 as AnyObject))
    }

    func testFormulaEditorSections() {
        let sections = op.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertTrue(sections.contains(.logic(position: type(of: op).position)))
    }
}
