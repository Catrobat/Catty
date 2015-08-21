/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

final class CBPlayerFrontendTests : XCTestCase {

    let logger = Swell.getLogger(LoggerTestConfig.PlayerFrontendID)

    func testComputeOperationSequence() {
        let frontend = CBPlayerFrontend(logger: self.logger, program: nil)
        let whenScript = WhenScript()
        whenScript.action = kWhenScriptDefaultAction
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(integer: 2)
        let noteBrick = NoteBrick()
        let broadcastBrick = BroadcastBrick()
        let broadcastWaitBrick = BroadcastWaitBrick()
        let playSoundBrick = PlaySoundBrick()
        let stopAllSoundsBrick = StopAllSoundsBrick()
        let speakBrick = SpeakBrick()
        let changeVolumeByNBrick = ChangeVolumeByNBrick()
        let setVolumeToBrick = SetVolumeToBrick()
        let setVariableBrick = SetVariableBrick()
        let changeVariableBrick = ChangeVariableBrick()
        let ledOnBrick = LedOnBrick()
        let ledOffBrick = LedOffBrick()
        let vibrationBrick = VibrationBrick()
        whenScript.brickList = [waitBrick, noteBrick, broadcastBrick, broadcastWaitBrick,
            playSoundBrick, speakBrick, stopAllSoundsBrick, speakBrick, changeVolumeByNBrick,
            setVolumeToBrick, setVariableBrick, changeVariableBrick, ledOnBrick, ledOffBrick,
            vibrationBrick]

        let scriptSequenceList = frontend.computeSequenceListForScript(whenScript)
        XCTAssertTrue(scriptSequenceList.script === whenScript)
        XCTAssertEqual(scriptSequenceList.count, 1, "Script sequence list should contain only one (operation) sequence")
        let sequenceList = scriptSequenceList.sequenceList
        XCTAssertNotNil(sequenceList.rootSequenceList)
        XCTAssertTrue(sequenceList.rootSequenceList! === scriptSequenceList)
        XCTAssertEqual(sequenceList.count, 1, "Sequence list should contain only one (operation) sequence")
        XCTAssertFalse(sequenceList.isEmpty(), "WTH!!! Sequence list is empty!")
        let sequence = sequenceList.sequenceList.first
        XCTAssertTrue(sequence is CBOperationSequence)
        let operationSequence = sequence as! CBOperationSequence
        XCTAssertTrue(operationSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(operationSequence.isEmpty())

        // WhenScript contains 1 NoteBrick => NoteBricks are ommited => therefore "- 1"
        XCTAssertEqual(operationSequence.operationList.count, (whenScript.brickList.count - 1))
        var index = 0
        for brick in whenScript.brickList {
            if brick is NoteBrick {
                continue // NoteBricks are ommited
            }
            XCTAssertTrue(operationSequence.operationList[index].brick === brick)
            ++index
        }
    }

    func testComputeIfElseConditionalSequence() {
        let frontend = CBPlayerFrontend(logger: self.logger, program: nil)
        let whenScript = WhenScript()
        whenScript.action = kWhenScriptDefaultAction
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(integer: 2)
        let noteBrick = NoteBrick()
        let broadcastBrick = BroadcastBrick()
        let broadcastWaitBrick = BroadcastWaitBrick()
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.ifCondition = Formula(integer: 1)
        let playSoundBrick = PlaySoundBrick()
        let stopAllSoundsBrick = StopAllSoundsBrick()
        let speakBrick = SpeakBrick()
        let ifLogicElseBrick = IfLogicElseBrick()
        let changeVolumeByNBrick = ChangeVolumeByNBrick()
        let setVolumeToBrick = SetVolumeToBrick()
        let setVariableBrick = SetVariableBrick()
        let changeVariableBrick = ChangeVariableBrick()
        let ifLogicEndBrick = IfLogicEndBrick()
        let ledOnBrick = LedOnBrick()
        let ledOffBrick = LedOffBrick()
        let vibrationBrick = VibrationBrick()
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

        let scriptSequenceList = frontend.computeSequenceListForScript(whenScript)
        XCTAssertTrue(scriptSequenceList.script === whenScript)
        XCTAssertEqual(scriptSequenceList.count, 3, "Sequence list should look like this: [CBOperationSequence, CBIfConditionalSequence, CBOperationSequence]")
        let sequenceList = scriptSequenceList.sequenceList
        XCTAssertNotNil(sequenceList.rootSequenceList)
        XCTAssertTrue(sequenceList.rootSequenceList! === scriptSequenceList)
        XCTAssertEqual(sequenceList.count, 3, "Sequence list should look like this: [CBOperationSequence, CBIfConditionalSequence, CBOperationSequence]")
        XCTAssertFalse(sequenceList.isEmpty(), "WTH!!! Sequence list is empty!")

        let firstSequence = sequenceList.sequenceList[0]
        XCTAssertTrue(firstSequence is CBOperationSequence)
        let operationSequence = firstSequence as! CBOperationSequence
        XCTAssertTrue(operationSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(operationSequence.isEmpty())
        // WhenScript contains 1 NoteBrick => NoteBricks are ommited => therefore "- 1"
        XCTAssertEqual(operationSequence.operationList.count, (preIfElseOperationSequenceBricks.count - 1))
        var index = 0
        for brick in preIfElseOperationSequenceBricks {
            if brick is NoteBrick {
                continue // NoteBricks are ommited
            }
            XCTAssertTrue(operationSequence.operationList[index].brick === brick)
            ++index
        }

        let secondSequence = sequenceList.sequenceList[1]
        XCTAssertTrue(secondSequence is CBIfConditionalSequence)
        let ifConditionalSequence = secondSequence as! CBIfConditionalSequence
        XCTAssertTrue(ifConditionalSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(ifConditionalSequence.isEmpty())
        XCTAssertTrue(ifConditionalSequence.sequenceList.rootSequenceList! === scriptSequenceList)
        let ifSequenceList = ifConditionalSequence.sequenceList.sequenceList
        XCTAssertEqual(ifSequenceList.count, 1) // 1 operation list!
        XCTAssertTrue(ifSequenceList.first is CBOperationSequence)
        let ifOperationSequence = ifSequenceList.first as! CBOperationSequence
        XCTAssertTrue(ifOperationSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(ifOperationSequence.isEmpty())
        XCTAssertEqual(ifOperationSequence.operationList.count, ifOperationSequenceBricks.count)
        index = 0
        for brick in ifOperationSequenceBricks {
            XCTAssertTrue(ifOperationSequence.operationList[index].brick === brick)
            ++index
        }
        XCTAssertNotNil(ifConditionalSequence.elseSequenceList)
        XCTAssertTrue(ifConditionalSequence.elseSequenceList!.rootSequenceList! === scriptSequenceList)
        let elseSequenceList = ifConditionalSequence.elseSequenceList!.sequenceList
        XCTAssertEqual(elseSequenceList.count, 1) // 1 operation list!
        XCTAssertTrue(elseSequenceList.first is CBOperationSequence)
        let elseOperationSequence = elseSequenceList.first as! CBOperationSequence
        XCTAssertTrue(elseOperationSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(elseOperationSequence.isEmpty())
        XCTAssertEqual(elseOperationSequence.operationList.count, elseOperationSequenceBricks.count)
        index = 0
        for brick in elseOperationSequenceBricks {
            XCTAssertTrue(elseOperationSequence.operationList[index].brick === brick)
            ++index
        }

        let thirdSequence = sequenceList.sequenceList[2]
        XCTAssertTrue(thirdSequence is CBOperationSequence)
        let postOperationSequence = thirdSequence as! CBOperationSequence
        XCTAssertTrue(postOperationSequence.rootSequenceList! === scriptSequenceList)
        XCTAssertFalse(postOperationSequence.isEmpty())
        XCTAssertEqual(postOperationSequence.operationList.count, postIfElseOperationSequenceBricks.count)
        index = 0
        for brick in postIfElseOperationSequenceBricks {
            XCTAssertTrue(postOperationSequence.operationList[index].brick === brick)
            ++index
        }
    }

}
