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
                // check if else branch is empty!
                var numberOfElseInstructions = 0
                if ifSequence.elseSequenceList != nil {
                    // add else instructions
                    let elseInstructions = _instructionsForSequence(ifSequence.elseSequenceList!, context: context)
                    numberOfElseInstructions = elseInstructions.count
                    instructionList += elseInstructions

                    // add jump instruction to be the last if instruction (needed to avoid executing else sequence)
                    instructionList += {
                        [weak self] in
                        context.jump(numberOfInstructions: numberOfElseInstructions)
                        self?.scheduler?.runNextInstructionOfContext(context)
                    }
                }
                // add if instructions
                let ifInstructions = _instructionsForSequence(ifSequence.sequenceList, context: context)
                let numberOfIfInstructions = ifInstructions.count
                instructionList += ifInstructions
                // add if condition evaluation instruction
                instructionList += { [weak self] in
                    if ifSequence.checkCondition() == false {
                        var numberOfInstructionsToJump = numberOfIfInstructions
                        if ifSequence.elseSequenceList != nil {
                            ++numberOfInstructionsToJump // includes jump instruction at the end of if sequence
                        }
                        context.jump(numberOfInstructions: numberOfInstructionsToJump)
                    }
                    self?.scheduler?.runNextInstructionOfContext(context)
                }
            } else if let conditionalSequence = sequence as? CBConditionalSequence {
                // loop sequence
                instructionList += _instructionsForLoopSequence(conditionalSequence, context: context)
            }
        }
        return instructionList
    }

    private func _instructionsForLoopSequence(conditionalSequence: CBConditionalSequence,
        context: CBScriptContextAbstract) -> [CBExecClosure]
    {
        let bodyInstructions = _instructionsForSequence(conditionalSequence.sequenceList, context: context)
        let numOfBodyInstructions = bodyInstructions.count

        let loopEndInstruction : CBExecClosure = { [weak self] in
            context.isLocked = true
            var numOfInstructionsToJump = 0
            if conditionalSequence.checkCondition() {
                numOfInstructionsToJump -= numOfBodyInstructions + 1 // includes current instruction
                conditionalSequence.lastLoopIterationStartTime = NSDate()
            } else {
                conditionalSequence.resetCondition() // IMPORTANT: reset loop counter right now
            }

            // minimum duration (CatrobatLanguage specification!)
            let duration = NSDate().timeIntervalSinceDate(conditionalSequence.lastLoopIterationStartTime)
            self?.logger.debug("  Duration for Sequence: \(duration*1000)ms")
            if duration < 0.02 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    self?.logger.debug("Waiting on high priority queue")
                    NSThread.sleepForTimeInterval(0.02 - duration)

                    // now switch back to the main queue for executing the sequence!
                    dispatch_async(dispatch_get_main_queue(), {
                        context.jump(numberOfInstructions: numOfInstructionsToJump)
                        context.isLocked = false
                        self?.scheduler?.runNextInstructionOfContext(context)
                    });
                });
            } else {
                // now switch back to the main queue for executing the sequence!
                context.jump(numberOfInstructions: numOfInstructionsToJump)
                context.isLocked = false
                self?.scheduler?.runNextInstructionOfContext(context)
            }
        }
        let loopBeginInstruction : CBExecClosure = { [weak self] in
            var numOfInstructionsToJump = 0
            if conditionalSequence.checkCondition() {
                conditionalSequence.lastLoopIterationStartTime = NSDate()
            } else {
                numOfInstructionsToJump += numOfBodyInstructions + 1 // includes loop end instruction!
            }
            context.jump(numberOfInstructions: numOfInstructionsToJump)
            self?.scheduler?.runNextInstructionOfContext(context)
        }
        // finally add all instructions to list (reverse order!)
        var instructionList = [CBExecClosure]()
        instructionList += loopEndInstruction
        instructionList += bodyInstructions
        instructionList += loopBeginInstruction
        return instructionList
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
