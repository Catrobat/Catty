/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class ChooseCameraBrickTests: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var scheduler: CBScheduler!
    var program: Program!
    var script: Script!
    var context: CBScriptContextProtocol!

    override func setUp() {
        program = Program()

        spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode
        spriteObject.program = program

        script = Script()
        script.object = spriteObject

        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let formulaInterpreter = FormulaManager(sceneSize: Util.screenSize(true))
        scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter)

        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter)
    }

    func testDefaultCameraPosition() {
        // front camera should be default
        CameraPreviewHandler.shared().reset()
        XCTAssertEqual(AVCaptureDevice.Position.front, CameraPreviewHandler.shared().cameraPosition)
    }

    func testChooseCameraBrick() {
        let brick = ChooseCameraBrick()
        brick.script = script

        let instruction = brick.instruction()

        switch instruction {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            break
        }

        XCTAssertEqual(AVCaptureDevice.Position.back, CameraPreviewHandler.shared().cameraPosition)
    }

    func testChooseCameraBrickInitWithZero() {
        let brick = ChooseCameraBrick(choice: 0)
        brick?.script = script

        let instruction = brick?.instruction()

        switch instruction! {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            break
        }

        XCTAssertEqual(AVCaptureDevice.Position.back, CameraPreviewHandler.shared().cameraPosition)
    }

    func testChooseCameraBrickInitWithOne() {
        let brick = ChooseCameraBrick(choice: 1)
        brick?.script = script

        let instruction = brick?.instruction()

        switch instruction! {
        case let .execClosure(closure):
            closure(context, scheduler)
        default:
            break
        }

        XCTAssertEqual(AVCaptureDevice.Position.front, CameraPreviewHandler.shared().cameraPosition)
    }
}
