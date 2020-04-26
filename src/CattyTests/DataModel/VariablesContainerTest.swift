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

final class VariablesContainerTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testAddObjectVariable() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let userVariable = UserVariable(name: "testName", isList: false)

        let container = VariablesContainer()
        XCTAssertEqual(0, container.allVariables()?.count)
        XCTAssertEqual(0, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, container.allVariables(for: objectB)?.count)

        var result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertTrue(result)

        XCTAssertEqual(1, container.allVariables()?.count)
        XCTAssertEqual(1, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(0, container.allVariables(for: objectB)?.count)

        result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertFalse(result)

        result = container.addObjectVariable(userVariable, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, container.allVariables()?.count)
        XCTAssertEqual(1, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(1, container.allVariables(for: objectB)?.count)
    }

    func testAddObjectList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let list = UserVariable(name: "testName", isList: true)

        let container = VariablesContainer()
        XCTAssertEqual(0, container.allLists().count)
        XCTAssertEqual(0, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)

        var result = container.addObjectList(list, for: objectA)
        XCTAssertTrue(result)

        XCTAssertEqual(1, container.allLists()?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(0, container.allLists(for: objectB)?.count)

        result = container.addObjectList(list, for: objectA)
        XCTAssertFalse(result)

        result = container.addObjectList(list, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, container.allLists()?.count)
        XCTAssertEqual(1, container.allLists(for: objectA)?.count)
        XCTAssertEqual(1, container.allLists(for: objectB)?.count)
    }

    func testAllVariables() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let userVariable1 = UserVariable(name: "testName1", isList: false)
        let userVariable2 = UserVariable(name: "testName2", isList: false)
        let list = UserVariable(name: "testlist", isList: true)

        let container = VariablesContainer()

        container.addObjectVariable(userVariable1, for: objectA)
        container.addObjectList(list, for: objectA)

        var allVariable = container.allVariables() as! [UserVariable]

        XCTAssertEqual(1, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1?.name)

        container.addObjectVariable(userVariable2, for: objectA)
        allVariable = container.allVariables() as! [UserVariable]

        XCTAssertEqual(2, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1?.name)
        XCTAssertEqual(allVariable[1].name, userVariable2?.name)
    }

    func testAllList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testName1", isList: true)
        let list2 = UserVariable(name: "testName2", isList: true)
        let variable = UserVariable(name: "testvariable", isList: false)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.addObjectVariable(variable, for: objectA)

        var allList = container.allLists() as! [UserVariable]

        XCTAssertEqual(1, allList.count)
        XCTAssertEqual(allList[0].name, list1?.name)

        container.addObjectList(list2, for: objectA)
        allList = container.allLists() as! [UserVariable]

        XCTAssertEqual(2, allList.count)
        XCTAssertEqual(allList[0].name, list1?.name)
        XCTAssertEqual(allList[1].name, list2?.name)
    }

    func testAllVariableAndAllList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let userVariable = UserVariable(name: "testVariable", isList: false)

        let list = UserVariable(name: "testList", isList: true)

        let container = VariablesContainer()

        container.addObjectVariable(userVariable, for: objectA)
        var allListAndALlVariable = container.allVariablesAndLists() as! [UserVariable]

        XCTAssertEqual(1, allListAndALlVariable.count)
        XCTAssertEqual(allListAndALlVariable[0].name, userVariable?.name)
        XCTAssertFalse(allListAndALlVariable[0].isList)

        container.addObjectList(list, for: objectA)
        allListAndALlVariable = container.allVariablesAndLists() as! [UserVariable]

        XCTAssertEqual(2, allListAndALlVariable.count)
        XCTAssertEqual(allListAndALlVariable[0].name, userVariable?.name)
        XCTAssertEqual(allListAndALlVariable[1].name, list?.name)
        XCTAssertFalse(allListAndALlVariable[0].isList)
        XCTAssertTrue(allListAndALlVariable[1].isList)
    }

    func testObjectVariablesForObject() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let userVariable1 = UserVariable(name: "testName1", isList: false)
        let userVariable2 = UserVariable(name: "testName2", isList: false)
        let userVariable3 = UserVariable(name: "testName3", isList: false)

        let container = VariablesContainer()

        container.addObjectVariable(userVariable1, for: objectA)
        var variables = container.objectVariables(for: objectA) as! [UserVariable]

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1?.name)

        container.addObjectVariable(userVariable2, for: objectA)
        container.addObjectVariable(userVariable3, for: objectB)

        variables = container.objectVariables(for: objectA) as! [UserVariable]

        XCTAssertEqual(2, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1?.name)
        XCTAssertEqual(variables[1].name, userVariable2?.name)
    }

    func testObjectListsForObject() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let list1 = UserVariable(name: "testVariable1", isList: true)
        let list2 = UserVariable(name: "testVariable2", isList: true)
        let list3 = UserVariable(name: "testVariable3", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        var lists = container.objectLists(for: objectA) as! [UserVariable]

        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(lists[0].name, list1?.name)
        XCTAssertTrue(lists[0].isList)

        container.addObjectList(list2, for: objectA)
        container.addObjectList(list3, for: objectB)

        lists = container.objectLists(for: objectA) as! [UserVariable]

        XCTAssertEqual(2, lists.count)
        XCTAssertEqual(lists[0].name, list1?.name)
        XCTAssertEqual(lists[1].name, list2?.name)
        XCTAssertTrue(lists[0].isList)
        XCTAssertTrue(lists[1].isList)
    }

    func testSetUserVariable() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let userVariable1 = UserVariable(name: "testName1", isList: false)

        let container = VariablesContainer()

        container.addObjectVariable(userVariable1, for: objectA)
        container.setUserVariable(userVariable1, toValue: 10)

        let variables = container.objectVariables(for: objectA) as! [UserVariable]

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].value as! Int, 10)
    }

    func testChangeVariable() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let userVariable1 = UserVariable(name: "testName1", isList: false)

        let container = VariablesContainer()

        container.addObjectVariable(userVariable1, for: objectA)
        container.setUserVariable(userVariable1, toValue: 10)
        container.change(userVariable1, byValue: 10)

        var variables = container.objectVariables(for: objectA) as! [UserVariable]

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].value as! Int, 20)

        container.change(userVariable1, byValue: 10)

        variables = container.objectVariables(for: objectA) as! [UserVariable]

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].value as! Int, 30)
    }

    func testAddToUserList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.add(toUserList: list1, value: 10)
        container.add(toUserList: list1, value: 20)

        let lists = container.allLists() as! [UserVariable]
        let itemInList = lists[0].value as! [Int]

        XCTAssertEqual(2, itemInList.count)
        XCTAssertEqual(itemInList[0], 10)
        XCTAssertEqual(itemInList[1], 20)
    }

    func testDeleteFromUserList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.add(toUserList: list1, value: 10)
        container.add(toUserList: list1, value: 20)

        var lists = container.allLists() as! [UserVariable]
        var itemInList = lists[0].value as! [Int]

        XCTAssertEqual(2, itemInList.count)

        container.delete(fromUserList: list1, atIndex: 2)

        lists = container.allLists() as! [UserVariable]
        itemInList = lists[0].value as! [Int]

        XCTAssertEqual(1, itemInList.count)
        XCTAssertEqual(itemInList[0], 10)
    }

    func testInsertToUserList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.insert(toUserList: list1, value: 10, atIndex: 1)
        container.insert(toUserList: list1, value: 30, atIndex: 2)

        var lists = container.allLists() as! [UserVariable]
        var itemInList = lists[0].value as! [Int]

        XCTAssertEqual(itemInList.count, 2)
        XCTAssertEqual(itemInList[0], 10)
        XCTAssertEqual(itemInList[1], 30)

        container.insert(toUserList: list1, value: 20, atIndex: 2)

        lists = container.allLists() as! [UserVariable]
        itemInList = lists[0].value as! [Int]

        XCTAssertEqual(itemInList.count, 3)
        XCTAssertEqual(itemInList[0], 10)
        XCTAssertEqual(itemInList[1], 20)
        XCTAssertEqual(itemInList[2], 30)
    }

    func testInsertToUserListInvalidIndex() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.insert(toUserList: list1, value: 10, atIndex: -1)

        var lists = container.allLists() as! [UserVariable]
        var itemInList = lists[0].value

        XCTAssertNil(itemInList)

        container.insert(toUserList: list1, value: 10, atIndex: 5)

        lists = container.allLists() as! [UserVariable]
        itemInList = lists[0].value

        XCTAssertNil(itemInList)
    }

    func testReplaceItemInUserList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.insert(toUserList: list1, value: 10, atIndex: 1)
        container.insert(toUserList: list1, value: 20, atIndex: 2)
        container.replaceItem(inUserList: list1, value: 30, atIndex: 2)

        var lists = container.allLists() as! [UserVariable]
        var itemInList = lists[0].value as! [Int]

        XCTAssertEqual(itemInList.count, 2)
        XCTAssertEqual(itemInList[0], 10)
        XCTAssertEqual(itemInList[1], 30)

        container.replaceItem(inUserList: list1, value: 40, atIndex: 1)

        lists = container.allLists() as! [UserVariable]
        itemInList = lists[0].value as! [Int]

        XCTAssertEqual(itemInList.count, 2)
        XCTAssertEqual(itemInList[0], 40)
        XCTAssertEqual(itemInList[1], 30)
    }

    func testReplaceItemInUserListInvalidIndex() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let list1 = UserVariable(name: "testVariable1", isList: true)

        let container = VariablesContainer()

        container.addObjectList(list1, for: objectA)
        container.insert(toUserList: list1, value: 10, atIndex: 1)
        container.replaceItem(inUserList: list1, value: 30, atIndex: 2)

        let lists = container.allLists() as! [UserVariable]
        let itemInList = lists[0].value as! [Int]

        XCTAssertNotEqual(itemInList[0], 30)
    }

    func testSpriteObjectForObjectVariableWhenNotList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let userVariable1 = UserVariable(name: "testName1", isList: false)
        let userVariable2 = UserVariable(name: "testName2", isList: false)

        let container = VariablesContainer()

        var result = container.addObjectVariable(userVariable1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable2, for: objectB)
        XCTAssertTrue(result)

        XCTAssertTrue(container.spriteObject(forObjectVariable: userVariable1)?.isEqual(to: objectA) == true)
        XCTAssertTrue(container.spriteObject(forObjectVariable: userVariable2)?.isEqual(to: objectB) == true)
    }

    func testSpriteObjectForObjectVariableWhenList() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let list1 = UserVariable(name: "testName1", isList: true)
        let list2 = UserVariable(name: "testName2", isList: true)

        let container = VariablesContainer()

        var result = container.addObjectList(list1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list2, for: objectB)
        XCTAssertTrue(result)

        XCTAssertTrue(container.spriteObject(forObjectVariable: list1)?.isEqual(to: objectA) == true)
        XCTAssertTrue(container.spriteObject(forObjectVariable: list2)?.isEqual(to: objectB) == true)
    }

    func testIsProjectVariableOrList() {
        let userVariable1 = UserVariable(name: "testVar1", isList: false)
        let userVariable2 = UserVariable(name: "testVar2", isList: false)

        let list1 = UserVariable(name: "testList1", isList: true)
        let list2 = UserVariable(name: "testList2", isList: true)

        let container = VariablesContainer()

        container.programVariableList.add(userVariable1 as Any)
        container.programListOfLists.add(list1 as Any)

        XCTAssertTrue(container.isProjectVariableOrList(userVariable1))
        XCTAssertFalse(container.isProjectVariableOrList(userVariable2))
        XCTAssertTrue(container.isProjectVariableOrList(list1))
        XCTAssertFalse(container.isProjectVariableOrList(list2))
    }

    func testRemoveObjectVariablesForSpriteObject() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let userVariable1 = UserVariable(name: "testName1", isList: false)
        let userVariable2 = UserVariable(name: "testName2", isList: false)
        let userVariable3 = UserVariable(name: "testName3", isList: false)
        let userVariable4 = UserVariable(name: "testName4", isList: false)

        let container = VariablesContainer()

        var result = container.addObjectVariable(userVariable1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable2, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable3, for: objectB)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable4, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(2, container.allVariables(for: objectB)?.count)

        container.removeObjectVariables(for: objectA)

        XCTAssertEqual(0, container.allVariables(for: objectA)?.count)
        XCTAssertEqual(2, container.allVariables(for: objectB)?.count)
    }

    func testRemoveObjectListsForSpriteObject() {
        let objectA = SpriteObject()
        objectA.name = "testObjectA"

        let objectB = SpriteObject()
        objectB.name = "testObjectB"

        let list1 = UserVariable(name: "testName1", isList: true)
        let list2 = UserVariable(name: "testName2", isList: true)
        let list3 = UserVariable(name: "testName3", isList: true)
        let list4 = UserVariable(name: "testName4", isList: true)

        let container = VariablesContainer()

        var result = container.addObjectList(list1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list2, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list3, for: objectB)
        XCTAssertTrue(result)

        result = container.addObjectList(list4, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, container.allLists(for: objectA)?.count)
        XCTAssertEqual(2, container.allLists(for: objectB)?.count)

        container.removeObjectLists(for: objectA)

        XCTAssertEqual(0, container.allLists(for: objectA)?.count)
        XCTAssertEqual(2, container.allLists(for: objectB)?.count)
    }
}
