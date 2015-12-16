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

extension SpeakBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        
        guard let object = self.script?.object else { fatalError("This should never happen!") }
        
        return CBInstruction.ExecClosure { (context, _) in
            //            self.logger.debug("Performing: SpeakBrick")
            let speakText = self.formula.interpretString(object)
//            if self.formula.formulaTree.type == .STRING {
//                speakText = self.formula.formulaTree.value
//            } else {
//                // remove trailing 0's behind the decimal point!!
//                speakText = String(format: "%g", self.formula.interpretDoubleForSprite(object))
//            }
            //            self.logger.debug("Speak text: '\(speakText)'")
            let utterance = AVSpeechUtterance(string: speakText)
            utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speakUtterance(utterance)
            context.state = .Runnable
        }
        
    }
}
