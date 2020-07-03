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

final class UserDataContainerTest: XCTestCase {

    var project: Project!
    var container: UserDataContainer!
    var objectA: SpriteObject!
    var objectB: SpriteObject!

    override func setUp() {
        super.setUp()
        self.project = Project()
        self.container = UserDataContainer()
        self.project.userData = self.container

        self.objectA = SpriteObject()
        self.objectA.name = "testObjectA"
        objectA.project = self.project

        self.objectB = SpriteObject()
        self.objectB.name = "testObjectB"
        self.objectB.project = self.project

        self.project.objectList.add(objectA as Any)
        self.project.objectList.add(objectB as Any)
    }

    func testAddObjectVariable() {
        let userVariable = UserVariable(name: "testName")

        XCTAssertEqual(0, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        var result = objectA.userData.addVariable(userVariable)
        XCTAssertTrue(result)

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        result = objectA.userData.addVariable(userVariable)
        XCTAssertFalse(result)

        result = objectB.userData.addVariable(userVariable)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectB).count)
    }

    func testAddObjectList() {
        let list = UserList(name: "testName")

        XCTAssertEqual(0, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectB).count)

        var result = objectA.userData.addList(list)
        XCTAssertTrue(result)

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectB).count)

        result = objectA.userData.addList(list)
        XCTAssertFalse(result)

        result = objectB.userData.addList(list)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)
    }

    func testAllVariables() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let list = UserList(name: "testName")

        objectA.userData.addVariable(userVariable1)
        objectA.userData.addList(list)

        var allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(1, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)

        objectA.userData.addVariable(userVariable2)
        allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(2, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)
        XCTAssertEqual(allVariable[1].name, userVariable2.name)
    }

    func testAllList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let variable = UserVariable(name: "testvariable")

        objectA.userData.addVariable(variable)
        objectA.userData.addList(list1)

        var allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(1, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)

        objectA.userData.addList(list2)
        allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(2, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)
        XCTAssertEqual(allList[1].name, list2.name)
    }

    func testObjectVariablesForObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")

        objectA.userData.addVariable(userVariable1)
        var variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)

        objectA.userData.addVariable(userVariable2)
        objectB.userData.addVariable(userVariable3)

        variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(2, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)
        XCTAssertEqual(variables[1].name, userVariable2.name)
    }

    func testObjectListsForObject() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")

        objectA.userData.addList(list1)
        var lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)

        objectA.userData.addList(list2)
        objectB.userData.addList(list3)

        lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(2, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)
        XCTAssertEqual(lists[1].name, list2.name)
    }

    func testIsProjectVariable() {
        let userVariable1 = UserVariable(name: "testVar1")
        let userVariable2 = UserVariable(name: "testVar2")

        container.addVariable(userVariable1)
        objectA.userData.addVariable(userVariable2)

        XCTAssertTrue(container.containsVariable(userVariable1))
        XCTAssertFalse(container.containsVariable(userVariable2))
    }

    func testIsProjectList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")

        container.addList(list1)
        objectA.userData.addList(list2)

        XCTAssertTrue(container.containsList(list1))
        XCTAssertFalse(container.containsList(list2))
    }

    func testIsProjectDataForListAndObjectWithSameName() {
        let object = SpriteObject()
        object.name = "testObject"

       let projectList = UserList(name: "testName")
       let objectVariable = UserVariable(name: "name")

        container.addList(projectList)
        object.userData.addVariable(objectVariable)

        XCTAssertTrue(container.containsList(projectList))
        XCTAssertFalse(container.containsVariable(objectVariable))
    }

    func testRemoveObjectVariablesForSpriteObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        var result = objectA.userData.addVariable(userVariable1)
        XCTAssertTrue(result)

        result = objectA.userData.addVariable(userVariable2)
        XCTAssertTrue(result)

        result = objectB.userData.addVariable(userVariable3)
        XCTAssertTrue(result)

        result = objectB.userData.addVariable(userVariable4)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        objectA.userData.removeAllVariables()

        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)
    }

    func testRemoveObjectListsForSpriteObject() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")

        var result = objectA.userData.addList(list1)
        XCTAssertTrue(result)

        result = objectA.userData.addList(list2)
        XCTAssertTrue(result)

        result = objectB.userData.addList(list3)
        XCTAssertTrue(result)

        result = objectB.userData.addList(list4)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        objectA.userData.removeAllLists()

        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)
    }

    func testIsEqualToVariablesContainer() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addList(list)
        container1.addVariable(variable)

        container2.addList(list)
        container2.addVariable(variable)

        XCTAssertTrue(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForUnequalNumberOfLists() {
        let list = UserList(name: "testList")
        let list2 = UserList(name: "testList2")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addList(list)

        container2.addList(list)
        container2.addList(list2)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForVariableWithSameNameDifferentValues() {
        let variable1 = UserVariable(name: "testvariable")
        variable1.value = 10

        let variable2 = UserVariable(name: "testvariable")
        variable2.value = 20

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addVariable(variable1)
        container2.addVariable(variable2)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForItemWithSameNameDifferentType() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testUserVariable")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addList(list)
        container2.addVariable(variable)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerWithProgramListAndVariableHavingSameName() {
        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        XCTAssertFalse(container1 === container2)
        XCTAssertTrue(container1.isEqual(to: container2))

        let userList = UserList(name: "userData")
        let userVariable = UserVariable(name: "userData")

        container1.addVariable(userVariable)
        container2.addList(userList)

        XCTAssertFalse(container1 === container2)
        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testMutableCopy() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        container.addList(list)
        container.addVariable(variable)
        variable.value = 10

        let copyContainer = container.mutableCopy() as! UserDataContainer
        let copyProject = Project()
        copyProject.objectList.add(objectA as Any)
        copyProject.objectList.add(objectB as Any)
        copyProject.userData = copyContainer

        XCTAssertTrue(container.isEqual(to: copyContainer))
        XCTAssertFalse(container == copyContainer)
        XCTAssertTrue(UserDataContainer.allVariables(for: project)[0] === UserDataContainer.allVariables(for: copyProject)[0])
        XCTAssertTrue(UserDataContainer.allLists(for: project)[0] === UserDataContainer.allLists(for: copyProject)[0])
    }

    func testGetUserVariableNamed() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        var result = objectA.userData.addVariable(userVariable1)
        XCTAssertTrue(result)

        result = objectB.userData.addVariable(userVariable2)
        XCTAssertTrue(result)

        container.addVariable(userVariable3)

        XCTAssertTrue(objectA.userData.getUserVariable(withName: userVariable1.name)?.isEqual(userVariable1) == true)
        XCTAssertNil(objectB.userData.getUserVariable(withName: userVariable1.name))
        XCTAssertTrue(container.getUserVariable(withName: userVariable3.name)?.isEqual(userVariable3) == true)
        XCTAssertTrue(objectB.userData.getUserVariable(withName: userVariable2.name)?.isEqual(userVariable2) == true)
        XCTAssertNil(objectA.userData.getUserVariable(withName: userVariable4.name))
    }

    func testGetUserListNamed() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")

        var result = objectA.userData.addList(list1)
        XCTAssertTrue(result)

        result = objectB.userData.addList(list2)
        XCTAssertTrue(result)

        container.addList(list3)

        XCTAssertTrue(objectA.userData.getUserList(withName: list1.name)?.isEqual(list1) == true)
        XCTAssertNil(objectB.userData.getUserList(withName: list1.name))
        XCTAssertTrue(container.getUserList(withName: list3.name)?.isEqual(list3) == true)
        XCTAssertTrue(objectB.userData.getUserList(withName: list2.name)?.isEqual(list2) == true)
        XCTAssertNil(objectA.userData.getUserList(withName: list4.name))
    }

    func testRemoveUserVariableNamed() {
        let objectC = SpriteObject()
        objectC.name = "testObjectC"

        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")

        var result = objectA.userData.addVariable(userVariable1)
        XCTAssertTrue(result)

        result = objectB.userData.addVariable(userVariable2)
        XCTAssertTrue(result)

        container.addVariable(userVariable3)

        XCTAssertEqual(3, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(objectB.userData.removeUserVariable(withName: userVariable1.name))
        XCTAssertTrue(objectA.userData.removeUserVariable(withName: userVariable1.name))
        XCTAssertFalse(objectA.userData.removeUserVariable(withName: userVariable1.name))

        XCTAssertEqual(2, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertTrue(container.removeUserVariable(withName: userVariable3.name))
        XCTAssertFalse(container.removeUserVariable(withName: userVariable3.name))

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(objectC.userData.removeUserVariable(withName: userVariable3.name))
    }

    func testRemoveUserListNamed() {
        let objectC = SpriteObject()
        objectC.name = "testObjectC"

        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")

        var result = objectA.userData.addList(list1)
        XCTAssertTrue(result)

        result = objectB.userData.addList(list2)
        XCTAssertTrue(result)

        container.addList(list3)

        XCTAssertEqual(3, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(objectB.userData.removeUserList(withName: list1.name))
        XCTAssertTrue(objectA.userData.removeUserList(withName: list1.name))
        XCTAssertFalse(objectA.userData.removeUserList(withName: list1.name))

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertTrue(objectB.userData.removeUserList(withName: list2.name))
        XCTAssertFalse(objectB.userData.removeUserList(withName: list2.name))

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(objectC.userData.removeUserList(withName: list3.name))
    }

    func testObjectOrProjectVariable() {
        let variable1 = UserVariable(name: "testVariable1")

        objectA.userData.addVariable(variable1)
        XCTAssertNil(UserDataContainer.objectOrProjectVariable(for: objectA, and: "variable"))
        XCTAssertEqual(variable1, UserDataContainer.objectOrProjectVariable(for: objectA, and: "testVariable1"))

        let variable2 = UserVariable(name: "testVariable2")

        project.userData.addVariable(variable2)
        XCTAssertNil(UserDataContainer.objectOrProjectVariable(for: objectA, and: "variable"))
        XCTAssertEqual(variable2, UserDataContainer.objectOrProjectVariable(for: objectA, and: "testVariable2"))
    }

    func testObjectOrProjectList() {
        let list1 = UserList(name: "testList1")

        objectA.userData.addList(list1)
        XCTAssertNil(UserDataContainer.objectOrProjectList(for: objectA, and: "list"))
        XCTAssertEqual(list1, UserDataContainer.objectOrProjectList(for: objectA, and: "testList1"))

        let list2 = UserList(name: "testList2")

        project.userData.addList(list2)
        XCTAssertNil(UserDataContainer.objectOrProjectList(for: objectA, and: "list"))
        XCTAssertEqual(list2, UserDataContainer.objectOrProjectList(for: objectA, and: "testList2"))
    }
}
