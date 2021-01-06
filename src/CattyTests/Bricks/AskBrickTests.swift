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

final class AskBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userList: UserList!
    var brick: AskBrick!
    var broadcastHandler: CBBroadcastHandler!

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

        brick = AskBrick()
        brick.userVariable = UserVariable(name: "var")
        brick.question = Formula(string: "Does that work?")
        brick.script = script

        let logger = CBLogger(name: "Logger")
        broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }

    func testAnswerNormal() {
        let variableBefore = brick.userVariable?.value as? String

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "an answer", scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }
        let variableAfter = brick.userVariable?.value as? String

        XCTAssertNotEqual(variableBefore, variableAfter)
    }

    func testAnswerNoChange() {
        let variableBefore = brick.userVariable?.value as? String

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "", scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }
        let variableAfter = brick.userVariable?.value as? String

        XCTAssertEqual(variableBefore, variableAfter)
    }

    func testAnswerNoUserVariable() {
        brick.userVariable = nil

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)
            brick.callbackSubmit(with: "an answer", scheduler: scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(brick.userVariable, nil)
    }

    func testSchedulerPaused() {
        let variableBefore = brick.userVariable?.value as? String

        switch brick.instruction() {
        case let .waitExecClosure(closure):
            closure(context, scheduler)

            XCTAssertFalse(scheduler.running)

            brick.callbackSubmit(with: "another answer", scheduler: scheduler)

            XCTAssertTrue(scheduler.running)
        default:
            XCTFail("Fatal Error")
        }
        let variableAfter = brick.userVariable?.value as? String

        XCTAssertNotEqual(variableBefore, variableAfter)
    }
}
