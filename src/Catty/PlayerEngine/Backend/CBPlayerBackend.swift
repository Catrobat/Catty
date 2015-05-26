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

final class CBPlayerBackend : NSObject {

    // MARK: - Properties
    var logger : CBLogger
    weak var scheduler : CBPlayerScheduler?

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBPlayerScheduler?) {
        self.logger = logger
        self.scheduler = scheduler
    }

    convenience init(logger: CBLogger) {
        self.init(logger: logger, scheduler: nil)
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
        return CBScriptExecContext(script: scriptSequenceList.script,
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
                                scheduler?.removeInstructionsBeforeCurrentInstruction(
                                    numberOfInstructions: numberOfInstructionsOfPreviousLoopIteration,
                                    inScript: script
                                )
                            }
                            let instruction = scriptSequenceList!.whileSequences[localUniqueID]
                            assert(instruction != nil, "This should NEVER happen!")
                            scheduler?.addInstructionAfterCurrentInstructionOfScript(script, instruction: instruction!)
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
                    self?.scheduler?.performBroadcastWithMessage(broadcastBrick.broadcastMessage,
                        senderScript: broadcastBrick.script)
                }
            } else if let broadcastWaitBrick = operation.brick as? BroadcastWaitBrick {
                // TODO!!!
                // cancel all upcoming actions if BroadcastWaitBrick calls its own script
                if let broadcastScript = broadcastWaitBrick.script as? BroadcastScript {
                    assert(broadcastWaitBrick.broadcastMessage != nil, "broadcastMessage in BroadcastWaitBrick must NOT be nil")
                    assert(broadcastScript.receivedMessage != nil, "receivedMessage in BroadcastScript must NOT be nil")
                    if broadcastWaitBrick.broadcastMessage == broadcastScript.receivedMessage {
                        // DO NOT call completionBlock here so that upcoming actions are ignored!
                        instructionList += { [weak self] in
                            // end of script reached!! Scripts will be aborted due to self-calling broadcast
                            if broadcastScript.calledByOtherScriptBroadcastWait {
                                broadcastScript.signalForWaitingBroadcasts() // signal finished broadcast!
                            }
                            //                            NSDebug(@"BroadcastScript ended due to self broadcastWait!");
                            // finally perform normal (!) broadcast
                            // no waiting required, since all upcoming actions in the sequence are omitted!
                            self?.scheduler?.performBroadcastWithMessage(broadcastWaitBrick.broadcastMessage,
                                senderScript:broadcastScript)

                            // end of script reached!! Scripts will be aborted due to self-calling broadcast
                            // the final closure will never be called (except when script is canceled!) due
                            // to self-broadcast
                            println("SCRIPT HAS BEEN RESTARTED DUE TO SELF-BROADCASTWAIT!!")
                        }
                        continue
                    }
                }
                instructionList += { [weak self] in
                    if let scheduler = self?.scheduler {
                        broadcastWaitBrick.performBroadcastAndWaitWithScheduler(scheduler)
                    }
                }
            } else {
                instructionList += { [weak self] in
                    let scriptExecContext = self?.scheduler?.scriptExecContextDict[operation.brick.script]
                    assert(scriptExecContext != nil, "FATAL: ScriptExecContext added to Scheduler!")
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
