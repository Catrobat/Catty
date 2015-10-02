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

import AudioToolbox
import Darwin // usleep

protocol CBInstructionHandlerProtocol {
    func instructionForBrick(brick: Brick) -> CBInstruction
}

final class CBInstructionHandler: CBInstructionHandlerProtocol {

    var logger: CBLogger
    private var _brickInstructionMap = [String:CBInstructionClosure]()
    static let vibrateSerialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL)

    // MARK: - Initializers
    init(logger: CBLogger) {
        self.logger = logger

        // brick actions that have been ported to Swift yet
        func _setupBrickInstructionMapping() {
            _brickInstructionMap["ChangeVariableBrick"] = _changeVariableInstruction
            _brickInstructionMap["LedOnBrick"] = _flashLightOnInstruction
            _brickInstructionMap["LedOffBrick"] = _flashLightOffInstruction
            _brickInstructionMap["VibrationBrick"] = _vibrationInstruction
            _brickInstructionMap["MoveNStepsBrick"] = _moveNStepsInstruction
            _brickInstructionMap["IfOnEdgeBounceBrick"] = _ifOnEdgeBounceInstruction
        }
        _setupBrickInstructionMapping()
    }

    // MARK: - Operations
    func instructionForBrick(brick: Brick) -> CBInstruction {
        if let instruction = _brickInstructionMap["\(brick.dynamicType.description())"] {
            return instruction(brick: brick)
        }

        // cannot find in map => check if conforms to CBInstructionProtocol (i.e. Brick extension)
        if let instructionBrick = brick as? CBInstructionProtocol {
            return instructionBrick.instruction()
        }

        // fallback: poor old ObjC fellow... ;)
        return .Action(action: brick.action())
    }
    
    // MARK: - Mapped instructions
    private func _changeVariableInstruction(brick: Brick) -> CBInstruction {
        guard let changeVariableBrick = brick as? ChangeVariableBrick,
              let spriteObject = changeVariableBrick.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = changeVariableBrick.userVariable
        let variableFormula = changeVariableBrick.variableFormula

        return CBInstruction.ExecClosure { (context, scheduler) in
            self.logger.debug("Performing: ChangeVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.changeVariable(userVariable, byValue: result)
            context.state = .Runnable
        }
    }

    private func _flashLightOnInstruction(brick: Brick) -> CBInstruction {
        if brick is LedOnBrick == false { fatalError("This should never happen!") }
        return CBInstruction.ExecClosure { (context, scheduler) in
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOn()
            context.state = .Runnable
        }
    }

    private func _flashLightOffInstruction(brick: Brick) -> CBInstruction {
        if brick is LedOffBrick == false { fatalError("This should never happen!") }
        return CBInstruction.ExecClosure { (context, scheduler) in
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOff()
            context.state = .Runnable
        }
    }

    private func _vibrationInstruction(brick: Brick) -> CBInstruction {
        guard let vibrationBrick = brick as? VibrationBrick,
              let spriteObject = vibrationBrick.script?.object
        else { fatalError("This should never happen!") }

        let durationFormula = vibrationBrick.durationInSeconds
        return CBInstruction.ExecClosure { (context, scheduler) in
            self.logger.debug("Performing: VibrationBrick")
            dispatch_async(CBInstructionHandler.vibrateSerialQueue, {
                let durationInSeconds = durationFormula.interpretDoubleForSprite(spriteObject)
                let max = Int(2 * durationInSeconds)
                for var i = 1; i < max; i++ {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                        Int64(Double(i)*0.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                }
            })
            context.state = .Runnable
        }
    }

    private func _moveNStepsInstruction(brick: Brick) -> CBInstruction {
        guard let moveNStepsBrick = brick as? MoveNStepsBrick,
              let object = moveNStepsBrick.script?.object,
              let spriteNode = object.spriteNode,
              let stepsFormula = moveNStepsBrick.steps
        else { fatalError("This should never happen!") }

        return .Action(action: SKAction.runBlock {
            let steps = stepsFormula.interpretDoubleForSprite(object)
            let rotation = ((spriteNode.rotation + 90) % 360) * M_PI / 180
            let position = spriteNode.scenePosition
            let xPosition = round(Double(position.x) + (steps * sin(rotation)))
            let yPosition = round(Double(position.y) - (steps * cos(rotation)))
            spriteNode.scenePosition = CGPointMake(CGFloat(xPosition), CGFloat(yPosition))
        })
    }

    private func _ifOnEdgeBounceInstruction(brick: Brick) -> CBInstruction {
        guard let ifOnEdgeBounceBrick = brick as? IfOnEdgeBounceBrick,
              let object = ifOnEdgeBounceBrick.script?.object,
              let spriteNode = object.spriteNode,
              let scene = spriteNode.scene
        else { fatalError("This should never happen!") }

        // TODO: simplify...
        return .Action(action: SKAction.runBlock {
            let width = spriteNode.size.width
            let height = spriteNode.size.height

            let virtualScreenWidth = scene.size.width/2.0
            let virtualScreenHeight = scene.size.height/2.0

            var xPosition = spriteNode.scenePosition.x
            var rotation = spriteNode.rotation
            let xComparePosition = -virtualScreenWidth + (width/2.0)
            let xOtherComparePosition = virtualScreenWidth - (width/2.0)
            if xPosition < xComparePosition {
                if (rotation > 90) && (rotation < 270) {
                    rotation = 180 - rotation
                }
                xPosition = xComparePosition
            } else if xPosition > xOtherComparePosition {
                if (rotation >= 0 && rotation < 90) || (rotation > 270 && rotation <= 360) {
                    rotation = 180 - rotation
                }
                xPosition = xOtherComparePosition
            }
            if rotation < 0 { rotation += 360 }

            var yPosition = spriteNode.scenePosition.y
            let yComparePosition = virtualScreenHeight - (height/2.0)
            let yOtherComparePosition = -virtualScreenHeight + (height/2.0)
            if yPosition > yComparePosition {
                if (rotation > 0) && (rotation < 180) {
                    rotation = -rotation
                }
                yPosition = yComparePosition
            } else if yPosition < yOtherComparePosition {
                if (rotation > 180) && (rotation < 360) {
                    rotation = 360 - rotation
                }
                yPosition = yOtherComparePosition
            }
            spriteNode.rotation = rotation
            spriteNode.scenePosition = CGPointMake(xPosition, yPosition)
        })
    }
}
