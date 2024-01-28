/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class SetBackgroundAndWaitBrickTests: XCTestCase {

    var lookA: Look!
    var lookB: Look!
    var image: UIImage!

    var project: Project!
    var spriteObject: SpriteObject!
    var scene: Scene!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var whenBackgroundChangesScript: WhenBackgroundChangesScript!
    var context: CBScriptContextProtocol!
    var scheduler: CBScheduler!
    var formulaInterpreter: FormulaManager!

    override func setUp() {
        super.setUp()

        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        image = UIImage(contentsOfFile: filePath)

        lookA = LookMock(name: "LookA", absolutePath: filePath)
        lookB = LookMock(name: "LookB", absolutePath: filePath)
        scene = Scene(name: "scene")

        project = Project()
        spriteObject = SpriteObject()

        spriteObject.scene = scene
        spriteObject.name = "SpriteObjectName"
        scene.add(object: spriteObject)

        spriteObject.lookList.add(lookA!)
        spriteObject.lookList.add(lookB!)

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.scene.project = project

        script = Script()
        script.object = spriteObject

        whenBackgroundChangesScript = WhenBackgroundChangesScript()
        whenBackgroundChangesScript.object = spriteObject

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)

        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter, audioEngine: AudioEngineMock())
        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }

    func testMutableCopy() {
        let brick = SetBackgroundAndWaitBrick()
        let look = Look(name: "backgroundToCopy", filePath: "background")
        brick.look = look

        let copiedBrick: SetBackgroundAndWaitBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetBackgroundAndWaitBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.look!.isEqual(copiedBrick.look))
        XCTAssertTrue(copiedBrick.look!.isEqual(look))
        XCTAssertTrue(copiedBrick.look === brick.look)
    }

    func testSetBackgroundPart() {
        let brick = SetBackgroundAndWaitBrick()
        brick.script = script
        brick.look = lookB

        spriteNode.currentLook = lookA

        let instruction = brick.instruction()

        switch instruction {
        case let .waitExecClosure(closure):
            let expectation = self.expectation(description: "Wait for background change expectation")
            DispatchQueue.global(qos: .background).async {
                closure(self.context, self.scheduler)
                expectation.fulfill()
            }
            waitForExpectations(timeout: 10)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(lookB, spriteNode.currentLook)
    }

    func testSetBackgroundPartWithoutLook() {
        let brick = SetBackgroundAndWaitBrick()
        brick.script = script
        brick.look = nil

        spriteNode.currentLook = lookA

        let instruction = brick.instruction()

        switch instruction {
        case let .waitExecClosure(closure):
            let expectation = self.expectation(description: "Wait for background change expectation")
            DispatchQueue.global(qos: .background).async {
                closure(self.context, self.scheduler)
                expectation.fulfill()
            }
            waitForExpectations(timeout: 10)
        default:
            XCTFail("Fatal Error")
        }

        XCTAssertEqual(lookA, spriteNode.currentLook)
    }

    func testWaitConditionTrue() {
        let brick = SetBackgroundAndWaitBrick(look: lookA)
        whenBackgroundChangesScript.look = lookA

        let whenBackgroundChangesScriptContext = CBWhenBackgroundChangesScriptContext(
            whenBackgroundChangesScript: whenBackgroundChangesScript,
            spriteNode: spriteNode,
            formulaInterpreter: formulaInterpreter,
            touchManager: formulaInterpreter.touchManager,
            state: .runnable)

        scheduler.registerSpriteNode(spriteNode)
        scheduler.registerContext(whenBackgroundChangesScriptContext!)

        scheduler.startWhenBackgroundChangesContexts()

        XCTAssertTrue(brick.isWhenBackgroundChangesRunning(scheduler: scheduler))
    }

    func testWaitPartWithoutWaiting() {
        let brick = SetBackgroundAndWaitBrick()
        whenBackgroundChangesScript.look = lookA

        let whenBackgroundChangesScriptContext = CBWhenBackgroundChangesScriptContext(
            whenBackgroundChangesScript: whenBackgroundChangesScript,
            spriteNode: spriteNode,
            formulaInterpreter: formulaInterpreter,
            touchManager: formulaInterpreter.touchManager,
            state: .runnable)

        scheduler.registerSpriteNode(spriteNode)
        scheduler.registerContext(whenBackgroundChangesScriptContext!)

        scheduler.startWhenBackgroundChangesContexts()

        XCTAssertFalse(brick.isWhenBackgroundChangesRunning(scheduler: scheduler))
    }

    func testIsEqual() {
        let brickA = SetBackgroundAndWaitBrick(look: lookA)
        let brickB = SetBackgroundAndWaitBrick(look: lookA)

        XCTAssertTrue(brickA.isEqual(to: brickB))
    }

    func testIsEqualDifferentLook() {
        let brickA = SetBackgroundAndWaitBrick(look: lookA)
        let brickB = SetBackgroundAndWaitBrick(look: lookB)

        XCTAssertFalse(brickA.isEqual(to: brickB))
    }

    func testIsEqualDifferentBrick() {
        let brickA = SetBackgroundAndWaitBrick(look: lookA)
        let brickB = SetBackgroundBrick(look: lookB)

        XCTAssertFalse(brickA.isEqual(to: brickB))
    }
}
