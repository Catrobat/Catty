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

final class SetVariableBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!

    override func setUp() {
        project = Project()

        spriteObject = SpriteObject()
        let scene = Scene(name: "testScene")
        spriteObject.scene = scene
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.scene.project = project

        project.scene = spriteObject.scene

        script = Script()
        script.object = spriteObject

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }

    func testSetVariableBrickUserVariablesNil() {
        spriteNode.position = CGPoint(x: 0, y: 0)

        let userDataContainer = UserDataContainer()
        spriteObject.scene.project!.userData = userDataContainer

        let brick = SetVariableBrick()
        brick.variableFormula = Formula(integer: 0)
        brick.script = script

        let instruction = brick.instruction()

        switch instruction {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertTrue(true) // The purpose of this test is to show that the program does not crash
        // when no UserVariable is selected in the IDE and the brick is executed
    }

      func testMutableCopy() {
        let brick = SetVariableBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        brick.userVariable = UserVariable(name: "testVariable")
        brick.variableFormula = Formula(integer: 0)

        let copiedBrick: SetVariableBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetVariableBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.variableFormula.isEqual(to: copiedBrick.variableFormula))
        XCTAssertFalse(brick.variableFormula === copiedBrick.variableFormula)
 }

   func testGetFormulas() {
        let brick = SetVariableBrick()
        brick.variableFormula = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.variableFormula, formulas?[0])

        brick.variableFormula = Formula(integer: 21)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.variableFormula, formulas?[0])
    }
}
