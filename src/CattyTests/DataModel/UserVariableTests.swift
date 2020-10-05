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

final class UserVariableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testInit() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(variable: userVariable1)

        XCTAssertTrue(userVariable1.isEqual(userVariable2))
        XCTAssertFalse(userVariable1 === userVariable2)
    }

    func testMutableCopyWithContext() {
        let userVariable = UserVariable(name: "userVar")

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let userVariableCopy = userVariable.mutableCopy(with: context) as! UserVariable
        XCTAssertEqual(userVariable.name, userVariableCopy.name)
        XCTAssertTrue(userVariable === userVariableCopy)
    }

    func testMutableCopyAndUpdateReference() {
        let userVariableA = UserVariable(name: "userVar")
        let userVariableB = UserVariable(name: "userVar")

        let context = CBMutableCopyContext()
        context.updateReference(userVariableA, withReference: userVariableB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let userVariableCopy = userVariableA.mutableCopy(with: context) as! UserVariable
        XCTAssertEqual(userVariableA.name, userVariableCopy.name)
        XCTAssertFalse(userVariableA === userVariableCopy)
        XCTAssertTrue(userVariableB === userVariableCopy)
    }

    func testIsEqualToUserVariableForEmptyInit() {
        let userVariableA = UserVariable(name: "userVar")
        let userVariableB = UserVariable(name: "userVar")

        userVariableA.value = "NewValue"
        userVariableB.value = "valueB"
        XCTAssertFalse(userVariableA.isEqual(userVariableB))

        userVariableB.value = "NewValue"
        XCTAssertTrue(userVariableA.isEqual(userVariableB))
    }

    func testIsEqualToUserVariableForVariable() {
        let userVariableA = UserVariable(name: "userVar")
        let userVariableB = UserVariable(name: "userVar")

        userVariableA.value = "NewValue"
        userVariableB.value = "valueB"
        XCTAssertFalse(userVariableB.isEqual(userVariableA))

        userVariableB.value = "NewValue"
        XCTAssertTrue(userVariableB.isEqual(userVariableA))
    }

    func testIsEqualToUserVariableForSameValueTypeDifferentName() {
        let userVariableA = UserVariable(name: "userVariable")
        let userVariableB = UserVariable(name: "userVariableB")
        let userVariableC = UserVariable(name: "userVariable")

        userVariableA.value = "NewValue"
        userVariableB.value = "NewValue"
        userVariableC.value = "NewValue"
        XCTAssertFalse(userVariableB.isEqual(userVariableA))
        XCTAssertTrue(userVariableC.isEqual(userVariableA))
    }

    func testSet() {
        let userVariable1 = UserVariable(name: "testName1")

        XCTAssertNil(userVariable1.value)

        userVariable1.value = 10
        XCTAssertEqual(10, userVariable1.value as! Int)

        userVariable1.value = "testValue"
        XCTAssertEqual("testValue", userVariable1.value as! String)
    }

    func testSetWithInvalidDataType() {
        let userVariable1 = UserVariable(name: "testName1")

        XCTAssertNil(userVariable1.value)

        let formula = Formula(double: 50.50)!
        userVariable1.value = formula
        XCTAssertEqual(0, userVariable1.value as! Int)
    }

    func testChange() {
        let userVariable1 = UserVariable(name: "testName1")

        XCTAssertNil(userVariable1.value)

        userVariable1.value = 10
        XCTAssertEqual(10, userVariable1.value as! Int)

        userVariable1.change(by: 10)
        XCTAssertEqual(20, userVariable1.value as! Int)
    }

    func testChangeToInvalidDataType() {
        let userVariable1 = UserVariable(name: "testName1")

        XCTAssertNil(userVariable1.value)

        userVariable1.value = "10"
        XCTAssertEqual("10", userVariable1.value as! String)

        userVariable1.change(by: 10)
        XCTAssertEqual("10", userVariable1.value as! String)
    }

    func testThreadSafety() {
        let iterations = 1000

        let userVariable = UserVariable(name: "name")
        userVariable.value = NSNumber(0)

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            userVariable.change(by: 1)
        }
        XCTAssertEqual(iterations, userVariable.value as! Int)
    }

    func testTextLabelString() {
        let expectedValue = "text"

        let userVariable = UserVariable(name: "name")
        userVariable.textLabel = SKLabelNode()
        XCTAssertNil(userVariable.textLabel?.text)

        userVariable.value = expectedValue
        XCTAssertEqual(expectedValue, userVariable.textLabel?.text)
    }

    func testTextLabelInteger() {
        let expectedValue = 123

        let userVariable = UserVariable(name: "name")
        userVariable.textLabel = SKLabelNode()
        XCTAssertNil(userVariable.textLabel?.text)

        userVariable.value = expectedValue
        XCTAssertEqual(String(expectedValue), userVariable.textLabel?.text)
    }

    func testTextLabelFloat() {
        let expectedValue = 12.3

        let userVariable = UserVariable(name: "name")
        userVariable.textLabel = SKLabelNode()
        XCTAssertNil(userVariable.textLabel?.text)

        userVariable.value = expectedValue
        XCTAssertEqual(String(expectedValue), userVariable.textLabel?.text)
    }

    func testTextLabelInvalid() {
        let userVariable = UserVariable(name: "name")
        userVariable.textLabel = SKLabelNode()
        XCTAssertNil(userVariable.textLabel?.text)

        userVariable.value = userVariable
        XCTAssertEqual(SpriteKitDefines.defaultValueShowVariable, userVariable.textLabel?.text)
    }

    func testChangeTextLabel() {
        let initialValue = 1
        let incrementValue = 2

        let userVariable = UserVariable(name: "name")
        userVariable.textLabel = SKLabelNode()

        userVariable.value = initialValue
        XCTAssertEqual(String(initialValue), userVariable.textLabel?.text)

        userVariable.change(by: Double(incrementValue))
        XCTAssertEqual(String(initialValue + incrementValue), userVariable.textLabel?.text)
    }
}
