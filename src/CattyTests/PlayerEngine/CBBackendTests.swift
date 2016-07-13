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
        case .ExecClosure(_):
            break;
        default:
            XCTFail("Wrong instruction type")
        }
        
        switch instructionList[2] {
        case let .Action(action):
            XCTAssertNotNil(action)
        default:
            XCTFail("Wrong instruction type")
        }
        
        for counter in 3...(instructionList.count - 1) {
            switch instructionList[counter] {
            case .ExecClosure(_):
                break;
            default:
                XCTFail("Wrong instruction type for \(counter)")
            }
        }
        
        
    }
    
    func testLoopInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        
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
        let broadcastBrick = BroadcastBrick()
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
        turnRightBrick.degrees = Formula(integer: 20)
        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = loopBeginBrick
        loopBeginBrick.loopEndBrick = loopEndBrick
        
        startScript.brickList = [loopBeginBrick, broadcastBrick, noteBrick, waitBrick, hideBrick, turnRightBrick, loopEndBrick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        
        
        XCTAssertEqual(instructionList.count, 6, "Instruction list should contain six instructions")
        
        switch instructionList[0] {
        case .ExecClosure(_):
            break;
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
    
    func testIfElseConditionalInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)
        let program = Program.defaultProgramWithName("ProgramName", programID: "123")
        
        let whenScript = WhenScript()
        whenScript.action = kWhenScriptDefaultAction
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.name = "SpriteNodeName"
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        spriteObject.program = program
        whenScript.object = spriteObject
        
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(integer: 2)
        waitBrick.script = whenScript
        let noteBrick = NoteBrick()
        noteBrick.script = whenScript
        let broadcastBrick = BroadcastBrick()
        broadcastBrick.script = whenScript
        let broadcastWaitBrick = BroadcastWaitBrick()
        broadcastWaitBrick.script = whenScript
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.ifCondition = Formula(integer: 1)
        ifLogicBeginBrick.script = whenScript
        let playSoundBrick = PlaySoundBrick()
        playSoundBrick.script = whenScript
        let stopAllSoundsBrick = StopAllSoundsBrick()
        stopAllSoundsBrick.script = whenScript
        let speakBrick = SpeakBrick()
        speakBrick.script = whenScript
        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = whenScript
        let changeVolumeByNBrick = ChangeVolumeByNBrick()
        changeVolumeByNBrick.script = whenScript
        let setVolumeToBrick = SetVolumeToBrick()
        setVolumeToBrick.script = whenScript
        let setVariableBrick = SetVariableBrick()
        setVariableBrick.script = whenScript
        let changeVariableBrick = ChangeVariableBrick()
        changeVariableBrick.script = whenScript
        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = whenScript
        let ledOnBrick = LedOnBrick()
        ledOnBrick.script = whenScript
        let ledOffBrick = LedOffBrick()
        ledOffBrick.script = whenScript
        let vibrationBrick = VibrationBrick()
        vibrationBrick.script = whenScript
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        
        let preIfElseOperationSequenceBricks = [waitBrick, noteBrick, broadcastBrick,
                                                broadcastWaitBrick]
        let ifOperationSequenceBricks = [playSoundBrick, speakBrick, stopAllSoundsBrick, speakBrick]
        let elseOperationSequenceBricks = [changeVolumeByNBrick, setVolumeToBrick,
                                           setVariableBrick, changeVariableBrick]
        let postIfElseOperationSequenceBricks = [ledOnBrick, ledOffBrick, vibrationBrick]
        
        var scriptBrickList = preIfElseOperationSequenceBricks
        scriptBrickList += [ifLogicBeginBrick]
        scriptBrickList += ifOperationSequenceBricks
        scriptBrickList += [ifLogicElseBrick]
        scriptBrickList += elseOperationSequenceBricks
        scriptBrickList += [ifLogicEndBrick]
        scriptBrickList += postIfElseOperationSequenceBricks
        whenScript.brickList = NSMutableArray(array: scriptBrickList)
        
        let sequenceList = frontend.computeSequenceListForScript(whenScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        
        XCTAssertEqual(instructionList.count, 16, "Instruction list should contain sixteen instructions")
        
        switch instructionList[0] { // waitBrick
        case .WaitExecClosure(_):
            break;
        default:
            XCTFail("Wrong insruction type")
        }
        
        switch instructionList[1] { // broadcastBrick
        case .HighPriorityExecClosure(_):
            break;
        default:
            XCTFail("Wrong insruction type")
        }
        
        switch instructionList[2] { // broadcastWaitBrick
        case .HighPriorityExecClosure(_):
            break;
        default:
            XCTFail("Wrong insruction type")
        }
        
        switch instructionList[3] { // ifLogicBeginBrick
        case .ExecClosure(_):
            break;
        default:
            XCTFail("Wrong insruction type")
        }
            
        switch instructionList[4] { // playSoundBrick
        case .InvalidInstruction():
            break;
        default:
            XCTFail("Wrong insruction type")
        }
        
        // speakBrick, stopAllSoundsBrick, speakBrick, ifLogicElseBrick, changeVolumeByNBrick, setVolumeToBrick, setVariableBrick, changeVariableBrick, ledOnBrick, ledOffBrick, vibrationBrick
        
        for counter in 5...(instructionList.count - 1) {
            switch instructionList[counter] {
            case .ExecClosure(_):
                break;
            default:
                XCTFail("Wrong insruction type for \(counter)")
            }
        }
    }
    
    func testLookMoveInstruction() {
        let frontend = CBFrontend(logger: self.logger, program: nil)
        let backend = CBBackend(logger: self.logger)

        let startScript = StartScript()
        let spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode()
        spriteNode.name = "SpriteNodeName"
        spriteNode.spriteObject = spriteObject
        spriteObject.name = "SpriteObjectName"
        spriteObject.spriteNode = spriteNode
        startScript.object = spriteObject
        
        let setBrightnessBrick = SetBrightnessBrick()
        setBrightnessBrick.script = startScript
        setBrightnessBrick.brightness = Formula(integer: 40)
        let setSizeToBrick = SetSizeToBrick()
        setSizeToBrick.script = startScript
        let setTransparencyBrick = SetTransparencyBrick()
        setTransparencyBrick.script = startScript
        setTransparencyBrick.transparency = Formula(integer: 60)
        let clearGraphicEffectBrick = ClearGraphicEffectBrick()
        clearGraphicEffectBrick.script = startScript
        let placeAtBrick = PlaceAtBrick()
        placeAtBrick.script = startScript
        let pointInDirectionBrick = PointInDirectionBrick()
        pointInDirectionBrick.script = startScript
        let changeXByNBrick = ChangeXByNBrick()
        changeXByNBrick.script = startScript
        changeXByNBrick.xMovement = Formula(integer: 2)
        
        
        startScript.brickList = [setBrightnessBrick, setSizeToBrick, setTransparencyBrick, clearGraphicEffectBrick, placeAtBrick, pointInDirectionBrick, changeXByNBrick]
        
        let sequenceList = frontend.computeSequenceListForScript(startScript).sequenceList
        let instructionList = backend.instructionsForSequence(sequenceList)
        
        XCTAssertEqual(instructionList.count, 7, "Instruction list should contain eight instructions")
        
        for counter in 0...(instructionList.count - 1) {
            switch instructionList[counter] {
            case let .Action(action):
                XCTAssertNotNil(action)
            default:
                XCTFail("Wrong instruction type for \(counter)")
            }
        }
        
    }
}
