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

final class BrickWithUserVariableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testUserVariableNoList() {
        let userVariable = UserVariable()
        userVariable.name = "test"
        userVariable.isList = false
        userVariable.value = "testValue"

        let brick = SetVariableBrick()
        brick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userVariable))
    }

    func testUserVariableList() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable()
        userList.name = "test"
        userList.isList = true

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = SetVariableBrick()
        brick.setVariable(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
    }

    func testUserVariableListUsedReplaceItemInUserListBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable()
        userList.name = "test"
        userList.isList = true

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
    }

    func testUserVariableListNotUsedReplaceItemInUserListBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable()
        let userList2 = UserVariable()
        userList.name = "test"
        userList.isList = true
        userList2.name = "test2"
        userList2.isList = true

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
        XCTAssertFalse(brick.isVarOrListBeingUsed(userList2))
    }

    func testUserVariableListUsedMultipleBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable()
        userList.name = "test"
        userList.isList = true

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let insertBrick = InsertItemIntoUserListBrick()
        let addBrick = AddItemToUserListBrick()
        let deleteBrick = DeleteItemOfUserListBrick()

        insertBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isVarOrListBeingUsed(userList))
        XCTAssertFalse(addBrick.isVarOrListBeingUsed(userList))
        XCTAssertFalse(deleteBrick.isVarOrListBeingUsed(userList))

        addBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isVarOrListBeingUsed(userList))
        XCTAssertTrue(addBrick.isVarOrListBeingUsed(userList))
        XCTAssertFalse(deleteBrick.isVarOrListBeingUsed(userList))

        deleteBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isVarOrListBeingUsed(userList))
        XCTAssertTrue(addBrick.isVarOrListBeingUsed(userList))
        XCTAssertTrue(deleteBrick.isVarOrListBeingUsed(userList))
    }
}
