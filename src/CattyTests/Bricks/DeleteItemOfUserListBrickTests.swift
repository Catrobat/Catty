/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

    var program: Program!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userList: UserVariable!
    var brick: DeleteItemOfUserListBrick!

    override func setUp() {
        program = Program()
        spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.program = program

        script = Script()
        script.object = spriteObject

        spriteObject.program.variables = VariablesContainer()

        userList = UserVariable()
        userList.isList = true
        spriteObject.program.variables.addObjectList(userList, for: spriteObject)

        brick = DeleteItemOfUserListBrick()
        brick.userList = userList
        brick.script = script

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(sceneSize: Util.screenSize(true))
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter)
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter)
    }

    func testDeleteItem() {
        userList.value = NSMutableArray(array: [1])
        brick.listFormula = Formula(integer: 1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(0, (userList.value as! [AnyObject]).count)
    }

    func testDeleteItemAtInvalidPosition() {
        userList.value = NSMutableArray(array: [1])
        brick.listFormula = Formula(string: "abc")

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(1, (userList.value as! [AnyObject]).count)
    }

    func testDeleteItemAtNegativePosition() {
        userList.value = NSMutableArray(array: [1])
        brick.listFormula = Formula(integer: -1)

        switch brick.instruction() {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(1, (userList.value as! [AnyObject]).count)
    }
}
