/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc extension SpeakAndWaitBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        guard let object = self.script?.object else {
            fatalError("This should never happen!")
        }

        return CBInstruction.waitExecClosure { context, scheduler in
            let audioEngine = (scheduler as! CBScheduler).getAudioEngine()
            let synthesizer = audioEngine.getSpeechSynth()
            if synthesizer.isSpeaking {
                let waitUntilSpeechStopped = audioEngine.addConditionToSpeechSynth(accessibilityHint: "", synthesizer: synthesizer)
                synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                waitUntilSpeechStopped.lock()
                while synthesizer.isSpeaking {
                    waitUntilSpeechStopped.wait()
                }
                waitUntilSpeechStopped.unlock()
            }

            let utterance = AudioEngineConfig.stringFormulaToUtterance(text: self.formula, spriteObject: object, context: context)

            let waitUntilTextSpoken = audioEngine.addConditionToSpeechSynth(accessibilityHint: "0", synthesizer: synthesizer)
            synthesizer.speak(utterance)

            waitUntilTextSpoken.lock()
            while waitUntilTextSpoken.accessibilityHint == "0" {     //accessibilityHint used because synthesizer.speaking not yet true.
                waitUntilTextSpoken.wait()
            }
            waitUntilTextSpoken.unlock()
            usleep(10000) //will sleep for 0.01seconds. Needed to have consistent behaviour in the followin case: First Object has a "when tapped"
            //script with 2 "speak and wait" bricks. 2nd object has a "when tapped" script with one "speak and wait" brick. Tap first object,
            //then tap 2nd object. "Speak und wait" brick from 2nd object should not be audible because the 2nd speak and wait brick from the
            //first object will stop the spoken text from the 2nd object immediately.
        }
    }


}
