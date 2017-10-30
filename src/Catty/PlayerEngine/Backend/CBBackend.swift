/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
    func instructionsForSequence(_ sequenceList: CBSequenceList) -> [CBInstruction] {
        var instructionList = [CBInstruction]()
        sequenceList.forEach {
            switch $0 {
            case let opSequence as CBOperationSequence:
                for operation in opSequence.operationList {
                    instructionList += _instructionForBrick(operation.brick)
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

    private func _instructionForBrick(_ brick: Brick) -> [CBInstruction] {
        // check whether conforms to CBInstructionProtocol (i.e. brick extension)
        guard let instructionBrick = brick as? CBInstructionProtocol else {
            fatalError("All Bricks should implement the CBInstructionProtocol")
        }
        if (brick.getRequiredResources() & ResourceType.bluetoothArduino.rawValue) > 0 {
            guard let formulaBufferBrick = brick as? BrickFormulaProtocol else {
                 fatalError("All Bricks with formulas should implement the BrickFormulaProtocol")
            }
            return [.formulaBuffer(brick: formulaBufferBrick), instructionBrick.instruction()]
        }
        return [instructionBrick.instruction()] // actions that have been ported to Swift yet
    }

    private func _instructionsForIfSequence(_ ifSequence: CBIfConditionalSequence) -> [CBInstruction] {
        var instructionList = [CBInstruction]()

        // add if condition evaluation instruction
        let ifInstructions = instructionsForSequence(ifSequence.sequenceList)
        let numberOfIfInstructions = ifInstructions.count
        if ifSequence.hasBluetoothFormula() {
            instructionList += CBInstruction.conditionalFormulaBuffer(conditionalBrick: ifSequence)
        }
        instructionList += CBInstruction.execClosure { (context, scheduler) in
            if ifSequence.checkCondition() == false {
                var numberOfInstructionsToJump = numberOfIfInstructions
                if ifSequence.elseSequenceList != nil {
                    numberOfInstructionsToJump += 1 // includes jump instr. at the end of if sequence
                }
                context.jump(numberOfInstructions: numberOfInstructionsToJump)
            }
            context.state = .runnable
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
            instructionList += CBInstruction.execClosure { (context, scheduler) in
                context.jump(numberOfInstructions: numberOfElseInstructions)
                context.state = .runnable
            }
            instructionList += elseInstructions
        }
        return instructionList
    }

    private func _instructionsForLoopSequence(_ loopSequence: CBConditionalSequence) -> [CBInstruction] {
        let bodyInstructions = instructionsForSequence(loopSequence.sequenceList)
        let numOfBodyInstructions = bodyInstructions.count

        let loopEndInstruction = CBInstruction.highPriorityExecClosure { (context, scheduler, _) in
            var numOfInstructionsToJump = 0
            if loopSequence.checkCondition() {
                if loopSequence.hasBluetoothFormula() {
                   numOfInstructionsToJump -= numOfBodyInstructions + 2 // omits loop begin instruction
                } else {
                   numOfInstructionsToJump -= numOfBodyInstructions + 1 // omits loop begin instruction
                }
                
                loopSequence.lastLoopIterationStartTime = Date()
            } else {
                loopSequence.resetCondition() // IMPORTANT: reset loop counter right now
            }

            // minimum duration (CatrobatLanguage specification!)
            let duration = Date().timeIntervalSince(loopSequence.lastLoopIterationStartTime)
            self.logger.debug("  Duration for Sequence: \(duration*1_000)ms")
            if duration < PlayerConfig.LoopMinDurationTime {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                    // high priority queue only needed for blocking purposes...
                    // the reason for this is that you should NEVER block the (serial) main_queue!!
                    self.logger.debug("Waiting on high priority queue")
                    let uduration = UInt32((PlayerConfig.LoopMinDurationTime - duration) * 1_000_000) // in µs
                    usleep(uduration)

                    // now switch back to the main queue for executing the sequence!
                    DispatchQueue.main.async(execute: {
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

        let loopBeginInstruction = CBInstruction.execClosure { (context, scheduler) in
            if loopSequence.checkCondition() {
                loopSequence.lastLoopIterationStartTime = Date()
            } else {
                loopSequence.resetCondition() // IMPORTANT: reset loop counter right now
                if loopSequence.hasBluetoothFormula() {
                   context.jump(numberOfInstructions: numOfBodyInstructions + 2) // includes loop end instr.!
                } else {
                    context.jump(numberOfInstructions: numOfBodyInstructions + 1) // includes loop end instr.!
                }
                
            }
            context.state = .runnable
        }

        // finally add all instructions to list
        var instructionList = [CBInstruction]()
        if loopSequence.hasBluetoothFormula() {
            instructionList += CBInstruction.conditionalFormulaBuffer(conditionalBrick: loopSequence)
        }
        instructionList += loopBeginInstruction
        instructionList += bodyInstructions
        if loopSequence.hasBluetoothFormula() {
            instructionList += CBInstruction.conditionalFormulaBuffer(conditionalBrick: loopSequence)
        }
        instructionList += loopEndInstruction
        return instructionList
    }

}
