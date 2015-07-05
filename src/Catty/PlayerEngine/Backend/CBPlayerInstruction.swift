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

import Foundation
import AudioToolbox

final class CBPlayerInstruction {

    static let vibrateSerialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL)

    // MARK: Custom Brick Instructions
    class func instructionForWaitBrick(waitBrick: WaitBrick, scheduler: CBPlayerSchedulerProtocol,
        context: CBScriptContextAbstract) -> CBExecClosure
    {
        let object = waitBrick.script.object
        return {
            context.state = .RunningMature
            let durationInSeconds = waitBrick.timeToWaitInSeconds.interpretDoubleForSprite(object)

            // ignore wait operation if an invalid duration is given!
            // => UInt32 underflow not possible any more!
            if durationInSeconds <= 0.0 {
                scheduler.runNextInstructionOfContext(context)
                return
            }

            if durationInSeconds > 60.0 {
//                self?.logger.warn("WOW!!! long time to sleep (more than 1 minute!!!)...")
                let wakeUpTime = NSDate().dateByAddingTimeInterval(durationInSeconds)
//                self?.logger.debug("Sleeping now until \(wakeUpTime)...")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    NSThread.sleepUntilDate(wakeUpTime)
                    // now switch back to the main queue for executing the next instruction!
                    dispatch_async(dispatch_get_main_queue(), {
                        scheduler.runNextInstructionOfContext(context)
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
                            scheduler.runNextInstructionOfContext(context)
                        });
                    });
                } else {
                    // to be honest: duration of <1ms is too short for a queue
                    //               switch due to >10% accuracy
                    if uduration > 0 { // maybe duration is too small and became 0 after UInt32 conversion
                        usleep(uduration)
                    }
                    scheduler.runNextInstructionOfContext(context)
                }
            }
        }
    }

    class func instructionForPlaySoundBrick(playSoundBrick: PlaySoundBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let fileName = playSoundBrick.sound.fileName
        let objectName = playSoundBrick.script.object.name
        let filePath = playSoundBrick.script.object.projectPath() + kProgramSoundsDirName
        let audioManager = AudioManager.sharedAudioManager()

        return {
//            self?.logger.debug("Performing: PlaySoundBrick")
            audioManager.playSoundWithFileName(fileName, andKey: objectName, atFilePath: filePath)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForStopAllSoundsBrick(stopAllSoundsBrick: StopAllSoundsBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let audioManager = AudioManager.sharedAudioManager()

        return {
//            self?.logger.debug("Performing: StopAllSoundsBrick")
            audioManager.stopAllSounds()
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForSpeakBrick(speakBrick: SpeakBrick, scheduler: CBPlayerSchedulerProtocol,
        context: CBScriptContextAbstract) -> CBExecClosure
    {
        let speakText = speakBrick.formula.formulaTree.value
        let utterance = AVSpeechUtterance(string: speakText)
        utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)

        return {
//            self?.logger.debug("Performing: SpeakBrick")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speakUtterance(utterance)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForChangeVolumeByNBrick(changeVolumeByNBrick: ChangeVolumeByNBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let spriteObject = changeVolumeByNBrick.script.object
        let volumeFormula = changeVolumeByNBrick.volume
        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return {
//            self?.logger.debug("Performing: ChangeVolumeByNBrick")
            let volume = volumeFormula.interpretDoubleForSprite(spriteObject)
            audioManager.changeVolumeByPercent(CGFloat(volume), forKey: spriteObjectName)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    static func instructionForSetVolumeToBrick(setVolumeToBrick: SetVolumeToBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let spriteObject = setVolumeToBrick.script.object
        let volume = setVolumeToBrick.volume.interpretDoubleForSprite(spriteObject)
        let audioManager = AudioManager.sharedAudioManager()
        let spriteObjectName = spriteObject.name

        return {
//            self?.logger.debug("Performing: SetVolumeToBrick")
            audioManager.setVolumeToPercent(CGFloat(volume), forKey: spriteObjectName)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForSetVariableBrick(setVariableBrick: SetVariableBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let spriteObject = setVariableBrick.script.object
        let result = setVariableBrick.variableFormula.interpretDoubleForSprite(spriteObject)
        let variables = spriteObject.program.variables
        let userVariable = setVariableBrick.userVariable

        return {
            //            self?.logger.debug("Performing: SetVariableBrick")
//            if setVariableBrick.userVariable.name == "digit" {
//                println("Result is %f", result)
//            }
            variables.setUserVariable(userVariable, toValue: result)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForChangeVariableBrick(changeVariableBrick: ChangeVariableBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let spriteObject = changeVariableBrick.script.object
        let result = changeVariableBrick.variableFormula.interpretDoubleForSprite(spriteObject)
        let variables = spriteObject.program.variables
        let userVariable = changeVariableBrick.userVariable

        return {
            //            self?.logger.debug("Performing: ChangeVariableBrick")
            variables.changeVariable(userVariable, byValue: result)
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForFlashLightOnBrick(flashLightOnBrick: LedOnBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let flashHelper = FlashHelper.sharedFlashHandler()
        return {
            //            self?.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            flashHelper.turnOn()
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForFlashLightOffBrick(flashLightOffBrick: LedOffBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let flashHelper = FlashHelper.sharedFlashHandler()
        return {
            //            self?.logger.debug("Performing: FlashLightOnBrick/LEDOnBrick")
            flashHelper.turnOff()
            scheduler.runNextInstructionOfContext(context)
        }
    }

    class func instructionForVibrationBrick(vibrationBrick: VibrationBrick,
        scheduler: CBPlayerSchedulerProtocol, context: CBScriptContextAbstract) -> CBExecClosure
    {
        let durationFormula = vibrationBrick.durationInSeconds
        let spriteObject = vibrationBrick.script.object
        return {
            //            self?.logger.debug("Performing: VibrationBrick")
            dispatch_async(CBPlayerInstruction.vibrateSerialQueue, {
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
            scheduler.runNextInstructionOfContext(context)
        }
    }
}
