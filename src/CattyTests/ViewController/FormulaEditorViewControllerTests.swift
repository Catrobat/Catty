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

import Nimble
import XCTest

@testable import Pocket_Code

final class FormulaEditorViewControllerTests: XCTestCase {

    var controller: FormulaEditorViewController!
    var project: Project!
    var spriteObject: SpriteObject!
    var script: Script!
    var scene: Scene!
    var analytics = AnalyticsMock.self
    var reporter: FirebaseAnalyticsReporter?

    override func setUp() {
        super.setUp()

        project = Project()
        project.userData = UserDataContainer()

        scene = Scene(name: "testScene")
        scene.project = project
        project.scene = scene

        spriteObject = SpriteObjectMock()
        project.scene.add(object: spriteObject!)

        script = StartScript()
        spriteObject.scriptList.add(script!)

        controller = FormulaEditorViewController()
        controller.object = spriteObject
    }

    func testNotification() {
        let expectedNotification = Notification(name: .formulaEditorControllerDidAppear, object: controller)

        expect(self.controller.viewDidAppear(true)).to(postNotifications(contain(expectedNotification)))
    }

    func testIsVariableUsedGlobalWithoutBrick() {
        let variable = UserVariable(name: "globalVariable")
        project.userData.add(variable)

        XCTAssertFalse(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedGlobalWithMultipleBricks() {
        let variable = UserVariable(name: "globalVariable")
        let brickA = HideTextBrick()
        let brickB = HideTextBrick()

        project.userData.add(variable)
        brickB.userVariable = variable
        script.brickList.add(brickA)

        XCTAssertFalse(controller.isVariableUsed(variable))

        script.brickList.add(brickB)
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedGlobalWithMultipleScripts() {
        let variable = UserVariable(name: "globalVariable")
        let brick = HideTextBrick()
        let scriptB = WhenScript()

        project.userData.add(variable)
        brick.userVariable = variable
        scriptB.brickList.add(brick)

        XCTAssertFalse(controller.isVariableUsed(variable))

        spriteObject.scriptList.add(scriptB)
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedGlobalWithMultipleObjects() {
        let variable = UserVariable(name: "globalVariable")
        let brick = HideTextBrick()
        let scriptB = WhenScript()
        let objectB = SpriteObject()

        project.userData.add(variable)
        brick.userVariable = variable
        scriptB.brickList.add(brick)
        objectB.scriptList.add(scriptB)

        XCTAssertFalse(controller.isVariableUsed(variable))

        project.scene.add(object: objectB)
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedLocalWithoutBrick() {
        let variable = UserVariable(name: "localVariable")
        spriteObject.userData.add(variable)

        XCTAssertFalse(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedLocalWithMultipleBricks() {
        let variable = UserVariable(name: "localVariable")
        let brickA = HideTextBrick()
        let brickB = HideTextBrick()

        spriteObject.userData.add(variable)
        brickB.userVariable = variable
        script.brickList.add(brickA)

        XCTAssertFalse(controller.isVariableUsed(variable))

        script.brickList.add(brickB)
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedLocalWithMultipleScripts() {
        let variable = UserVariable(name: "localVariable")
        let brick = HideTextBrick()
        let scriptB = WhenScript()

        spriteObject.userData.add(variable)
        brick.userVariable = variable
        scriptB.brickList.add(brick)

        XCTAssertFalse(controller.isVariableUsed(variable))

        spriteObject.scriptList.add(scriptB)
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsVariableUsedLocalWithMultipleObjects() {
        let variable = UserVariable(name: "localVariable")
        let brick = HideTextBrick()
        let scriptB = WhenScript()
        let objectB = SpriteObject()

        spriteObject.userData.add(variable)
        brick.userVariable = variable
        scriptB.brickList.add(brick)
        objectB.scriptList.add(scriptB)
        project.scene.add(object: objectB)

        XCTAssertFalse(controller.isVariableUsed(variable))

        controller.object = objectB
        XCTAssertTrue(controller.isVariableUsed(variable))
    }

    func testIsListUsedGlobalWithoutBrick() {
        let list = UserList(name: "globalList")
        project.userData.add(list)

        XCTAssertFalse(controller.isListUsed(list))
    }

    func testIsListUsedGlobalWithMultipleBricks() {
        let list = UserList(name: "globalList")
        let brickA = AddItemToUserListBrick()
        let brickB = AddItemToUserListBrick()

        brickA.listFormula = Formula()
        brickB.listFormula = Formula()

        project.userData.add(list)
        brickB.userList = list
        script.brickList.add(brickA)

        XCTAssertFalse(controller.isListUsed(list))

        script.brickList.add(brickB)
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testIsListUsedGlobalWithMultipleScripts() {
        let list = UserList(name: "globalList")
        let brick = AddItemToUserListBrick()
        let scriptB = WhenScript()

        brick.listFormula = Formula()

        project.userData.add(list)
        brick.userList = list
        scriptB.brickList.add(brick)

        XCTAssertFalse(controller.isListUsed(list))

        spriteObject.scriptList.add(scriptB)
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testIsListUsedGlobalWithMultipleObjects() {
        let list = UserList(name: "globalList")
        let brick = AddItemToUserListBrick()
        let scriptB = WhenScript()
        let objectB = SpriteObject()

        brick.listFormula = Formula()

        project.userData.add(list)
        brick.userList = list
        scriptB.brickList.add(brick)
        objectB.scriptList.add(scriptB)

        XCTAssertFalse(controller.isListUsed(list))

        project.scene.add(object: objectB)
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testIsListUsedLocalWithoutBrick() {
        let list = UserList(name: "localList")
        spriteObject.userData.add(list)

        XCTAssertFalse(controller.isListUsed(list))
    }

    func testIsListUsedLocalWithMultipleBricks() {
        let list = UserList(name: "localList")
        let brickA = AddItemToUserListBrick()
        let brickB = AddItemToUserListBrick()

        brickA.listFormula = Formula()
        brickB.listFormula = Formula()

        spriteObject.userData.add(list)
        brickB.userList = list
        script.brickList.add(brickA)

        XCTAssertFalse(controller.isListUsed(list))

        script.brickList.add(brickB)
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testIsListUsedLocalWithMultipleScripts() {
        let list = UserList(name: "localList")
        let brick = AddItemToUserListBrick()
        let scriptB = WhenScript()

        brick.listFormula = Formula()

        spriteObject.userData.add(list)
        brick.userList = list
        scriptB.brickList.add(brick)

        XCTAssertFalse(controller.isListUsed(list))

        spriteObject.scriptList.add(scriptB)
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testIsListUsedLocalWithMultipleObjects() {
        let list = UserList(name: "localList")
        let brick = AddItemToUserListBrick()
        let scriptB = WhenScript()
        let objectB = SpriteObject()

        brick.listFormula = Formula()

        spriteObject.userData.add(list)
        brick.userList = list
        scriptB.brickList.add(brick)
        objectB.scriptList.add(scriptB)
        project.scene.add(object: objectB)

        XCTAssertFalse(controller.isListUsed(list))

        controller.object = objectB
        XCTAssertTrue(controller.isListUsed(list))
    }

    func testFormulaSavedNotification() {
        let formulaEditorViewControllerMock = FormulaEditorViewControllerMock()
        let expectedNotification = Notification(name: .formulaSaved, object: formulaEditorViewControllerMock)
        expect(formulaEditorViewControllerMock.showFormulaSavedNotification()).to(postNotifications(contain(expectedNotification)))
    }
}
