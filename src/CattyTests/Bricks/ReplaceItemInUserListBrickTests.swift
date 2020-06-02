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

final class ReplaceItemInUserListBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userList: UserList!
    var brick: ReplaceItemInUserListBrick!

    override func setUp() {
        project = Project()
        spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.project = project

        script = Script()
        script.object = spriteObject

        spriteObject.project.variables = VariablesContainer()

        userList = UserList(name: "testName")
        spriteObject.project.variables.addObjectList(userList, for: spriteObject)

        brick = ReplaceItemInUserListBrick()
        brick.userList = userList
        brick.script = script

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(sceneSize: Util.screenSize(true))
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter)
    }

    func testReplaceItem() {
        let newValue: Int32 = 2

        userList.value = NSMutableArray(array: [1])
        brick.index = Formula(integer: 1)
        brick.elementFormula = Formula(integer: newValue)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        let valueArr = userList.value
        XCTAssertEqual(1, valueArr.count)
        XCTAssertEqual(newValue, valueArr[0] as! Int32)
    }

    func testReplaceItemAtInvalidPosition() {
        XCTAssertEqual(userList.value.count, 0)

        brick.index = Formula(string: "abc")
        brick.elementFormula = Formula(integer: 1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(userList.value.count, 0)
    }

    func testReplaceItemAtNegativePosition() {
        XCTAssertEqual(userList.value.count, 0)

        brick.index = Formula(integer: -1)
        brick.elementFormula = Formula(integer: 1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

       XCTAssertEqual(userList.value.count, 0)
    }
}
