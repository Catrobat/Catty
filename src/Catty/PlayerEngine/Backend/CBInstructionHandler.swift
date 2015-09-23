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
    func instructionForBrick(brick: Brick, withContext context: CBScriptContextAbstract)
        -> CBExecClosure
}

final class CBInstructionHandler : CBInstructionHandlerProtocol {

    var logger: CBLogger
    private let _scheduler: CBSchedulerProtocol
    private let _broadcastHandler: CBBroadcastHandlerProtocol
    private var _brickInstructionMap = [String:CBInstruction]()
    static let vibrateSerialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL)

    // MARK: - Initializers
    init(logger: CBLogger, scheduler: CBSchedulerProtocol,
        broadcastHandler: CBBroadcastHandlerProtocol)
    {
        self.logger = logger
        _scheduler = scheduler
        _broadcastHandler = broadcastHandler

        func _setupBrickInstructionMapping() {
            // brick actions that have been already ported to Swift
            _brickInstructionMap["BroadcastBrick"] = _broadcastInstruction
            _brickInstructionMap["BroadcastWaitBrick"] = _broadcastWaitInstruction
            _brickInstructionMap["WaitBrick"] = _waitInstruction
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
    func instructionForBrick(brick: Brick, withContext context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        if let instruction = _brickInstructionMap["\(brick.dynamicType.description())"] {
            return instruction(brick: brick, context: context)
        }

        // not found in map => get action via brick class
        return {
            context.runAction(brick.action(), completion:{
                // the script must continue here. upcoming actions are executed!!
                self._scheduler.runNextInstructionOfContext(context)
            })
        }
    }

    // MARK: - Mapped instructions
    private func _broadcastInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let bcBrick = brick as? BroadcastBrick
        else { fatalError("This should never happen!") }

        return {
            self._broadcastHandler.performBroadcastWithMessage(bcBrick.broadcastMessage,
                senderScriptContext: context, broadcastType: .Broadcast)
        }
    }

    private func _broadcastWaitInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let bcWaitBrick = brick as? BroadcastWaitBrick
        else { fatalError("This should never happen!") }

        return {
            self._broadcastHandler.performBroadcastWithMessage(bcWaitBrick.broadcastMessage,
                senderScriptContext: context, broadcastType: .BroadcastWait)
        }
    }

    private func _waitInstruction(brick: Brick, context: CBScriptContextAbstract) -> CBExecClosure {
        guard let waitBrick = brick as? WaitBrick,
              let object = waitBrick.script?.object
        else { fatalError("This should never happen!") }

        return {
            context.state = .RunningMature
            let durationInSeconds = waitBrick.timeToWaitInSeconds.interpretDoubleForSprite(object)

            // ignore wait operation if an invalid duration is given!
            // => UInt32 underflow not possible any more!
            if durationInSeconds <= 0.0 {
                self._scheduler.runNextInstructionOfContext(context)
                return
            }

            if durationInSeconds > 60.0 {
                self.logger.warn("WOW!!! long time to sleep (more than 1 minute!!!)...")
                let wakeUpTime = NSDate().dateByAddingTimeInterval(durationInSeconds)
                self.logger.debug("Sleeping now until \(wakeUpTime)...")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    NSThread.sleepUntilDate(wakeUpTime)
                    // now switch back to the main queue for executing the next instruction!
                    dispatch_async(dispatch_get_main_queue(), {
                        self._scheduler.runNextInstructionOfContext(context)
                    });
                });
            } else {
                let durationInMicroSeconds = durationInSeconds * 1_000_000
                // no worry about UInt32 overflow => not possible any more
                // because of previous if condition!
                let uduration = UInt32(durationInMicroSeconds) // in microseconds
                // >1ms => duration for queue switch ~0.1ms => less than 10% inaccuracy
                if uduration > 1_000 {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        // high priority queue only needed for blocking purposes...
                        // the reason for this is that you should NEVER block (serial) main_queue!!
                        usleep(uduration)

                        // now switch back to the main queue for executing the next instruction!
                        dispatch_async(dispatch_get_main_queue(), {
                            self._scheduler.runNextInstructionOfContext(context)
                        });
                    });
                } else {
                    // to be honest: duration of <1ms is too short for a queue
                    //               switch due to >10% accuracy
                    if uduration > 0 { // maybe duration is too small and became 0 after UInt32 conversion
                        usleep(uduration)
                    }
                    self._scheduler.runNextInstructionOfContext(context)
                }
            }
        }
    }

    private func _playSoundInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let playSoundBrick = brick as? PlaySoundBrick,
              let fileName = playSoundBrick.sound.fileName,
              let objectName = playSoundBrick.script?.object?.name,
              let projectPath = playSoundBrick.script?.object?.projectPath() else {
                fatalError("This should never happen!")
        }

        let filePath = projectPath + kProgramSoundsDirName
        let audioManager = AudioManager.sharedAudioManager()

        return {
            self.logger.debug("Performing: PlaySoundBrick")
            audioManager.playSoundWithFileName(fileName, andKey: objectName, atFilePath: filePath)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _stopAllSoundsInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let _ = brick as? StopAllSoundsBrick else { fatalError("This should never happen!") }

        let audioManager = AudioManager.sharedAudioManager()

        return {
            //            self?.logger.debug("Performing: StopAllSoundsBrick")
            audioManager.stopAllSounds()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _speakInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let speakBrick = brick as? SpeakBrick,
              let object = speakBrick.script?.object
        else { fatalError("This should never happen!") }

        return {
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

    private func _changeVolumeByNInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let changeVolumeByNBrick = brick as? ChangeVolumeByNBrick,
              let spriteObject = changeVolumeByNBrick.script?.object
        else { fatalError("This should never happen!") }

        let volumeFormula = changeVolumeByNBrick.volume
        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return {
            self.logger.debug("Performing: ChangeVolumeByNBrick")
            let volume = volumeFormula.interpretDoubleForSprite(spriteObject)
            audioManager.changeVolumeByPercent(CGFloat(volume), forKey: spriteObjectName)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _setVolumeToInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let setVolumeToBrick = brick as? SetVolumeToBrick,
              let spriteObject = setVolumeToBrick.script?.object
        else { fatalError("This should never happen") }

        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return {
            self.logger.debug("Performing: SetVolumeToBrick")
            let volume = setVolumeToBrick.volume.interpretDoubleForSprite(spriteObject)
            audioManager.setVolumeToPercent(CGFloat(volume), forKey: spriteObjectName)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _setVariableInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let setVariableBrick = brick as? SetVariableBrick,
              let spriteObject = setVariableBrick.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = setVariableBrick.userVariable
        let variableFormula = setVariableBrick.variableFormula

        return {
            self.logger.debug("Performing: SetVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.setUserVariable(userVariable, toValue: result)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _changeVariableInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let changeVariableBrick = brick as? ChangeVariableBrick,
              let spriteObject = changeVariableBrick.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = changeVariableBrick.userVariable
        let variableFormula = changeVariableBrick.variableFormula

        return {
            self.logger.debug("Performing: ChangeVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.changeVariable(userVariable, byValue: result)
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _flashLightOnInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let _ = brick as? LedOnBrick else { fatalError("This should never happen!") }
        return {
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOn()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _flashLightOffInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let _ = brick as? LedOffBrick else { fatalError("This should never happen!") }
        return {
            self.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            FlashHelper.sharedFlashHandler().turnOff()
            self._scheduler.runNextInstructionOfContext(context)
        }
    }

    private func _vibrationInstruction(brick: Brick, context: CBScriptContextAbstract)
        -> CBExecClosure
    {
        guard let vibrationBrick = brick as? VibrationBrick,
              let spriteObject = vibrationBrick.script?.object
        else { fatalError("This should never happen!") }

        let durationFormula = vibrationBrick.durationInSeconds

        return {
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
