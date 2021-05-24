/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class OperatorManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testDefaultValueForUndefinedOperator() {
        let manager = OperatorManager(operators: [])

        XCTAssertNil(manager.getOperator(tag: "invalidTag"))
        XCTAssertEqual(type(of: manager).defaultValueForUndefinedOperator, manager.value(tag: "invalidTag", leftParameter: 0 as AnyObject, rightParameter: 0 as AnyObject) as! Double)
    }

    func testExists() {
        let operatorA = BinaryOperatorMock(value: 0)
        let operatorB = UnaryOperatorMock(value: 0)
        let manager = OperatorManager(operators: [operatorA, operatorB])

        XCTAssertFalse(manager.exists(tag: "invalidTag"))
        XCTAssertTrue(manager.exists(tag: type(of: operatorA).tag))
        XCTAssertTrue(manager.exists(tag: type(of: operatorB).tag))
    }

    func testOperator() {
        let operatorA = BinaryOperatorMock(value: 0)
        let operatorB = UnaryOperatorMock(value: 0)
        let manager = OperatorManager(operators: [operatorA, operatorB])

        XCTAssertNil(manager.getOperator(tag: "invalidTag"))

        var op = manager.getOperator(tag: type(of: operatorA).tag)
        XCTAssertEqual(type(of: operatorA).tag, type(of: op!).tag)

        op = manager.getOperator(tag: type(of: operatorB).tag)
        XCTAssertEqual(type(of: operatorB).tag, type(of: op!).tag)
    }

    func testName() {
        let operatorA = BinaryOperatorMock(value: 0)
        let operatorB = UnaryOperatorMock(value: 0)
        let manager = OperatorManager(operators: [operatorA, operatorB])

        XCTAssertNil(type(of: manager).name(tag: "invalidTag"))
        XCTAssertEqual(type(of: operatorA).name, type(of: manager).name(tag: type(of: operatorA).tag))
        XCTAssertEqual(type(of: operatorB).name, type(of: manager).name(tag: type(of: operatorB).tag))
        XCTAssertNotEqual(type(of: operatorA).name, type(of: operatorB).name)
    }

    func testFormulaEditorItems() {
        let operatorA = BinaryOperatorMock(value: 0, formulaEditorSections: [.object(position: 2, subsection: .general), .functions(position: 10, subsection: .maths)])
        let operatorB = UnaryOperatorMock(value: 0, formulaEditorSections: [.sensors(position: 1, subsection: .device), .functions(position: 10, subsection: .maths)])

        let manager = OperatorManager(operators: [operatorA, operatorB])
        let items = manager.formulaEditorItems()

        XCTAssertEqual(2, items.count)
        XCTAssertTrue(items.contains { type(of: $0.op!).tag == type(of: operatorA).tag })
        XCTAssertTrue(items.contains { type(of: $0.op!).tag == type(of: operatorB).tag })
    }

    func testValue() {
        let valueA = 2.0
        let valueB = 10.0
        let operatorA = BinaryOperatorMock(value: valueA)
        let operatorB = UnaryOperatorMock(value: valueB)
        let manager = OperatorManager(operators: [operatorA, operatorB])

        XCTAssertEqual(type(of: manager).defaultValueForUndefinedOperator, manager.value(tag: "undefinedTag", leftParameter: 0 as AnyObject, rightParameter: 0 as AnyObject) as! Double)
        XCTAssertEqual(valueA, manager.value(tag: type(of: operatorA).tag, leftParameter: 0 as AnyObject, rightParameter: 0 as AnyObject) as! Double)
        XCTAssertEqual(valueB, manager.value(tag: type(of: operatorB).tag, leftParameter: 0 as AnyObject, rightParameter: 0 as AnyObject) as! Double)
    }

    func testPriority() {
        let operatorA = BinaryOperatorMock(value: 0)
        type(of: operatorA).priority = 10

        let operatorB = UnaryOperatorMock(value: 0)
        type(of: operatorB).priority = 11

        let manager = OperatorManager(operators: [operatorA, operatorB])

        XCTAssertEqual(-1, type(of: manager).comparePriority(of: type(of: operatorA).tag, with: type(of: operatorB).tag))
        XCTAssertEqual(1, type(of: manager).comparePriority(of: type(of: operatorB).tag, with: type(of: operatorA).tag))
        XCTAssertEqual(0, type(of: manager).comparePriority(of: type(of: operatorB).tag, with: "invalidTag"))
        XCTAssertEqual(0, type(of: manager).comparePriority(of: "invalidTagA", with: "invalidTagB"))
        XCTAssertEqual(0, type(of: manager).comparePriority(of: type(of: operatorA).tag, with: type(of: operatorA).tag))
    }
}
