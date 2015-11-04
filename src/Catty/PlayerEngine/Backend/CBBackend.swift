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

final class CBBackend: CBBackendProtocol {

    // MARK: - Properties
    var logger: CBLogger

    // MARK: - Initializers
    init(logger: CBLogger) {
        self.logger = logger
    }

    // MARK: - Operations
    func instructionsForSequence(sequenceList: CBSequenceList) -> [CBInstruction] {
        var instructionList = [CBInstruction]()
        sequenceList.forEach {
            switch $0 {
            case let opSequence as CBOperationSequence:
                instructionList += opSequence.operationList.map {
                    return _instructionForBrick($0.brick)
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

    private func _instructionForBrick(brick: Brick) -> CBInstruction {
        // check whether conforms to CBInstructionProtocol (i.e. brick extension)
        if((brick.getRequiredResources() & ResourceType.BluetoothArduino.rawValue) > 0){
            // TODO WaitExecclosure of this brick
            if let instructionBrick = brick as? CBInstructionProtocol {
                return .Buffer(brick: instructionBrick) // actions that have been ported to Swift yet
            }
        }
        if let instructionBrick = brick as? CBInstructionProtocol {
            return instructionBrick.instruction() // actions that have been ported to Swift yet
        }
        return .Action(action: brick.action()) // fallback: poor old ObjC fellow... ;)
    }

    private func _instructionsForIfSequence(ifSequence: CBIfConditionalSequence) -> [CBInstruction] {
        var instructionList = [CBInstruction]()

        // add if condition evaluation instruction
        let ifInstructions = instructionsForSequence(ifSequence.sequenceList)
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
            let elseInstructions = instructionsForSequence(ifSequence.elseSequenceList!)
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
        let bodyInstructions = instructionsForSequence(loopSequence.sequenceList)
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
            self.logger.debug("  Duration for Sequence: \(duration*1_000)ms")
            if duration < PlayerConfig.LoopMinDurationTime {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    self.logger.debug("Waiting on high priority queue")
                    let uduration = UInt32((PlayerConfig.LoopMinDurationTime - duration) * 1_000_000) // in µs
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
                context.jump(numberOfInstructions: numOfBodyInstructions + 1) // includes loop end instr.!
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
