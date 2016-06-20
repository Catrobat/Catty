/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

final class CBBackendTests: XCTestCase {

    let logger = Swell.getLogger(LoggerTestConfig.PlayerFrontendID)

    func testActionInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        
        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let showBrick = ShowBrick()
        showBrick.script = startScript
        let hideBrick = HideBrick()
        hideBrick.script = startScript
        let noteBrick = NoteBrick()
    
        startScript.brickList = [showBrick, noteBrick, hideBrick]

        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
            let instructionList = backend.instructionsForSequence(sequenceList)
        XCTAssertEqual(instructionList.count, 2, "Instruction list should contain two instructions")
        
        switch instructionList[0] {
            case let .Action(action):
                XCTAssertNotNil(action)
            default:
                XCTFail("Wrong instruction type")
        }
        
        switch instructionList[1] {
            case let .Action(action):
                XCTAssertNotNil(action)
            default:
                XCTFail("Wrong instruction type")
        }
    }
    
    func testSetLookChangeLookInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        
        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let setLookBrick = SetLookBrick()
        setLookBrick.script = startScript
        let nextLookBrick = NextLookBrick()
        nextLookBrick.script = startScript
        let note1Brick = NoteBrick()
        
        startScript.brickList = [setLookBrick, nextLookBrick, note1Brick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        XCTAssertEqual(instructionList.count, 2, "Instruction list should contain two instructions")
        
        switch instructionList[0] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[1] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
    }
    
    func testSetYSetXInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        
        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let setYBrick = SetYBrick()
        setYBrick.script = startScript
        let setXBrick = SetXBrick()
        setXBrick.script = startScript
        let note1Brick = NoteBrick()
        
        startScript.brickList = [setYBrick, setXBrick, note1Brick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        XCTAssertEqual(instructionList.count, 2, "Instruction list should contain two instructions")
        
        switch instructionList[0] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[1] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
    }
    
    func testIfElseInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        let broadcastHandler = CBBroadcastHandler(logger: self.logger)
        let scheduler = CBScheduler(logger: self.logger, broadcastHandler: broadcastHandler)
        
        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.name = "SpriteNodeName"
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let setYBrick = SetYBrick()
        setYBrick.script = startScript
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        ifLogicBeginBrick.ifCondition = Formula(integer: 1)
        let setXBrick = SetXBrick()
        setXBrick.script = startScript
        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        let ledOnBrick = LedOnBrick()
        ledOnBrick.script = startScript
        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        let vibrationBrick = VibrationBrick()
        vibrationBrick.script = startScript
        vibrationBrick.durationInSeconds = Formula(integer: 3)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        
        let context = CBStartScriptContext(startScript: startScript, spriteNode: spriteNode, state: .Running)
        
        startScript.brickList = [setYBrick, ifLogicBeginBrick, setXBrick, ifLogicElseBrick, ledOnBrick, ifLogicEndBrick, vibrationBrick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        // [[CBOperationSequence] [CBIfConditionalSequence] [CBOperationSequence]]
        let instructionList = backend.instructionsForSequence(sequenceList)
        
        
        XCTAssertEqual(instructionList.count, 6, "Instruction list should contain six instructions")
        
        switch instructionList[0] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[1] {
        case let .ExecClosure(closure):
            closure(context: context, scheduler: scheduler)
            XCTAssertEqual(context.state, CBScriptContextState.Runnable, "State should be runnable")
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[2] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[3] {
        case let .ExecClosure(closure):
            closure(context: context, scheduler: scheduler)
            XCTAssertEqual(context.state, CBScriptContextState.Runnable, "State should be runnable")
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[4] {
        case let .ExecClosure(closure):
            closure(context: context, scheduler: scheduler)
            XCTAssertEqual(context.state, CBScriptContextState.Runnable, "State should be runnable")
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[5] {
        case let .ExecClosure(closure):
            closure(context: context, scheduler: scheduler)
            XCTAssertEqual(context.state, CBScriptContextState.Runnable, "State should be runnable")
        default:
            XCTFail("Wrong instruction type")
        }
        
    }
    
    func testLoopInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        let broadcastHandler = CBBroadcastHandler(logger: self.logger)
        let scheduler = CBScheduler(logger: self.logger, broadcastHandler: broadcastHandler)
        
        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.name = "SpriteNodeName"
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let loopBeginBrick = LoopBeginBrick()
        loopBeginBrick.script = startScript
        let broadcastBrick = BroadcastBrick(message: "This is a test")
        broadcastBrick.script = startScript
        let noteBrick = NoteBrick()
        noteBrick.script = startScript
        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        waitBrick.timeToWaitInSeconds = Formula(integer: 5)
        let hideBrick = HideBrick()
        hideBrick.script = startScript
        let turnRightBrick = TurnRightBrick()
        turnRightBrick.script = startScript
        turnRightBrick.degrees = Formula(integer: 2)
        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = loopBeginBrick
        loopBeginBrick.loopEndBrick = loopEndBrick
        
        let context = CBStartScriptContext(startScript: startScript, spriteNode: spriteNode, state: .Running)
        
        startScript.brickList = [loopBeginBrick, broadcastBrick, noteBrick, waitBrick, hideBrick, turnRightBrick, loopEndBrick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        
        
        XCTAssertEqual(instructionList.count, 6, "Instruction list should contain six instructions")
        
        switch instructionList[0] {
        case let .ExecClosure(closure):
            closure(context: context, scheduler: scheduler)
            XCTAssertEqual(context.state, CBScriptContextState.Runnable, "State should be runnable")
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[1] {
        case .HighPriorityExecClosure(_):
            break;
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[2] {
        case .WaitExecClosure(_):
            break;
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[3] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[4] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[5] {
        case .HighPriorityExecClosure(_):
            break;
        default:
            XCTFail("Wrong instruction type")
        }
    }
}
