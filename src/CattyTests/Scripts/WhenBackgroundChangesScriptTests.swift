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

final class WhenBackgroundChangesScriptTests: XCTestCase {

    var project: Project!
    var object: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: WhenBackgroundChangesScript!
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

        self.spriteNode = spriteNode
        object.spriteNode = spriteNode
        scene.add(object: object)

        script = WhenBackgroundChangesScript()
        script.object = object
        formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testConditionOfWhenBackgroundChangesScript() {

        let look1 = Look(name: "testLook1", filePath: "testPath1")
        let look2 = Look(name: "testLook2", filePath: "testPath2")

        object.add(look1, andSaveToDisk: false)
        object.add(look2, andSaveToDisk: false)

        script.look = look1
        spriteNode.currentLook = look2
        XCTAssertFalse(script.checkCondition(formulaInterpreter: formulaInterpreter))

        spriteNode.currentLook = look1
        XCTAssertTrue(script.checkCondition(formulaInterpreter: formulaInterpreter))
    }

    func testMethodCallNotifyBackgroundChanges() {

        let look1 = Look(name: "testLook1", filePath: "testPath1")
        let look2 = Look(name: "testLook2", filePath: "testPath2")

        object.add(look1, andSaveToDisk: false)
        object.add(look2, andSaveToDisk: false)

        XCTAssertFalse(stage.notifyBackgroundChangeWasCalled)

        script.look = look1
        spriteNode.currentLook = look1

        XCTAssertTrue(stage.notifyBackgroundChangeWasCalled)
    }

    func testNoCallNotifyBackgroundChangesForOtherObjects() {

        let secondObject = SpriteObject()
        secondObject.name = "object"
        secondObject.scene = scene
        let spriteNode = CBSpriteNodeMock(spriteObject: secondObject)
        spriteNode.mockedStage = stage

        secondObject.spriteNode = spriteNode
        scene.add(object: secondObject)
        script.object = secondObject

        let look1 = Look(name: "testLook1", filePath: "testPath1")
        let look2 = Look(name: "testLook2", filePath: "testPath2")

        secondObject.add(look1, andSaveToDisk: false)
        secondObject.add(look2, andSaveToDisk: false)

        XCTAssertFalse(stage.notifyBackgroundChangeWasCalled)

        script.look = look1
        spriteNode.currentLook = look1

        XCTAssertFalse(stage.notifyBackgroundChangeWasCalled)
    }
}
