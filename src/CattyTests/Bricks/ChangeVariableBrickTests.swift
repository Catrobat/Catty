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

final class ChangeVariableBrickTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var scheduler: CBScheduler!
    var context: CBScriptContextProtocol!

    override func setUp() {
        project = Project()
        let scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        project.scene = spriteObject.scene
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.scene.project = project

        script = Script()
        script.object = spriteObject

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)

        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }

    func testChangeVariableBrickUserVariablesNil() {
        spriteNode.position = CGPoint(x: 0, y: 0)

        let formula = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "0"
        formula.formulaTree = formulaTree

        let userDataContainer = UserDataContainer()
        spriteObject.scene.project!.userData = userDataContainer

        let brick = ChangeVariableBrick()
        brick.variableFormula = formula
        brick.script = script

        let instruction = brick.instruction()

        switch instruction {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            break
        }

        XCTAssertTrue(true); // The purpose of this test is to show that the program does not crash
        // when no UserVariable is selected in the IDE and the brick is executed
    }

    func testMutableCopy() {

        let brick = ChangeVariableBrick()
        brick.variableFormula = Formula(integer: 50)

        let userVariable = UserVariable(name: "testName")
        userVariable.value = 30

        brick.userVariable = userVariable

        let copiedBrick: ChangeVariableBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! ChangeVariableBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.variableFormula.isEqual(to: copiedBrick.variableFormula))
        XCTAssertFalse(brick.variableFormula === copiedBrick.variableFormula)

        XCTAssertTrue(brick.userVariable.isEqual(copiedBrick.userVariable))
        XCTAssertTrue(brick.userVariable === copiedBrick.userVariable)
    }

    func testGetFormulas() {
        let brick = ChangeVariableBrick()
        brick.variableFormula = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.variableFormula, formulas?[0])

        brick.variableFormula = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.variableFormula, formulas?[0])
    }
}
