/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc class AudioEngineHelper: NSObject {

    class func stringFormulaToUtterance(text: Formula, volume: Float, spriteObject: SpriteObject, context: CBScriptContextProtocol) -> AVSpeechUtterance {
        var speakText = context.formulaInterpreter.interpretString(text, for: spriteObject)
        if Double(speakText) != nil {
            let num = (speakText as NSString).doubleValue
            speakText = (num as NSNumber).stringValue
        }

        let utterance = AVSpeechUtterance(string: speakText)
        utterance.volume = volume
        utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)

        return utterance
    }

    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.soloAmbient, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            debugPrint("Could not activate audio session.")
            debugPrint(error)
        }
    }

    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            debugPrint("Could not deactivate audio session.")
            debugPrint(error)
        }
    }
}

enum SamplerType: String {
    case instrument, drum
}
