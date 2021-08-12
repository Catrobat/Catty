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

        let scene = Scene(name: "testScene")

        self.project.scene = scene

        self.objectA = SpriteObject()
        self.objectA.scene = scene
        self.objectA.name = "testObjectA"
        objectA.scene.project = self.project

        self.objectB = SpriteObject()
        self.objectB.name = "testObjectB"
        self.objectB.scene = scene
        self.objectB.scene.project = self.project

        self.project.scene.add(object: objectA)
        self.project.scene.add(object: objectB)

        self.project.scene = objectA.scene
    }

    func testAddObjectVariable() {
        let userVariable = UserVariable(name: "testName")

        XCTAssertEqual(0, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        objectA.userData.add(userVariable)

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        objectA.userData.add(userVariable)
        objectB.userData.add(userVariable)

        XCTAssertEqual(2, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectB).count)
    }

    func testAddObjectList() {
        let list = UserList(name: "testName")

        XCTAssertEqual(0, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectB).count)

        objectA.userData.add(list)

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectLists(for: objectB).count)

        objectA.userData.add(list)
        objectB.userData.add(list)

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)
    }

    func testAllVariables() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let list = UserList(name: "testName")

        objectA.userData.add(userVariable1)
        objectA.userData.add(list)

        var allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(1, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)

        objectA.userData.add(userVariable2)
        allVariable = UserDataContainer.allVariables(for: project)

        XCTAssertEqual(2, allVariable.count)
        XCTAssertEqual(allVariable[0].name, userVariable1.name)
        XCTAssertEqual(allVariable[1].name, userVariable2.name)
    }

    func testAllList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let variable = UserVariable(name: "testvariable")

        objectA.userData.add(variable)
        objectA.userData.add(list1)

        var allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(1, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)

        objectA.userData.add(list2)
        allList = UserDataContainer.allLists(for: project)

        XCTAssertEqual(2, allList.count)
        XCTAssertEqual(allList[0].name, list1.name)
        XCTAssertEqual(allList[1].name, list2.name)
    }

    func testObjectVariablesForObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")

        objectA.userData.add(userVariable1)
        var variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(1, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)

        objectA.userData.add(userVariable2)
        objectB.userData.add(userVariable3)

        variables = UserDataContainer.objectVariables(for: objectA)

        XCTAssertEqual(2, variables.count)
        XCTAssertEqual(variables[0].name, userVariable1.name)
        XCTAssertEqual(variables[1].name, userVariable2.name)
    }

    func testObjectListsForObject() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")

        objectA.userData.add(list1)
        var lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(1, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)

        objectA.userData.add(list2)
        objectB.userData.add(list3)

        lists = UserDataContainer.objectLists(for: objectA)

        XCTAssertEqual(2, lists.count)
        XCTAssertEqual(lists[0].name, list1.name)
        XCTAssertEqual(lists[1].name, list2.name)
    }

    func testIsProjectVariable() {
        let userVariable1 = UserVariable(name: "testVar1")
        let userVariable2 = UserVariable(name: "testVar2")

        container.add(userVariable1)
        objectA.userData.add(userVariable2)

        XCTAssertTrue(container.contains(userVariable1))
        XCTAssertFalse(container.contains(userVariable2))
    }

    func testIsProjectList() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")

        container.add(list1)
        objectA.userData.add(list2)

        XCTAssertTrue(container.contains(list1))
        XCTAssertFalse(container.contains(list2))
    }

    func testIsProjectDataForListAndObjectWithSameName() {
        let object = SpriteObject()
        object.name = "testObject"

       let projectList = UserList(name: "testName")
       let objectVariable = UserVariable(name: "name")

        container.add(projectList)
        object.userData.add(objectVariable)

        XCTAssertTrue(container.contains(projectList))
        XCTAssertFalse(container.contains(objectVariable))
    }

    func testRemoveObjectVariablesForSpriteObject() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        objectA.userData.add(userVariable1)
        objectA.userData.add(userVariable2)
        objectB.userData.add(userVariable3)
        objectB.userData.add(userVariable4)

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

        objectA.userData.add(list1)
        objectA.userData.add(list2)
        objectB.userData.add(list3)
        objectB.userData.add(list4)

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

        container1.add(list)
        container1.add(variable)

        container2.add(list)
        container2.add(variable)

        XCTAssertTrue(container1.isEqual(container2))
    }

    func testIsEqualToVariablesContainerForUnequalNumberOfLists() {
        let list = UserList(name: "testList")
        let list2 = UserList(name: "testList2")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.add(list)

        container2.add(list)
        container2.add(list2)

        XCTAssertFalse(container1.isEqual(container2))
    }

    func testIsEqualForEqualNumberOfUserDataButInDifferentOrder() {
        let variable1 = UserVariable(name: "testVariable1")
        let variable2 = UserVariable(name: "testVariable2")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.add(variable1)
        container2.add(variable2)

        container2.add(variable1)
        container1.add(variable2)

        XCTAssertTrue(container1.isEqual(container2))
    }

    func testIsEqualToVariablesContainerForVariableWithSameNameDifferentValues() {
        let variable1 = UserVariable(name: "testvariable")
        variable1.value = 10

        let variable2 = UserVariable(name: "testvariable")
        variable2.value = 20

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.add(variable1)
        container2.add(variable2)

        XCTAssertFalse(container1.isEqual(container2))
    }

    func testIsEqualToVariablesContainerForItemWithSameNameDifferentType() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testUserVariable")

        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        container1.add(list)
        container2.add(variable)

        XCTAssertFalse(container1.isEqual(container2))
    }

    func testIsEqualToVariablesContainerWithProgramListAndVariableHavingSameName() {
        let container1 = UserDataContainer()
        let container2 = UserDataContainer()

        XCTAssertFalse(container1 === container2)
        XCTAssertTrue(container1.isEqual(container2))

        let userList = UserList(name: "userData")
        let userVariable = UserVariable(name: "userData")

        container1.add(userVariable)
        container2.add(userList)

        XCTAssertFalse(container1 === container2)
        XCTAssertFalse(container1.isEqual(container2))
    }

    func testMutableCopy() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        container.add(list)
        container.add(variable)

        let copyContainer = container.mutableCopy(with: CBMutableCopyContext()) as! UserDataContainer
        XCTAssertFalse(container === copyContainer)

        let copiedVariables = copyContainer.variables()
        XCTAssertEqual(1, copiedVariables.count)
        XCTAssertEqual(variable, copiedVariables[0])
        XCTAssertTrue(copiedVariables[0] === variable)

        let copiedLists = copyContainer.lists()
        XCTAssertEqual(1, copiedLists.count)
        XCTAssertEqual(list, copiedLists[0])
        XCTAssertTrue(copiedLists[0] === list)
    }

    func testMutableCopyWithUpdatedReferences() {
        let context = CBMutableCopyContext()

        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        container.add(list)
        container.add(variable)

        let copiedList = UserList(name: "testList")
        let copiedVariable = UserVariable(name: "testvariable")

        context.updateReference(list, withReference: copiedList)
        context.updateReference(variable, withReference: copiedVariable)

        let copyContainer = container.mutableCopy(with: context) as! UserDataContainer
        XCTAssertFalse(container === copyContainer)

        let copiedVariables = copyContainer.variables()
        XCTAssertEqual(1, copiedVariables.count)
        XCTAssertFalse(copiedVariables[0] === variable)

        let copiedLists = copyContainer.lists()
        XCTAssertFalse(copiedLists[0] === list)
    }

    func testGetUserVariableNamed() {
        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")
        let userVariable4 = UserVariable(name: "testName4")

        objectA.userData.add(userVariable1)
        objectB.userData.add(userVariable2)

        container.add(userVariable3)

        XCTAssertTrue(objectA.userData.getUserVariable(identifiedBy: userVariable1.name)?.isEqual(userVariable1) == true)
        XCTAssertNil(objectB.userData.getUserVariable(identifiedBy: userVariable1.name))
        XCTAssertTrue(container.getUserVariable(identifiedBy: userVariable3.name)?.isEqual(userVariable3) == true)
        XCTAssertTrue(objectB.userData.getUserVariable(identifiedBy: userVariable2.name)?.isEqual(userVariable2) == true)
        XCTAssertNil(objectA.userData.getUserVariable(identifiedBy: userVariable4.name))
    }

    func testGetUserListNamed() {
        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")
        let list4 = UserList(name: "testName4")

        objectA.userData.add(list1)
        objectB.userData.add(list2)
        container.add(list3)

        XCTAssertTrue(objectA.userData.getUserList(identifiedBy: list1.name)?.isEqual(list1) == true)
        XCTAssertNil(objectB.userData.getUserList(identifiedBy: list1.name))
        XCTAssertTrue(container.getUserList(identifiedBy: list3.name)?.isEqual(list3) == true)
        XCTAssertTrue(objectB.userData.getUserList(identifiedBy: list2.name)?.isEqual(list2) == true)
        XCTAssertNil(objectA.userData.getUserList(identifiedBy: list4.name))
    }

    func testRemoveUserVariableNamed() {
        let objectC = SpriteObject()
        let scene = Scene(name: "testScene")
        objectC.scene = scene
        objectC.name = "testObjectC"

        let userVariable1 = UserVariable(name: "testName1")
        let userVariable2 = UserVariable(name: "testName2")
        let userVariable3 = UserVariable(name: "testName3")

        objectA.userData.add(userVariable1)
        objectB.userData.add(userVariable2)
        container.add(userVariable3)

        XCTAssertEqual(3, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(objectB.userData.removeUserVariable(identifiedBy: userVariable1.name))
        XCTAssertTrue(objectA.userData.removeUserVariable(identifiedBy: userVariable1.name))
        XCTAssertFalse(objectA.userData.removeUserVariable(identifiedBy: userVariable1.name))

        XCTAssertEqual(2, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertTrue(container.removeUserVariable(identifiedBy: userVariable3.name))
        XCTAssertFalse(container.removeUserVariable(identifiedBy: userVariable3.name))

        XCTAssertEqual(1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual(0, UserDataContainer.objectAndProjectVariables(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectVariables(for: objectB).count)

        XCTAssertFalse(objectC.userData.removeUserVariable(identifiedBy: userVariable3.name))
    }

    func testRemoveUserListNamed() {
        let objectC = SpriteObject()
        let scene = Scene(name: "testScene")
        objectC.scene = scene
        objectC.name = "testObjectC"

        let list1 = UserList(name: "testName1")
        let list2 = UserList(name: "testName2")
        let list3 = UserList(name: "testName3")

        objectA.userData.add(list1)
        objectB.userData.add(list2)
        container.add(list3)

        XCTAssertEqual(3, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(objectB.userData.removeUserList(identifiedBy: list1.name))
        XCTAssertTrue(objectA.userData.removeUserList(identifiedBy: list1.name))
        XCTAssertFalse(objectA.userData.removeUserList(identifiedBy: list1.name))

        XCTAssertEqual(2, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(2, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertTrue(objectB.userData.removeUserList(identifiedBy: list2.name))
        XCTAssertFalse(objectB.userData.removeUserList(identifiedBy: list2.name))

        XCTAssertEqual(1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectA).count)
        XCTAssertEqual(1, UserDataContainer.objectAndProjectLists(for: objectB).count)

        XCTAssertFalse(objectC.userData.removeUserList(identifiedBy: list3.name))
    }

    func testObjectOrProjectVariable() {
        let variable1 = UserVariable(name: "testVariable1")

        objectA.userData.add(variable1)
        XCTAssertNil(UserDataContainer.objectOrProjectVariable(for: objectA, and: "variable"))
        XCTAssertEqual(variable1, UserDataContainer.objectOrProjectVariable(for: objectA, and: "testVariable1"))

        let variable2 = UserVariable(name: "testVariable2")

        project.userData.add(variable2)
        XCTAssertNil(UserDataContainer.objectOrProjectVariable(for: objectA, and: "variable"))
        XCTAssertEqual(variable2, UserDataContainer.objectOrProjectVariable(for: objectA, and: "testVariable2"))
    }

    func testObjectOrProjectList() {
        let list1 = UserList(name: "testList1")

        objectA.userData.add(list1)
        XCTAssertNil(UserDataContainer.objectOrProjectList(for: objectA, and: "list"))
        XCTAssertEqual(list1, UserDataContainer.objectOrProjectList(for: objectA, and: "testList1"))

        let list2 = UserList(name: "testList2")

        project.userData.add(list2)
        XCTAssertNil(UserDataContainer.objectOrProjectList(for: objectA, and: "list"))
        XCTAssertEqual(list2, UserDataContainer.objectOrProjectList(for: objectA, and: "testList2"))
    }
}
