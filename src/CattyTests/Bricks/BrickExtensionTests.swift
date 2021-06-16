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

final class BrickExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testIsVariableUsed() {
        let userVariable = UserVariable(name: "testName")
        userVariable.value = "testValue"

        let brick = SetVariableBrick()
        brick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVariableUsed(variable: userVariable))
    }

    func testIsListUsed() {
        let userDataContainer = UserDataContainer()
        let userList = UserList(name: "testName")

        userDataContainer.add(userList)
        userList.add(element: 4)
        userList.add(element: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)

        let formulaElement = FormulaElement()
        formulaElement.value = userList.name
        formulaElement.type = ElementType.USER_LIST

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 0, andParameterNumber: 1)

        XCTAssertTrue(brick.isListUsed(list: userList))
    }

    func testIsListUsedWithReplaceItemInUserListBrick() {
        let userDataContainer = UserDataContainer()
        let userList = UserList(name: "testName")

        userDataContainer.add(userList)
        userList.add(element: 4)
        userList.add(element: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isListUsed(list: userList))
    }

    func testIsListUsedWithReplaceItemInUserListBrickForMultipleUserList() {
        let userDataContainer = UserDataContainer()
        let userList = UserList(name: "testName")
        let userList2 = UserList(name: "testName")

        userDataContainer.add(userList)
        userList.add(element: 4)
        userList.add(element: "testValue")

        let brick = ReplaceItemInUserListBrick()
        brick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        brick.setFormula(Formula(double: 50.50), forLineNumber: 2, andParameterNumber: 0)
        brick.setFormula(Formula(double: 50.50), forLineNumber: 2, andParameterNumber: 1)

        XCTAssertTrue(brick.isListUsed(list: userList))
        XCTAssertFalse(brick.isListUsed(list: userList2))
    }

    func testIsListUsedWithMultipleBrick() {
        let userDataContainer = UserDataContainer()
        let userList = UserList(name: "testName")

        userDataContainer.add(userList)
        userList.add(element: 4)
        userList.add(element: "testValue")

        let insertBrick = InsertItemIntoUserListBrick()
        let addBrick = AddItemToUserListBrick()
        let deleteBrick = DeleteItemOfUserListBrick()

        insertBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 2)
        addBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 2)
        deleteBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 2)

        insertBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isListUsed(list: userList))
        XCTAssertFalse(addBrick.isListUsed(list: userList))
        XCTAssertFalse(deleteBrick.isListUsed(list: userList))

        addBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isListUsed(list: userList))
        XCTAssertTrue(addBrick.isListUsed(list: userList))
        XCTAssertFalse(deleteBrick.isListUsed(list: userList))

        deleteBrick.setList(userList, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(insertBrick.isListUsed(list: userList))
        XCTAssertTrue(addBrick.isListUsed(list: userList))
        XCTAssertTrue(deleteBrick.isListUsed(list: userList))
    }

    func testIsVariableUsedWithMultipleVariableBrick() {
        let userVariable = UserVariable(name: "testName")
        userVariable.value = "testValue"

        let changeVariableBrick = ChangeVariableBrick()
        let hideTextBrick = HideTextBrick()
        let showTextBrick = ShowTextBrick()

        changeVariableBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 0)
        changeVariableBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 1)
        showTextBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 0)
        showTextBrick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 1)

        changeVariableBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVariableUsed(variable: userVariable))
        XCTAssertFalse(hideTextBrick.isVariableUsed(variable: userVariable))
        XCTAssertFalse(showTextBrick.isVariableUsed(variable: userVariable))

        hideTextBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVariableUsed(variable: userVariable))
        XCTAssertTrue(hideTextBrick.isVariableUsed(variable: userVariable))
        XCTAssertFalse(showTextBrick.isVariableUsed(variable: userVariable))

        showTextBrick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)
        XCTAssertTrue(changeVariableBrick.isVariableUsed(variable: userVariable))
        XCTAssertTrue(hideTextBrick.isVariableUsed(variable: userVariable))
        XCTAssertTrue(showTextBrick.isVariableUsed(variable: userVariable))
    }

    func testIsVariableUsedForBrickWithMultipleFormula() {
        let userVariable = UserVariable(name: "testName")
        let uservariableB = UserVariable(name: "testNameB")

        let brick = SetVariableBrick()

        brick.setFormula(Formula(double: 50.50), forLineNumber: 1, andParameterNumber: 1)
        brick.setFormula(Formula(string: "TestFormula"), forLineNumber: 2, andParameterNumber: 1)
        brick.setFormula(Formula(integer: 100), forLineNumber: 2, andParameterNumber: 1)

        XCTAssertFalse(brick.isVariableUsed(variable: userVariable))
        XCTAssertFalse(brick.isVariableUsed(variable: uservariableB))

        brick.setVariable(userVariable, forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVariableUsed(variable: userVariable))
        XCTAssertFalse(brick.isVariableUsed(variable: uservariableB))

        let formulaElement = FormulaElement()
        formulaElement.value = uservariableB.name
        formulaElement.type = ElementType.USER_VARIABLE

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVariableUsed(variable: userVariable))
        XCTAssertTrue(brick.isVariableUsed(variable: uservariableB))
    }

    func testIsVariableUsedWithOnlyFormulaBrick() {
        let userVariable = UserVariable(name: "testUserVariable")
        let userList = UserList(name: "testUserList")

        let brick = ArduinoSendDigitalValueBrick()

        let formulaElement = FormulaElement()
        formulaElement.value = userVariable.name
        formulaElement.type = ElementType.USER_VARIABLE

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 0, andParameterNumber: 1)
        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isVariableUsed(variable: userVariable))

        formulaElement.value = userList.name
        formulaElement.type = ElementType.USER_LIST

        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 0, andParameterNumber: 1)
        brick.setFormula(Formula(formulaElement: formulaElement), forLineNumber: 1, andParameterNumber: 1)

        XCTAssertTrue(brick.isListUsed(list: userList))
    }

    func testIsVariableUsedWithNitherVaribleOrFormulaBrick() {
        let userVariable = UserVariable(name: "testName")

        let brick = IfLogicEndBrick()
        XCTAssertFalse(brick.isVariableUsed(variable: userVariable))
    }

    func testIsListUsedWithNitherListOrFormulaBrick() {
        let userList = UserList(name: "testUserList")

        let brick = IfLogicEndBrick()
        XCTAssertFalse(brick.isListUsed(list: userList))
    }
}
