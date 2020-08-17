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

final class DeleteItemOfUserListBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userList: UserList!
    var brick: DeleteItemOfUserListBrick!

    override func setUp() {
        project = Project()
        let scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.scene.project = project
        project.scene = spriteObject.scene

        script = Script()
        script.object = spriteObject

        spriteObject.scene.project!.userData = UserDataContainer()

        userList = UserList(name: "testName")
        spriteObject.userData.add(userList)

        brick = DeleteItemOfUserListBrick()
        brick.userList = userList
        brick.script = script

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter)
    }

    func testDeleteItem() {
        userList.add(element: 1)
        brick.listFormula = Formula(integer: 1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(0, userList.count)
    }

     func testDeleteItemAtInvalidPosition() {
        userList.add(element: 1)
        brick.listFormula = Formula(string: "abc")

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(1, userList.count)
    }

    func testDeleteItemAtNegativePosition() {
        userList.add(element: 1)
        brick.listFormula = Formula(integer: -1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(1, userList.count)
    }

    func testMutableCopy() {
        userList.add(element: 1)
        brick.listFormula = Formula(integer: -1)
        let copiedBrick: DeleteItemOfUserListBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! DeleteItemOfUserListBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.listFormula.isEqual(to: copiedBrick.listFormula))
        XCTAssertFalse(brick.listFormula === copiedBrick.listFormula)

        XCTAssertTrue(brick.userList.isEqual(userList))
        XCTAssertTrue(brick.userList === copiedBrick.userList)
    }
}
