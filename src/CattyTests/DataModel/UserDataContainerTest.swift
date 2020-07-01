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

        var result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertTrue(result)

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        result = container.addObjectVariable(userVariable, for: objectA)
        XCTAssertFalse(result)

        result = container.addObjectVariable(userVariable, for: objectB)
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

        var result = container.addObjectList(list, for: objectA)
        XCTAssertTrue(result)

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectB).count)

        result = container.addObjectList(list, for: objectA)
        XCTAssertFalse(result)

        result = container.addObjectList(list, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)
    }

    func testAllVariables() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let list = UserList(name: "testName")

        container.addObjectVariable(userVariable1, for: objectA)
        container.addObjectList(list, for: objectA)

        var allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(1, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)

        container.addObjectVariable(userVariable2, for: objectA)
        allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(2, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)
        XCTAssertEqual(allVariable[1].name, userVariable2.name)
    }

    func testAllList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let variable = UserVariable(name: "testvariable")

        container.addObjectList(list1, for: objectA)
        container.addObjectVariable(variable, for: objectA)

        var allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(1, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)

        container.addObjectList(list2, for: objectA)
        allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(2, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)
        XCTAssertEqual(allList[1].name, list2.name)
    }

    func testObjectVariablesForObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")

        container.addObjectVariable(userVariable1, for: objectA)
        var variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)

        container.addObjectVariable(userVariable2, for: objectA)
        container.addObjectVariable(userVariable3, for: objectB)

        variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(2, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)
        XCTAssertEqual(variables[1].name, userVariable2.name)
    }

    func testObjectListsForObject() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")

        container.addObjectList(list1, for: objectA)
        var lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)

        container.addObjectList(list2, for: objectA)
        container.addObjectList(list3, for: objectB)

        lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(2, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)
        XCTAssertEqual(lists[1].name, list2.name)
    }

    func testIsProjectVariable() {
        let userVariable1 = UserVariable(name: "testVar1")
        let userVariable2 = UserVariable(name: "testVar2")

        container.programVariableList.add(userVariable1)
        container.addObjectVariable(userVariable2, for: objectA)

        XCTAssertTrue(container.isProjectVariable(userVariable1))
        XCTAssertFalse(container.isProjectVariable(userVariable2))
    }

    func testIsProjectList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")

        container.programListOfLists.add(list1)
        container.addObjectList(list2, for: objectA)

        XCTAssertTrue(container.isProjectList(list1))
        XCTAssertFalse(container.isProjectList(list2))
    }

    func testIsProjectDataForListAndObjectWithSameName() {
        let object = SpriteObject()
        object.name = "testObject"

       let projectList = UserList(name: "testName")
       let objectVariable = UserVariable(name: "name")

        container.programListOfLists.add(projectList)
        container.addObjectVariable(objectVariable, for: object)

        XCTAssertTrue(container.isProjectList(projectList))
        XCTAssertFalse(container.isProjectVariable(objectVariable))
    }

    func testRemoveObjectVariablesForSpriteObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        var result = container.addObjectVariable(userVariable1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable2, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable3, for: objectB)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable4, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        container.removeObjectVariables(for: objectA)

        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)
    }

    func testRemoveObjectListsForSpriteObject() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")

        var result = container.addObjectList(list1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list2, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list3, for: objectB)
        XCTAssertTrue(result)

        result = container.addObjectList(list4, for: objectB)
        XCTAssertTrue(result)

        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        container.removeObjectLists(for: objectA)

        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)
    }

    func testIsEqualToVariablesContainer() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addObjectList(list, for: objectA)
        container1.addObjectVariable(variable, for: objectA)

        container2.addObjectList(list, for: objectA)
        container2.addObjectVariable(variable, for: objectA)

        XCTAssertTrue(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForUnqualNumberOfObject() {
        let list = UserList(name: "testList")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addObjectList(list, for: objectA)

        container2.addObjectList(list, for: objectA)
        container2.addObjectList(list, for: objectB)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForSameNameDifferentObject() {
        objectB.name = "testObjectA"

        let list = UserList(name: "testList")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addObjectList(list, for: objectA)
        container2.addObjectList(list, for: objectB)

        XCTAssertTrue(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForVariableWithSameNameDifferentValues() {
        let variable1 = UserVariable(name: "testvariable")
        variable1.value = 10

        let variable2 = UserVariable(name: "testvariable")
        variable2.value = 20

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addObjectVariable(variable1, for: objectA)
        container2.addObjectVariable(variable2, for: objectA)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerForItemWithSameNameDifferentType() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testUserVariable")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.addObjectList(list, for: objectA)
        container2.addObjectVariable(variable, for: objectA)

        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerWithProgramListAndVariableHavingSameName() {
        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        XCTAssertFalse(container1 === container2)
        XCTAssertTrue(container1.isEqual(to: container2))

        let userList = UserList(name: "userData")
        let userVariable = UserVariable(name: "userData")

        container1.programVariableList.add(userVariable)
        container2.programListOfLists.add(userList)

        XCTAssertFalse(container1 === container2)
        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testIsEqualToVariablesContainerWithObjectListAndVariableHavingSameName() {
        let object = SpriteObject()
        object.name = "object"

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        XCTAssertFalse(container1 === container2)
        XCTAssertTrue(container1.isEqual(to: container2))

        let userList = UserList(name: "userData")
        let userVariable = UserVariable(name: "userData")

        container1.addObjectVariable(userVariable, for: object)
        container2.addObjectList(userList, for: object)

        XCTAssertFalse(container1 === container2)
        XCTAssertFalse(container1.isEqual(to: container2))
    }

    func testMutableCopy() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        container.addObjectList(list, for: objectA)
        container.addObjectVariable(variable, for: objectA)
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

        var result = container.addObjectVariable(userVariable1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable2, for: objectB)
        XCTAssertTrue(result)

        container.programVariableList.add(userVariable3 as Any)

        XCTAssertTrue(container.getUserVariableNamed(userVariable1.name, for: objectA)?.isEqual(userVariable1) == true)
        XCTAssertTrue(container.getUserVariableNamed(userVariable1.name, for: objectB) == nil)
        XCTAssertTrue(container.getUserVariableNamed(userVariable3.name, for: objectA)?.isEqual(userVariable3) == true)
        XCTAssertTrue(container.getUserVariableNamed(userVariable3.name, for: objectB)?.isEqual(userVariable3) == true)
        XCTAssertTrue(container.getUserVariableNamed(userVariable4.name, for: objectA) == nil)
    }

    func testGetUserListNamed() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")

        var result = container.addObjectList(list1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list2, for: objectB)
        XCTAssertTrue(result)

        container.programListOfLists.add(list3 as Any)

        XCTAssertTrue(container.getUserListNamed(list1.name, for: objectA)?.isEqual(list1) == true)
        XCTAssertTrue(container.getUserListNamed(list1.name, for: objectB) == nil)
        XCTAssertTrue(container.getUserListNamed(list3.name, for: objectA)?.isEqual(list3) == true)
        XCTAssertTrue(container.getUserListNamed(list3.name, for: objectB)?.isEqual(list3) == true)
        XCTAssertTrue(container.getUserListNamed(list4.name, for: objectA) == nil)
    }

    func testRemoveUserVariableNamed() {
        let objectC = SpriteObject()
        objectC.name = "testObjectC"

        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        var result = container.addObjectVariable(userVariable1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectVariable(userVariable2, for: objectB)
        XCTAssertTrue(result)

        container.programVariableList.add(userVariable3)

        XCTAssertEqual(3, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(container.removeUserVariableNamed(userVariable1.name, for: objectB))
        XCTAssertTrue(container.removeUserVariableNamed(userVariable1.name, for: objectA))
        XCTAssertFalse(container.removeUserVariableNamed(userVariable1.name, for: objectA))

        XCTAssertEqual(2, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertTrue(container.removeUserVariableNamed(userVariable3.name, for: objectB))
        XCTAssertFalse(container.removeUserVariableNamed(userVariable3.name, for: objectB))

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(container.removeUserVariableNamed(userVariable4.name, for: objectC))
    }

    func testRemoveUserListNamed() {
        let objectC = SpriteObject()
        objectC.name = "testObjectC"

        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")
        var result = container.addObjectList(list1, for: objectA)
        XCTAssertTrue(result)

        result = container.addObjectList(list2, for: objectB)
        XCTAssertTrue(result)

        container.programListOfLists.add(list3 as Any)

        XCTAssertEqual(3, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(container.removeUserListNamed(list1.name, for: objectB))
        XCTAssertTrue(container.removeUserListNamed(list1.name, for: objectA))
        XCTAssertFalse(container.removeUserListNamed(list1.name, for: objectA))

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertTrue(container.removeUserListNamed(list3.name, for: objectB))
        XCTAssertFalse(container.removeUserListNamed(list3.name, for: objectB))

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(container.removeUserListNamed(list4.name, for: objectC))
    }
}
