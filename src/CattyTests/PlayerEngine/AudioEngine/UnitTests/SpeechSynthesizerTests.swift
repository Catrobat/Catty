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
import Nimble
import XCTest

@testable import Pocket_Code

final class SpeechSynthesizerTests: XCTestCase {

    var speechSynth = SpeechSynthesizer()

    var currentUtterance: AVSpeechUtterance!
    var newUtterance: AVSpeechUtterance!
    var currentUtteranceExpectation: CBExpectation!
    var newUtteranceExpectation: CBExpectation!
    var previousExpectationTuple: (AVSpeechUtterance, CBExpectation)!

    override func setUp() {
        self.speechSynth = SpeechSynthesizer()
        currentUtteranceExpectation = CBExpectation()
        newUtteranceExpectation = CBExpectation()
        currentUtterance = getUtterance(text: "previous")
        newUtterance = getUtterance(text: "new")
        previousExpectationTuple = (currentUtterance, currentUtteranceExpectation)

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(true)
        try? audioSession.setCategory(AVAudioSession.Category.playback)
    }

    func testSpeechSynthStartSpeaking() {
        speechSynth.speak(newUtterance, expectation: newUtteranceExpectation)
        expect(self.speechSynth.isSpeaking).toEventually(beTrue(), timeout: 3)
    }

    func testSpeechSynthExpectDidFinishCallbackToFulfillExpectation() {
        speechSynth.speak(newUtterance, expectation: newUtteranceExpectation)
        expect(self.newUtteranceExpectation.isFulfilled).toEventually(beTrue(), timeout: 3)
    }

    func testAlreadySpeakingSpeechSynthExpectCurrentExpectationToBeFulfilledAndRemovedWhenSpeakingNewUtterance() {
        speechSynth.finishedSpeakingExpectationTuple = previousExpectationTuple

        speechSynth.speak(newUtterance, expectation: nil)
        expect(self.currentUtteranceExpectation.isFulfilled).to(beTrue())
        XCTAssertNil(speechSynth.finishedSpeakingExpectationTuple)
    }

    func testAlreadySpeakingSpeechSynthExpectNewExpectationToBeAddedWhenSpeakingNewUtterance() {
        speechSynth.finishedSpeakingExpectationTuple = previousExpectationTuple

        speechSynth.speak(newUtterance, expectation: newUtteranceExpectation)
        expect(self.currentUtteranceExpectation.isFulfilled).to(beTrue())
        expect(self.newUtteranceExpectation.isFulfilled).to(beFalse())
        expect(self.speechSynth.finishedSpeakingExpectationTuple?.0) === newUtterance
        expect(self.speechSynth.finishedSpeakingExpectationTuple?.1) === newUtteranceExpectation
    }

    private func getUtterance(text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = (floor(NSFoundationVersionNumber) < 1200 ? 0.15 : 0.5)
        utterance.volume = 0
        return utterance
    }
}
