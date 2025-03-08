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

final class CBSchedulerTests: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var startScript: StartScript!
    var interpreter: FormulaInterpreterProtocol!
    var touchManager: TouchManagerProtocol!
    var scheduler: CBScheduler!

    override func setUp() {
        let scene = Scene()

        spriteObject = SpriteObjectMock(name: "Name", scene: scene)
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)

        startScript = StartScript()
        startScript.object = spriteObject

        let logger = Swell.getLogger(LoggerTestConfig.PlayerSchedulerID)!
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let audioEngine = AudioEngineMock()

        interpreter = FormulaManager(stageSize: CGSize.zero, landscapeMode: false)
        touchManager = TouchManagerMock()

        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: interpreter, audioEngine: audioEngine)

        scheduler.registerSpriteNode(spriteNode)
    }

    func testIsContextScheduled() {
        let context = CBScriptContext(script: startScript, spriteNode: spriteNode, formulaInterpreter: interpreter, touchManager: touchManager)!

        XCTAssertFalse(scheduler.isContextScheduled(context))

        scheduler.registerContext(context)
        scheduler.scheduleContext(context)

        XCTAssertTrue(scheduler.isContextScheduled(context))
    }

    func testIsContextScheduledForDifferentObjectName() {
        let context = CBScriptContext(script: startScript, spriteNode: spriteNode, formulaInterpreter: interpreter, touchManager: touchManager)!

        scheduler.registerContext(context)
        scheduler.scheduleContext(context)

        context.spriteNode.name = "DifferentName"
        XCTAssertFalse(scheduler.isContextScheduled(context))
    }

    func testIsWhenBackgroundChangesContextScheduled() {
        let look = LookMock(name: "Look", absolutePath: "path")

        let script = WhenBackgroundChangesScript()
        script.object = spriteObject
        script.look = look

        let context = CBWhenBackgroundChangesScriptContext(whenBackgroundChangesScript: script, spriteNode: spriteNode, formulaInterpreter: interpreter, touchManager: touchManager, state: .runnable)!

        XCTAssertFalse(scheduler.isWhenBackgroundChangesContextScheduled(look: look))

        scheduler.registerContext(context)
        scheduler.scheduleContext(context)

        XCTAssertTrue(scheduler.isWhenBackgroundChangesContextScheduled(look: look))
    }

    func testIsWhenBackgroundChangesContextScheduledDifferentLook() {
        let lookA = LookMock(name: "LookA", absolutePath: "pathA")
        let lookB = LookMock(name: "LookB", absolutePath: "pathB")

        let script = WhenBackgroundChangesScript()
        script.object = spriteObject
        script.look = lookA

        let context = CBWhenBackgroundChangesScriptContext(whenBackgroundChangesScript: script, spriteNode: spriteNode, formulaInterpreter: interpreter, touchManager: touchManager, state: .runnable)!

        scheduler.registerContext(context)
        scheduler.scheduleContext(context)

        XCTAssertFalse(scheduler.isWhenBackgroundChangesContextScheduled(look: lookB))
    }
}
