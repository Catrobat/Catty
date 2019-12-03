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

import Foundation

@objc class SpeechSynthesizer: AVSpeechSynthesizer, AVSpeechSynthesizerDelegate {

    var utteranceVolume: Float = 1.0
    var finishedSpeakingExpectationTuple: (AVSpeechUtterance, CBExpectation)?
    let speechSynthQueue = DispatchQueue(label: "SpeechSynthQueue")

    override init() {
        super.init()
        self.delegate = self
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        fulfillExpectationOfUtterance(utterance: utterance)
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        fulfillExpectationOfUtterance(utterance: utterance)
    }

    public func speak(_ utterance: AVSpeechUtterance, expectation: CBExpectation?) {
        speechSynthQueue.sync {
            fulfillExpectation()
            self.stopSpeaking(at: AVSpeechBoundary.immediate)
            if let exp = expectation {
                finishedSpeakingExpectationTuple = (utterance, exp)
            }
            self.speak(utterance)
        }
    }

    private func fulfillExpectationOfUtterance(utterance: AVSpeechUtterance) {
        speechSynthQueue.sync {
            if let tuple = finishedSpeakingExpectationTuple {
                if tuple.0 === utterance {
                    tuple.1.fulfill()
                    finishedSpeakingExpectationTuple = nil
                }
            }
        }
    }

    private func fulfillExpectation() {
        finishedSpeakingExpectationTuple?.1.fulfill()
        finishedSpeakingExpectationTuple = nil
    }
}
