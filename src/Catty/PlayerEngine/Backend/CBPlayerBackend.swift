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

protocol CBPlayerBackendProtocol {
    func scriptContextForSequenceList(sequenceList: CBScriptSequenceList) -> CBScriptContextAbstract
}

final class CBPlayerBackend : CBPlayerBackendProtocol {

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
    func scriptContextForSequenceList(sequenceList: CBScriptSequenceList) -> CBScriptContextAbstract
    {
        if scheduler == nil {
            logger.warn("No scheduler set!")
        }

        let script = sequenceList.script
        logger.info("Generating ScriptContext of \(script)")

        // create right context depending on script type
        var scriptContext: CBScriptContextAbstract? = nil
        if let startScript = script as? StartScript {
            scriptContext = CBStartScriptContext(startScript: startScript, state: .Runnable, scriptSequenceList: sequenceList)
        } else if let whenScript = script as? WhenScript {
            scriptContext = CBWhenScriptContext(whenScript: whenScript, state: .Runnable, scriptSequenceList: sequenceList)
        } else if let bcScript = script as? BroadcastScript {
            scriptContext = CBBroadcastScriptContext(broadcastScript: bcScript, state: .Runnable, scriptSequenceList: sequenceList)
        } else {
            fatalError("Unknown script! THIS SHOULD NEVER HAPPEN!")
        }

        // generated instructions and add them to script context
        let instructionList = _instructionsForSequence(sequenceList.sequenceList, context: scriptContext!)
        for instruction in instructionList {
            scriptContext! += instruction
        }
        return scriptContext!
    }

    private func _instructionsForSequence(sequenceList: CBSequenceList, context: CBScriptContextAbstract) -> [CBExecClosure]
    {
        var instructionList = [CBExecClosure]()
        for sequence in sequenceList.reverseSequenceList().sequenceList {
            if let operationSequence = sequence as? CBOperationSequence {
                instructionList += _instructionsForOperationSequence(operationSequence, context: context)
            } else if let ifSequence = sequence as? CBIfConditionalSequence {
                // if else sequence
                // TODO............
//                instructionList += { [weak self] in
//                    let script = ifSequence.rootSequenceList?.script
//                    assert(script != nil, "This should never happen!")
//                    if ifSequence.checkCondition() {
//                        if let instructionList = self?._instructionListForSequenceList(ifSequence.sequenceList) {
//                            self?.scheduler?.addInstructionsAfterCurrentInstructionOfScript(script!, instructionList: instructionList)
//                        }
//                    } else if ifSequence.elseSequenceList != nil {
//                        if let instructionList = self?._instructionListForSequenceList(ifSequence.elseSequenceList!) {
//                            self?.scheduler?.addInstructionsAfterCurrentInstructionOfScript(script!, instructionList: instructionList)
//                        }
//                    }
//                    self?.scheduler?.runNextInstructionOfScript(script!)
//                }
            } else if let conditionalSequence = sequence as? CBConditionalSequence {
                // loop sequence
                instructionList += _instructionsForLoopSequence(conditionalSequence, context: context)
            }
        }
        return instructionList
    }

    private func _instructionsForLoopSequence(conditionalSequence: CBConditionalSequence,
        context: CBScriptContextAbstract) -> CBExecClosure
    {
        let localUniqueID = NSString.localUniqueIdenfier()
        let loopInstruction : CBExecClosure = { [weak self] in
            let scriptSequenceList = conditionalSequence.rootSequenceList
            assert(scriptSequenceList != nil, "This should never happen!")
//            let script = scriptSequenceList!.script
            let scheduler = self?.scheduler
            if conditionalSequence.checkCondition() {
                let startTime = NSDate()
                var instructionList = [CBExecClosure]()
                // add loop end check
                let bodyInstructions = self?._instructionsForSequence(conditionalSequence.sequenceList, context: context)
                let numberOfBodyInstructions = bodyInstructions?.count
                instructionList += {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    let startIndex = context.reverseInstructionPointer
                    let previousLoopEndInstructionPointerPosition = startIndex
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
                                context.removeNumberOfInstructions(
                                    numberOfInstructionsOfPreviousLoopIteration,
                                    instructionStartIndex: previousLoopEndInstructionPointerPosition
                                )
                            }
                            let instruction = scriptSequenceList!.whileSequences[localUniqueID]
                            assert(instruction != nil, "This should NEVER happen!")
                            context.addInstructionAtCurrentPosition(instruction!)
                            scheduler?.runNextInstructionOfContext(context)
                            return
                        })
                    })
                }
                // now add all instructions within the loop
                if let bodyInstructs = bodyInstructions {
                    instructionList += bodyInstructs
                }
                context.addInstructionsAtCurrentPosition(instructionList)
                scheduler?.runNextInstructionOfContext(context)
            } else {
                // leaving loop now!
                conditionalSequence.resetCondition() // reset loop counter right now
                scheduler?.runNextInstructionOfContext(context) // run next action after loop
            }
        }
        assert(conditionalSequence.rootSequenceList != nil, "This should never happen!")
        conditionalSequence.rootSequenceList!.whileSequences[localUniqueID] = loopInstruction
        return loopInstruction
    }

    private func _instructionsForOperationSequence(operationSequence: CBOperationSequence,
        context: CBScriptContextAbstract) -> [CBExecClosure]
    {
        var instructionList = [CBExecClosure]()
        for operation in operationSequence.operationList.reverse() {
            if let broadcastBrick = operation.brick as? BroadcastBrick {
                instructionList += { [weak self] in
                    let msg = broadcastBrick.broadcastMessage
                    self?.broadcastHandler?.performBroadcastWithMessage(msg, senderScriptContext: context,
                        broadcastType: .Broadcast)
                }
            } else if let broadcastWaitBrick = operation.brick as? BroadcastWaitBrick {
                instructionList += { [weak self] in
                    let msg = broadcastWaitBrick.broadcastMessage
                    self?.broadcastHandler?.performBroadcastWithMessage(msg, senderScriptContext: context,
                        broadcastType: .BroadcastWait)
                }
            } else {
                instructionList += { [weak self] in
                    context.runAction(operation.brick.action(), completion:{
                        // the script must continue here. upcoming actions are executed!!
                        self?.scheduler?.runNextInstructionOfContext(context)
                    })
                }
            }
        }
        return instructionList
    }
}
