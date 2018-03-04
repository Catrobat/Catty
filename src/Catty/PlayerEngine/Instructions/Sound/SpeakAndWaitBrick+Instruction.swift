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

extension SpeakAndWaitBrick: CBInstructionProtocol, AVSpeechSynthesizerDelegate {
    
    func instruction() -> CBInstruction {
        
        guard let object = self.script?.object else { fatalError("This should never happen!") }
        
        return CBInstruction.WaitExecClosure { (context, _) in
            
            let condition = NSCondition()
            condition.accessibilityHint = "0"
            
            var speakText = self.formula.interpretString(object)
            if(Double(speakText) !=  nil)
            {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            
            let utterance = AVSpeechUtterance(string: speakText)
            utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.delegate = self
            synthesizer.accessibilityElements = [condition]
            synthesizer.speakUtterance(utterance)

            condition.lock()

            while(condition.accessibilityHint == "0") {     //accessibilityHint used because synthesizer.speaking not yet true.
                condition.wait()
            }
            condition.unlock()
        }
        
    }

    public func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        if let condition = synthesizer.accessibilityElements?.last as? NSCondition {
            condition.accessibilityHint = "1"
            condition.signal()
        }
    }
}
