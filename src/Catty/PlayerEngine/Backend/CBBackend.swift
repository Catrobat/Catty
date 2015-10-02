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

import Darwin // usleep

final class CBBackend: CBBackendProtocol {

    // MARK: - Properties
    var logger: CBLogger
    private let _instructionHandler: CBInstructionHandlerProtocol

    // MARK: - Initializers
    init(logger: CBLogger, instructionHandler: CBInstructionHandlerProtocol) {
        self.logger = logger
        _instructionHandler = instructionHandler
    }

    // MARK: - Operations
    func scriptContextForSequenceList(sequenceList: CBScriptSequenceList, spriteNode: CBSpriteNode)
        -> CBScriptContext
    {
        logger.info("Generating ScriptContext of \(sequenceList.script)")
        var context: CBScriptContext? = nil

        switch sequenceList.script {
        case let startScript as StartScript:
            context = CBStartScriptContext(startScript: startScript, spriteNode: spriteNode,
                state: .Runnable)
        case let whenScript as WhenScript:
            context = CBWhenScriptContext(whenScript: whenScript, spriteNode: spriteNode,
                state: .Runnable)
        case let bcScript as BroadcastScript:
            context = CBBroadcastScriptContext(broadcastScript: bcScript, spriteNode: spriteNode,
                state: .Runnable)
        default:
            fatalError("Unknown script! THIS SHOULD NEVER HAPPEN!")
        }

        // generate instructions and add them to script context
        context! += _instructionsForSequence(sequenceList.sequenceList)
        return context!
    }

    private func _instructionsForSequence(sequenceList: CBSequenceList) -> [CBInstruction] {
        var instructionList = [CBInstruction]()
        sequenceList.forEach {
            switch $0 {
            case let opSequence as CBOperationSequence:
                instructionList += opSequence.operationList.map {
                    return _instructionHandler.instructionForBrick($0.brick)
                }
            case let ifSequence as CBIfConditionalSequence:
                instructionList += self._instructionsForIfSequence(ifSequence)
            case let condSequence as CBConditionalSequence:
                instructionList += self._instructionsForLoopSequence(condSequence)
            default:
                fatalError("Unknown sequence type! THIS SHOULD NEVER HAPPEN!")
            }
        }
        return instructionList
    }

    private func _instructionsForIfSequence(ifSequence: CBIfConditionalSequence) -> [CBInstruction] {
        var instructionList = [CBInstruction]()

        // add if condition evaluation instruction
        let ifInstructions = _instructionsForSequence(ifSequence.sequenceList)
        let numberOfIfInstructions = ifInstructions.count
        instructionList += CBInstruction.ExecClosure { (context, scheduler) in
            if ifSequence.checkCondition() == false {
                var numberOfInstructionsToJump = numberOfIfInstructions
                if ifSequence.elseSequenceList != nil {
                    ++numberOfInstructionsToJump // includes jump instr. at the end of if sequence
                }
                context.jump(numberOfInstructions: numberOfInstructionsToJump)
            }
            context.state = .Runnable
        }
        instructionList += ifInstructions // add if instructions

        // check if else branch is empty!
        var numberOfElseInstructions = 0
        if ifSequence.elseSequenceList != nil {
            // add else instructions
            let elseInstructions = _instructionsForSequence(ifSequence.elseSequenceList!)
            numberOfElseInstructions = elseInstructions.count
            // add jump instruction to be the last if-instruction
            // (needed to avoid execution of else sequence)
            instructionList += CBInstruction.ExecClosure { (context, scheduler) in
                context.jump(numberOfInstructions: numberOfElseInstructions)
                context.state = .Runnable
            }
            instructionList += elseInstructions
        }
        return instructionList
    }

    private func _instructionsForLoopSequence(loopSequence: CBConditionalSequence) -> [CBInstruction] {
        let bodyInstructions = _instructionsForSequence(loopSequence.sequenceList)
        let numOfBodyInstructions = bodyInstructions.count

        let loopEndInstruction = CBInstruction.HighPriorityExecClosure { (context, scheduler, _) in
            var numOfInstructionsToJump = 0
            if loopSequence.checkCondition() {
                numOfInstructionsToJump -= numOfBodyInstructions + 1 // omits loop begin instruction
                loopSequence.lastLoopIterationStartTime = NSDate()
            } else {
                loopSequence.resetCondition() // IMPORTANT: reset loop counter right now
            }

            // minimum duration (CatrobatLanguage specification!)
            let duration = NSDate().timeIntervalSinceDate(loopSequence.lastLoopIterationStartTime)
            self.logger.debug("  Duration for Sequence: \(duration*1000)ms")
            if duration < 0.02 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    self.logger.debug("Waiting on high priority queue")
                    let uduration = UInt32((0.02 - duration) * 1_000_000) // in microseconds
                    usleep(uduration)

                    // now switch back to the main queue for executing the sequence!
                    dispatch_async(dispatch_get_main_queue(), {
                        context.jump(numberOfInstructions: numOfInstructionsToJump)
                        scheduler.runNextInstructionOfContext(context)
                    });
                });
            } else {
                // now switch back to the main queue for executing the sequence!
                context.jump(numberOfInstructions: numOfInstructionsToJump)
                scheduler.runNextInstructionOfContext(context)
            }
        }

        let loopBeginInstruction = CBInstruction.ExecClosure { (context, scheduler) in
            if loopSequence.checkCondition() {
                loopSequence.lastLoopIterationStartTime = NSDate()
            } else {
                loopSequence.resetCondition() // IMPORTANT: reset loop counter right now
                let numOfInstructionsToJump = numOfBodyInstructions + 1 // includes loop end instr.!
                context.jump(numberOfInstructions: numOfInstructionsToJump)
            }
            context.state = .Runnable
        }

        // finally add all instructions to list
        var instructionList = [CBInstruction]()
        instructionList += loopBeginInstruction
        instructionList += bodyInstructions
        instructionList += loopEndInstruction
        return instructionList
    }

}
