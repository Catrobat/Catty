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

@objc protocol CBPlayerBackendProtocol {
    func executionContextForScriptSequenceList(scriptSequenceList: CBScriptSequenceList,
        spriteNode: CBSpriteNode) -> CBScriptExecContext
}

final class CBPlayerBackend : NSObject, CBPlayerBackendProtocol {

    // MARK: - Properties
    var logger : CBLogger
    weak var scheduler : CBPlayerSchedulerProtocol?
    weak var broadcastHandler : CBPlayerBroadcastHandlerProtocol?

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBPlayerSchedulerProtocol?,
        broadcastHandler: CBPlayerBroadcastHandlerProtocol?)
    {
        self.logger = logger
        self.scheduler = scheduler
        self.broadcastHandler = broadcastHandler
    }

    convenience init(logger: CBLogger) {
        self.init(logger: logger, scheduler: nil, broadcastHandler: nil)
    }

    // MARK: - Operations
    func executionContextForScriptSequenceList(scriptSequenceList: CBScriptSequenceList,
        spriteNode: CBSpriteNode) -> CBScriptExecContext
    {
        if scheduler == nil {
            logger.warn("No scheduler set!")
        }
        logger.info("Generating ExecContext of \(scriptSequenceList.script)")
        var instructionList = _instructionListForSequenceList(scriptSequenceList.sequenceList)
        return CBScriptExecContext(script: scriptSequenceList.script, state: .Runnable,
            scriptSequenceList: scriptSequenceList, instructionList: instructionList)
    }

    private func _instructionListForSequenceList(sequenceList: CBSequenceList) -> [CBExecClosure] {
        var instructionList = [CBExecClosure]()
        for sequence in sequenceList.reverseSequenceList().sequenceList {
            if let operationSequence = sequence as? CBOperationSequence {
                instructionList += _instructionListForOperationSequence(operationSequence)
            } else if let ifSequence = sequence as? CBIfConditionalSequence {
                // if else sequence
                instructionList += { [weak self] in
                    let script = ifSequence.rootSequenceList?.script
                    assert(script != nil, "This should never happen!")
                    if ifSequence.checkCondition() {
                        if let instructionList = self?._instructionListForSequenceList(ifSequence.sequenceList) {
                            self?.scheduler?.addInstructionsAfterCurrentInstructionOfScript(script!, instructionList: instructionList)
                        }
                    } else if ifSequence.elseSequenceList != nil {
                        if let instructionList = self?._instructionListForSequenceList(ifSequence.elseSequenceList!) {
                            self?.scheduler?.addInstructionsAfterCurrentInstructionOfScript(script!, instructionList: instructionList)
                        }
                    }
                    self?.scheduler?.setStateForScript(script!, state: .RunningMature)
                    self?.scheduler?.runNextInstructionOfScript(script!)
                }
            } else if let conditionalSequence = sequence as? CBConditionalSequence {
                // loop sequence
                instructionList += _instructionListForLoopSequence(conditionalSequence)
            }
        }
        return instructionList
    }

    private func _instructionListForLoopSequence(conditionalSequence: CBConditionalSequence) -> CBExecClosure {
        let localUniqueID = NSString.localUniqueIdenfier()
        let loopInstruction : CBExecClosure = { [weak self] in
            let scriptSequenceList = conditionalSequence.rootSequenceList
            assert(scriptSequenceList != nil, "This should never happen!")
            let script = scriptSequenceList!.script
            let scheduler = self?.scheduler
            if conditionalSequence.checkCondition() {
                let startTime = NSDate()
                var instructionList = [CBExecClosure]()
                // add loop end check
                let bodyInstructions = self?._instructionListForSequenceList(conditionalSequence.sequenceList)
                let numberOfBodyInstructions = bodyInstructions?.count
                instructionList += {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    let startIndex = scheduler?.currentInstructionPointerPositionOfScript(script)
                    assert(startIndex >= 0, "Unable to retrieve instruction pointer position of current script!")
                    let previousloopEndInstructionPointerPosition = startIndex!
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        let duration = NSDate().timeIntervalSinceDate(startTime)
                        self?.logger.debug("  Duration for Sequence: \(duration*1000)ms")
                        if duration < 0.02 {
                            NSThread.sleepForTimeInterval(0.02 - duration)
                        }
                        // now switch back to the main queue for executing the sequence!
                        dispatch_async(dispatch_get_main_queue(), {
                            if let numOfBodyInstructions = numberOfBodyInstructions {
                                let numberOfInstructionsOfPreviousLoopIteration = numOfBodyInstructions + 2 // body + head + tail
                                scheduler?.removeNumberOfInstructions(
                                    numberOfInstructionsOfPreviousLoopIteration,
                                    instructionStartIndex: previousloopEndInstructionPointerPosition,
                                    inScript: script
                                )
                            }
                            let instruction = scriptSequenceList!.whileSequences[localUniqueID]
                            assert(instruction != nil, "This should NEVER happen!")
                            scheduler?.addInstructionAfterCurrentInstructionOfScript(script, instruction: instruction!)
                            scheduler?.setStateForScript(script, state: .RunningMature)
                            scheduler?.runNextInstructionOfScript(script)
                            return
                        })
                    })
                }
                // now add all instructions within the loop
                if let bodyInstructs = bodyInstructions {
                    instructionList += bodyInstructs
                }
                scheduler?.addInstructionsAfterCurrentInstructionOfScript(script, instructionList: instructionList)
                scheduler?.runNextInstructionOfScript(script)
            } else {
                // leaving loop now!
                conditionalSequence.resetCondition() // reset loop counter right now
                scheduler?.setStateForScript(script, state: .RunningMature)
                scheduler?.runNextInstructionOfScript(script) // run next action after loop
            }
        }
        assert(conditionalSequence.rootSequenceList != nil, "This should never happen!")
        conditionalSequence.rootSequenceList!.whileSequences[localUniqueID] = loopInstruction
        return loopInstruction
    }

    private func _instructionListForOperationSequence(operationSequence: CBOperationSequence)
        -> [CBExecClosure]
    {
        var instructionList = [CBExecClosure]()
        for operation in operationSequence.operationList.reverse() {
            if let broadcastBrick = operation.brick as? BroadcastBrick {
                instructionList += { [weak self] in
                    self?.broadcastHandler?.performBroadcastWithMessage(broadcastBrick.broadcastMessage,
                        senderScript: broadcastBrick.script, broadcastType: .Broadcast)
                }
            } else if let broadcastWaitBrick = operation.brick as? BroadcastWaitBrick {
                instructionList += { [weak self] in
                    self?.broadcastHandler?.performBroadcastWithMessage(broadcastWaitBrick.broadcastMessage,
                        senderScript: broadcastWaitBrick.script, broadcastType: .BroadcastWait)
                }
            } else {
                instructionList += { [weak self] in
                    let scriptExecContext = self?.scheduler?.scriptExecContextDict[operation.brick.script]
                    assert(scriptExecContext != nil, "FATAL: ScriptExecContext added to Scheduler!")
                    if let waitBrick = operation.brick as? WaitBrick {
                        self?.scheduler?.setStateForScript(waitBrick.script, state: .RunningMature)
                    }
                    scriptExecContext?.runAction(operation.brick.action(), completion:{
                        // the script must continue here. upcoming actions are executed!!
                        self?.scheduler?.runNextInstructionOfScript(operation.brick.script)
                    })
                }
            }
        }
        return instructionList
    }
}
