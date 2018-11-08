/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc extension WaitUntilBrick: CBInstructionProtocol {
    
    @nonobjc func instruction() -> CBInstruction {
        
        guard let object = self.script?.object else { fatalError("This should never happen!") }
        
        return CBInstruction.waitExecClosure { (context, _) in
            let condition = NSCondition()
            condition.accessibilityHint = "0"
            
//            var speakText = context.formulaInterpreter.interpretString(self.formula, for: object)
//            if(Double(speakText) !=  nil)
//            {
//                let num = (speakText as NSString).doubleValue
//                speakText = (num as NSNumber).stringValue
//            }
//
//            let utterance = AVSpeechUtterance(string: speakText)
//            utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)
//
//            if let synthesizer = audioManager?.getSpeechSynth() {
//                synthesizer.delegate = self
//                if synthesizer.accessibilityElements != nil {
//                    synthesizer.accessibilityElements?.append((condition, utterance))
//                } else {
//                    synthesizer.accessibilityElements = [(condition, utterance)]
//                }
//                synthesizer.speak(utterance)
//
//                condition.lock()
//                while(condition.accessibilityHint == "0") {     //accessibilityHint used because synthesizer.speaking not yet true.
//                    condition.wait()
//                }
//                condition.unlock()
//            }
//        }
//    }
//
//    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        for (index, object) in synthesizer.accessibilityElements!.enumerated() {
//            if let tuple = object as? (NSCondition, AVSpeechUtterance) {
//                if tuple.1 === utterance {
//                    synthesizer.accessibilityElements?.remove(at: index)
//                    tuple.0.accessibilityHint = "1"
//                    tuple.0.signal()
//                    break
//                }
//            }
        }
    }
}
