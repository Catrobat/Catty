/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

 final class WhenConditionScriptTests: XCTestCase {

    var project: Project!
    var object: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: WhenConditionScript!
    var formulaInterpreter: FormulaInterpreterProtocol!
    var scene: Scene!
    var stage: StageMock!

     override func setUp() {
        super.setUp()
        project = ProjectMock(width: 400, andHeight: 800)
        scene = SceneMock(name: "sceneMock")
        scene.project = project
        project.scene = scene

        object = SpriteObject()
        object.name = "object"
        object.scene = scene

        stage = StageMock()
        let spriteNode = CBSpriteNodeMock(spriteObject: object)
        spriteNode.mockedStage = stage
        spriteNode.spriteObject = object

        self.spriteNode = spriteNode
        object.spriteNode = spriteNode
        scene.add(object: object)

        script = WhenConditionScript()
        script.object = object
        object.scriptList.add(script!)
        formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

     func testConditionOfWhenConditionScriptSimple() {
        script.condition = Formula(float: 0)
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        script.condition = Formula(float: 1)
        XCTAssertTrue(script.checkCondition(formulaInterpreter: formulaInterpreter))
    }

    func testConditionOfWhenConditionScriptFirstExecution() {
        script.condition = Formula(float: 1)
        XCTAssertTrue(script.checkCondition(formulaInterpreter: formulaInterpreter))

        script.condition = Formula(float: 0)
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        script.condition = Formula(float: 1)
        XCTAssertTrue(script.checkCondition(formulaInterpreter: formulaInterpreter))
   }

    func testConditionOfWhenConditionScript() {
        let userVariable = UserVariable(name: "userVariable")
        let formulaTree = FormulaElement(elementType: .OPERATOR, value: AndOperator.tag)!

        userVariable.value = "0"
        project.userData.add(userVariable)

        formulaTree.rightChild = FormulaElement(elementType: .OPERATOR, value: SmallerThanOperator.tag)
        formulaTree.rightChild.leftChild = FormulaElement(elementType: .USER_VARIABLE, value: userVariable.name)
        formulaTree.rightChild.rightChild = FormulaElement(elementType: .NUMBER, value: "4")

        formulaTree.leftChild = FormulaElement(elementType: .OPERATOR, value: GreaterThanOperator.tag)
        formulaTree.leftChild.leftChild = FormulaElement(elementType: .USER_VARIABLE, value: userVariable.name)
        formulaTree.leftChild.rightChild = FormulaElement(elementType: .NUMBER, value: "2")

        let formula = Formula(formulaElement: formulaTree)!
        script.condition = formula

        userVariable.value = "0"
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        userVariable.value = "2"
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        userVariable.value = "3"
        XCTAssertTrue(script.checkCondition(formulaInterpreter: formulaInterpreter))

        userVariable.value = "4"
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        userVariable.value = "5"
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))
    }

    func testMethodCallNotifyWhenCondition() {
        XCTAssertFalse(stage.notifyWhenConditionWasCalled)
        script.condition = Formula(integer: 1)
        spriteNode.update(10)
        XCTAssertTrue(stage.notifyWhenConditionWasCalled)
    }

    func testCallNotifyWhenConditionForOtherObjects() {
        let secondObject = SpriteObject()
        secondObject.name = "object"
        secondObject.scene = scene
        let spriteNode = CBSpriteNodeMock(spriteObject: secondObject)
        spriteNode.mockedStage = stage

        secondObject.spriteNode = spriteNode
        scene.add(object: secondObject)
        script.object = secondObject

        script.condition = Formula(integer: 1)

        XCTAssertFalse(stage.notifyWhenConditionWasCalled)

        spriteNode.update(10)
        XCTAssertFalse(stage.notifyWhenConditionWasCalled)
    }
}
