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

@objc extension SpeakAndWaitBrick: CBInstructionProtocol, AVSpeechSynthesizerDelegate {

    @nonobjc func instruction(audioEngine: AudioEngine) -> CBInstruction {

        guard let object = self.script?.object,
            let objectName = self.script?.object?.name
            else { fatalError("This should never happen!") }

        return CBInstruction.waitExecClosure { context, _ in
            let synthesizer = audioEngine.getSpeechSynth()
            if synthesizer.isSpeaking {
                let waitUntilSpeechStopped = NSCondition()
                waitUntilSpeechStopped.accessibilityLabel = "waitingUntilSpeechStopped"

                if synthesizer.accessibilityElements != nil {
                    synthesizer.accessibilityElements?.append(waitUntilSpeechStopped)
                } else {
                    synthesizer.accessibilityElements = [waitUntilSpeechStopped]
                }
                synthesizer.delegate = self
                synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                waitUntilSpeechStopped.lock()
                while synthesizer.isSpeaking {
                    waitUntilSpeechStopped.wait()
                }
                waitUntilSpeechStopped.unlock()
            }
            var speakText = context.formulaInterpreter.interpretString(self.formula, for: object)
            if Double(speakText) != nil {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }

            let utterance = AVSpeechUtterance(string: speakText)
            utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)

            if let volume = audioEngine.getOutputVolumeOfChannel(objName: objectName) {
                utterance.volume = Float(volume)
            } else {
                utterance.volume = 1.0
            }

            let waitUntilTextSpoken = NSCondition()
            waitUntilTextSpoken.accessibilityHint = "0"

            if synthesizer.accessibilityElements != nil {
                synthesizer.accessibilityElements?.append(waitUntilTextSpoken)
            } else {
                synthesizer.accessibilityElements = [waitUntilTextSpoken]
            }

            synthesizer.delegate = self
            synthesizer.speak(utterance)
            waitUntilTextSpoken.lock()
            while waitUntilTextSpoken.accessibilityHint == "0" {     //accessibilityHint used because synthesizer.speaking not yet true.
                waitUntilTextSpoken.wait()
            }
            waitUntilTextSpoken.unlock()
            usleep(10000) //will sleep for 0.01seconds. Nötig um im Folgenden Fall ein beständiges Verhalten zu haben: Erstes Objekt hat einen when tapped
            //brick und dann 2 speak and wait bricks. 2. Objekt hat einen when tapped brick und
            //einen speak and wait brick. zuerst 1. objekt, dann 2. anklicken. Speak und wait
            //vom 2. Objeckt soll gar nicht abgespielt werden, da der 2. speak and wait vom 1.
            //objekt dann gleich wieder einsetzt und den speak and wait vom 2. objekt stopt
        }
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //        if let condition = synthesizer.accessibilityElements?.last as? NSCondition {
        //            condition.accessibilityHint = "1"
        //            condition.signal()
        //            synthesizer.accessibilityElements?.removeAll()
        //        }
        for (index, object) in synthesizer.accessibilityElements!.enumerated() {
            if let condition = object as? NSCondition {
                if condition.accessibilityLabel == "waitingUntilSpeechStopped" {
                    synthesizer.accessibilityElements?.remove(at: index)
                    condition.accessibilityHint = "1"
                    condition.signal()
                    break
                }
            }
        }

        while !synthesizer.accessibilityElements!.isEmpty {
            let object = synthesizer.accessibilityElements!.first
            if let condition = object as? NSCondition {
                synthesizer.accessibilityElements?.remove(at: 0)
                condition.accessibilityHint = "1"
                condition.signal()
            }
        }
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {

        for (index, object) in synthesizer.accessibilityElements!.enumerated() {
            if let condition = object as? NSCondition {
                if  condition.accessibilityLabel == "waitingUntilSpeechStopped" {
                    synthesizer.accessibilityElements?.remove(at: index)
                    condition.accessibilityHint = "1"
                    condition.signal()
                    break
                }
            }
        }

        while !synthesizer.accessibilityElements!.isEmpty {
            let object = synthesizer.accessibilityElements!.first
            if let condition = object as? NSCondition {
                synthesizer.accessibilityElements?.remove(at: 0)
                condition.accessibilityHint = "1"
                condition.signal()
            }
        }

        //        if let condition = synthesizer.accessibilityElements?.last as? NSCondition {
        //            condition.accessibilityHint = "1"
        //            condition.signal()
        //            synthesizer.accessibilityElements?.removeAll()
        //        }

    }
}
