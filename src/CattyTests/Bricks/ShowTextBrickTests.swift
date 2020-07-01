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

final class ShowTextBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!
    var userDataContainer: UserDataContainer!

    override func setUp() {
        project = Project()

        spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.project = project

        script = Script()
        script.object = spriteObject

        userDataContainer = UserDataContainer()
        spriteObject.project.userData = userDataContainer

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(sceneSize: Util.screenSize(true), landscapeMode: false)
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter)
    }

    func testShowTextBrickUserVariablesNil() {
        let brick = ShowTextBrick()
        brick.script = script
        brick.xFormula = Formula(integer: 220)
        brick.yFormula = Formula(integer: 330)

        executeInstruction(for: brick)

        XCTAssertTrue(true); // The purpose of this test is to show that the program does not crash
        // when no UserVariable is selected in the IDE and the brick is executed
    }

    func testShowTextBrick() {
        let pos = CGPoint(x: -10, y: 20)
        let sceneSize = CGSize(width: 200, height: 300)
        let expectedPos = CGPoint(x: sceneSize.width / 2 + pos.x, y: sceneSize.height / 2 + pos.y)

        let userVariable = UserVariable(name: "testName")
        let label = SKLabelNode()
        userVariable.textLabel = label

        let scene = SKScene(size: sceneSize)
        scene.addChild(label)

        let brick = ShowTextBrick()
        brick.script = script
        brick.xFormula = Formula(float: Float(pos.x))
        brick.yFormula = Formula(float: Float(pos.y))
        brick.userVariable = userVariable

        executeInstruction(for: brick)

        XCTAssertEqual(expectedPos.x, userVariable.textLabel?.position.x)
        XCTAssertEqual(expectedPos.y, userVariable.textLabel?.position.y)
    }

    private func executeInstruction(for brick: CBInstructionProtocol) {
        let instruction = brick.instruction()

        switch instruction {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }
    }
}
