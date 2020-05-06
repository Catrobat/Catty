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
        let userVariable1 = UserVariable(name: "testName1", isList: true)
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
        let userVariableA = UserVariable(name: "userVar", isList: false)
        let userVariableB = UserVariable(name: "userVar", isList: false)

        userVariableA.value = "NewValue"
        userVariableB.value = "valueB"
        XCTAssertFalse(userVariableB.isEqual(userVariableA))

        userVariableB.value = "NewValue"
        XCTAssertTrue(userVariableB.isEqual(userVariableA))
    }

    func testIsEqualToUserVariableForList() {
        let listA = UserVariable(name: "userList", isList: true)
        let listB = UserVariable(name: "userList", isList: true)

        listA.value = NSMutableArray(array: [50, 51])
        listB.value = NSMutableArray(array: [50, 52])
        XCTAssertFalse(listB.isEqual(listA))

        listB.value = NSMutableArray(array: [50, 51])
        XCTAssertTrue(listB.isEqual(listA))
    }

    func testIsEqualToUserVariableForSameValueTypeDifferentName() {
        let userVariableA = UserVariable(name: "userVariable", isList: false)
        let userVariableB = UserVariable(name: "userVariableB", isList: false)
        let userVariableC = UserVariable(name: "userVariable", isList: false)

        userVariableA.value = "NewValue"
        userVariableB.value = "NewValue"
        userVariableC.value = "NewValue"
        XCTAssertFalse(userVariableB.isEqual(userVariableA))
        XCTAssertTrue(userVariableC.isEqual(userVariableA))
    }

    func testIsEqualToUserVariableForSameValueDiiferentType() {
        let userVariableA = UserVariable(name: "userVariable", isList: true)
        let userVariableB = UserVariable(name: "userVariable", isList: false)

        XCTAssertFalse(userVariableB.isEqual(userVariableA))

        userVariableB.isList = true
        XCTAssertTrue(userVariableB.isEqual(userVariableA))
    }
}
