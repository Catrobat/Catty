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

final class BrickUserDataTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testUserVariableNoList() {
        let userVariable = UserVariable(name: "testName")
        userVariable.value = "testValue"

        let brick = SetVariableBrick()
        brick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userVariable))
    }

    func testUserVariableList() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable(name: "testName", isList: true)

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = SetVariableBrick()
        brick.setVariable(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
    }

    func testUserVariableListUsedReplaceItemInUserListBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable(name: "testName", isList: true)

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
    }

    func testUserVariableListNotUsedReplaceItemInUserListBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable(name: "testName1", isList: true)
        let userList2 = UserVariable(name: "testName2", isList: true)

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        brick.setFormula(Formula(), forLineNumber: 2, andParameterNumber: 0)
        brick.setFormula(Formula(), forLineNumber: 2, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userList))
        XCTAssertFalse(brick.isVarOrListBeingUsed(userList2))
    }

    func testUserVariableListUsedMultipleBrick() {
        let variablesContainer = VariablesContainer()
        let userList = UserVariable(name: "testName", isList: true)

        variablesContainer.programListOfLists = [userList]
        variablesContainer.add(toUserList: userList, value: 4)
        variablesContainer.add(toUserList: userList, value: "testValue")

        let insertBrick = InsertItemIntoUserListBrick()
        let addBrick = AddItemToUserListBrick()
        let deleteBrick = DeleteItemOfUserListBrick()

        insertBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 2)
        addBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 2)
        deleteBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 2)

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

    func testUserVariableNoListUsedMultipleVariableBrick() {
        let userVariable = UserVariable(name: "testName")
        userVariable.value = "testValue"

        let changeVariableBrick = ChangeVariableBrick()
        let hideTextBrick = HideTextBrick()
        let showTextBrick = ShowTextBrick()

        changeVariableBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 0)
        changeVariableBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 1)
        showTextBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 0)
        showTextBrick.setFormula(Formula(), forLineNumber: 1, andParameterNumber: 1)

        changeVariableBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertFalse(hideTextBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertFalse(showTextBrick.isVarOrListBeingUsed(userVariable))

        hideTextBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertTrue(hideTextBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertFalse(showTextBrick.isVarOrListBeingUsed(userVariable))

        showTextBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertTrue(hideTextBrick.isVarOrListBeingUsed(userVariable))
        XCTAssertTrue(showTextBrick.isVarOrListBeingUsed(userVariable))
    }

    func testUserVariableNoListForBrickWithMultipleFormula() {
        let userVariable = UserVariable(name: "testName", isList: false)
        let uservariableB = UserVariable(name: "testNameB", isList: false)

        let brick = SetVariableBrick()

        brick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 1)
        brick.setFormula(Formula(string: "TestFormula"), forLineNumber: 2, andParameterNumber: 1)
        brick.setFormula(Formula(integer: 100), forLineNumber: 2, andParameterNumber: 1)

        XCTAssertFalse(brick.isVarOrListBeingUsed(userVariable))
        XCTAssertFalse(brick.isVarOrListBeingUsed(uservariableB))

        brick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userVariable))
        XCTAssertFalse(brick.isVarOrListBeingUsed(uservariableB))

        let formulaElement = FormulaElement()
        formulaElement.value = uservariableB.name
        formulaElement.type = ElementType.USER_VARIABLE

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userVariable))
        XCTAssertTrue(brick.isVarOrListBeingUsed(uservariableB))
    }

    func testUserVariableNoListUseOnlyFormulaBrick() {
        let userVariable = UserVariable(name: "testName", isList: false)

        let brick = ArduinoSendDigitalValueBrick()

        let formulaElement = FormulaElement()
        formulaElement.value = userVariable.name
        formulaElement.type = ElementType.USER_VARIABLE

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 0, andParameterNumber: 1)
        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVarOrListBeingUsed(userVariable))
    }

    func testUserVariableNoListUseNitherVaribleListOrFormulaBrick() {
        let userVariable = UserVariable(name: "testName", isList: false)

        let brick = IfLogicEndBrick()

        XCTAssertFalse(brick.isVarOrListBeingUsed(userVariable))
    }
}
