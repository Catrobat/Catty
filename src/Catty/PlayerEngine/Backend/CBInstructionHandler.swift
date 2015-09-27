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
    func instructionForBrick(brick: Brick, withContext context: CBScriptContext) -> CBInstruction
}

final class CBInstructionHandler : CBInstructionHandlerProtocol {

    var logger: CBLogger
    private let _scheduler: CBSchedulerProtocol
    private let _broadcastHandler: CBBroadcastHandlerProtocol
    private var _brickInstructionMap = [String:CBInstructionClosure]()
    static let vibrateSerialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL)

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBSchedulerProtocol,
        broadcastHandler: CBBroadcastHandlerProtocol)
    {
        self.logger = logger
        _scheduler = scheduler
        _broadcastHandler = broadcastHandler

        // brick actions that have been ported to Swift yet
        func _setupBrickInstructionMapping() {

            // long duration bricks
            _brickInstructionMap["WaitBrick"] = _waitInstruction
            _brickInstructionMap["GlideToBrick"] = _glideToInstruction

            // short duration bricks
            _brickInstructionMap["BroadcastBrick"] = _broadcastInstruction
            _brickInstructionMap["BroadcastWaitBrick"] = _broadcastWaitInstruction
            _brickInstructionMap["PlaySoundBrick"] = _playSoundInstruction
            _brickInstructionMap["StopAllSoundsBrick"] = _stopAllSoundsInstruction
            _brickInstructionMap["SpeakBrick"] = _speakInstruction
            _brickInstructionMap["ChangeVolumeByNBrick"] = _changeVolumeByNInstruction
            _brickInstructionMap["SetVolumeToBrick"] = _setVolumeToInstruction
            _brickInstructionMap["SetVariableBrick"] = _setVariableInstruction
            _brickInstructionMap["ChangeVariableBrick"] = _changeVariableInstruction
            _brickInstructionMap["LedOnBrick"] = _flashLightOnInstruction
            _brickInstructionMap["LedOffBrick"] = _flashLightOffInstruction
            _brickInstructionMap["VibrationBrick"] = _vibrationInstruction

        }
        _setupBrickInstructionMapping()
    }

    // MARK: - Operations
    func instructionForBrick(brick: Brick, withContext context: CBScriptContext) -> CBInstruction {
        if let instruction = _brickInstructionMap["\(brick.dynamicType.description())"] {
            return instruction(brick: brick, context: context)
        }

        // cannot find in map => get action via brick class
        return .Action(action: brick.action())
    }

    // MARK: - Mapped instructions
    private func _waitInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let waitBrick = brick as? WaitBrick,
              let object = waitBrick.script?.object
        else { fatalError("This should never happen!") }

        return CBInstruction.WaitExecClosure {
            let durationInSeconds = waitBrick.timeToWaitInSeconds.interpretDoubleForSprite(object)

            // check if an invalid duration is given! => prevents UInt32 underflow
            if durationInSeconds <= 0.0 { return }

            // UInt32 overflow protection check
            if durationInSeconds > 60.0 {
                self.logger.warn("WOW!!! long time to sleep (> 1min!!!)...")
                let wakeUpTime = NSDate().dateByAddingTimeInterval(durationInSeconds)
                self.logger.debug("Sleeping now until \(wakeUpTime)...")
                NSThread.sleepUntilDate(wakeUpTime)
            } else {
                let durationInMicroSeconds = durationInSeconds * 1_000_000
                let uduration = UInt32(durationInMicroSeconds) // in microseconds (10^-6)
                if uduration > 100 { // check if it makes sense at all to pause the thread...
                    usleep(uduration)
                }
            }
        }
    }

    private func _glideToInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let glideToBrick = brick as? GlideToBrick,
              let object = glideToBrick.script?.object,
              let spriteNode = object.spriteNode
        else { fatalError("This should never happen!") }

        glideToBrick.isInitialized = false

        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!
        //!!! FIXME!!!!!!! wrong behaviour issue!! no live evaluation!!
        //!!!             duration formula only evaluated once!!
        //!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        let durationInSeconds = glideToBrick.durationInSeconds.interpretDoubleForSprite(object)
        return .LongDurationAction(action: SKAction.customActionWithDuration(durationInSeconds) {
            [weak self] (node, elapsedTime) in
            self?.logger.debug("Performing: \(glideToBrick.description())")
            let xDestination = Float(glideToBrick.xDestination.interpretDoubleForSprite(object))
            let yDestination = Float(glideToBrick.yDestination.interpretDoubleForSprite(object))
            if !glideToBrick.isInitialized {
                glideToBrick.isInitialized = true
                glideToBrick.currentPoint = spriteNode.scenePosition
                glideToBrick.startingPoint = glideToBrick.currentPoint
            }

            // TODO: handle extreme movemenets and set currentPoint accordingly
            let percent = Float(elapsedTime) / Float(durationInSeconds)
            let xPoint = Float(glideToBrick.startingPoint.x) + (xDestination - Float(glideToBrick.startingPoint.x)) * percent
            let yPoint = Float(glideToBrick.startingPoint.y) + (yDestination - Float(glideToBrick.startingPoint.y)) * percent
            let currentPoint = CGPointMake(CGFloat(xPoint), CGFloat(yPoint))
            glideToBrick.currentPoint = currentPoint
            spriteNode.scenePosition = currentPoint
        })
    }

    private func _broadcastInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let bcBrick = brick as? BroadcastBrick
        else { fatalError("This should never happen!") }

        return CBInstruction.ExecClosure {
            self._broadcastHandler.performBroadcastWithMessage(bcBrick.broadcastMessage,
                senderContext: context, broadcastType: .Broadcast)
        }
    }
    
    private func _broadcastWaitInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let bcWaitBrick = brick as? BroadcastWaitBrick
        else { fatalError("This should never happen!") }

        return CBInstruction.ExecClosure {
            self._broadcastHandler.performBroadcastWithMessage(bcWaitBrick.broadcastMessage,
                senderContext: context, broadcastType: .BroadcastWait)
        }
    }

    private func _playSoundInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let playSoundBrick = brick as? PlaySoundBrick,
              let objectName = playSoundBrick.script?.object?.name,
              let projectPath = playSoundBrick.script?.object?.projectPath()
        else { fatalError("This should never happen!") }

        guard let sound = playSoundBrick.sound,
              let fileName = sound.fileName
        else { return .InvalidInstruction() }

        let filePath = projectPath + kProgramSoundsDirName
        let audioManager = AudioManager.sharedAudioManager()

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: PlaySoundBrick")
            audioManager.playSoundWithFileName(fileName, andKey: objectName, atFilePath: filePath)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _stopAllSoundsInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        if brick is StopAllSoundsBrick == false { fatalError("This should never happen!") }

        let audioManager = AudioManager.sharedAudioManager()

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: StopAllSoundsBrick")
            audioManager.stopAllSounds()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _speakInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let speakBrick = brick as? SpeakBrick,
              let object = speakBrick.script?.object
        else { fatalError("This should never happen!") }

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: SpeakBrick")
            var speakText = ""
            if speakBrick.formula.formulaTree.type == STRING {
                speakText = speakBrick.formula.formulaTree.value
            } else {
                // remove trailing 0's behind the decimal point!!
                func removeTrailingZeros(number: Double) -> String {
                    return String(format: "%g", number)
                }
                speakText = removeTrailingZeros(speakBrick.formula.interpretDoubleForSprite(object))
            }
            self.logger.debug("Speak text: '\(speakText)'")
            let utterance = AVSpeechUtterance(string: speakText)
            utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)

            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speakUtterance(utterance)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _changeVolumeByNInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let changeVolumeByNBrick = brick as? ChangeVolumeByNBrick,
              let spriteObject = changeVolumeByNBrick.script?.object
        else { fatalError("This should never happen!") }

        let volumeFormula = changeVolumeByNBrick.volume
        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: ChangeVolumeByNBrick")
            let volume = volumeFormula.interpretDoubleForSprite(spriteObject)
            audioManager.changeVolumeByPercent(CGFloat(volume), forKey: spriteObjectName)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _setVolumeToInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let setVolumeToBrick = brick as? SetVolumeToBrick,
              let spriteObject = setVolumeToBrick.script?.object
        else { fatalError("This should never happen") }

        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: SetVolumeToBrick")
            let volume = setVolumeToBrick.volume.interpretDoubleForSprite(spriteObject)
            audioManager.setVolumeToPercent(CGFloat(volume), forKey: spriteObjectName)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _setVariableInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let setVariableBrick = brick as? SetVariableBrick,
              let spriteObject = setVariableBrick.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = setVariableBrick.userVariable
        let variableFormula = setVariableBrick.variableFormula

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: SetVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.setUserVariable(userVariable, toValue: result)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _changeVariableInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let changeVariableBrick = brick as? ChangeVariableBrick,
              let spriteObject = changeVariableBrick.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = changeVariableBrick.userVariable
        let variableFormula = changeVariableBrick.variableFormula

        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: ChangeVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.changeVariable(userVariable, byValue: result)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _flashLightOnInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        if brick is LedOnBrick == false { fatalError("This should never happen!") }
        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOn()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _flashLightOffInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        if brick is LedOffBrick == false { fatalError("This should never happen!") }
        return CBInstruction.ExecClosure {
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOff()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _vibrationInstruction(brick: Brick, context: CBScriptContext) -> CBInstruction {
        guard let vibrationBrick = brick as? VibrationBrick,
              let spriteObject = vibrationBrick.script?.object
        else { fatalError("This should never happen!") }

        let durationFormula = vibrationBrick.durationInSeconds
        return CBInstruction.ExecClosure {
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
            self._scheduler.runNextInstructionOfContext(context)
        }
    }
}
