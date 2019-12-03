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

import AudioKit
import Nimble
import XCTest

@testable import Pocket_Code

// NOTE: This class does not record and analyze the audio output of the speech synthesizer, as apples frameworks
// do not allow this. Instead this class verifyies interaction of speak and speak and wait bricks with their
// subsequent bricks. As such, this class only records and validates the audio output of sound bricks that interact
// with speak and speak and wait bricks.
final class SpeechSynthesizerIntegrationTests: AudioEngineAbstractTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSpeakBrickExpectScriptToImmediatelyContinueExecution() {
        let referenceSimHash = "01100001100111000000000000101010"
        let scene = self.createScene(xmlFile: "SpeakBrickWithSoundBrick")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = self.calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) > 0.80
    }

    func testSpeakAndWaitBrickExpectScriptToWaitUntilFinishedSpeaking() {
        let referenceSimHash = "00010000011011011011000110111010"
        let scene = self.createScene(xmlFile: "SpeakAndWaitBrickWithSoundBrick")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = self.calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) > 0.80
    }

    func testOneSpeakAndWaitAndOneSpeakBrickExpectExpectSpeakAndWaitBrickToBeInterruptedBySpeakBrick() {
        let referenceSimHash = "01100011001011101010110011001000"
        let scene = self.createScene(xmlFile: "SpeakAndWaitInterruptedBySpeak")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = self.calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) > 0.80
    }

    func testThreeSpeakAndWaitBricksExpectFirstTwoToBeImmediatelyInterrupted() {
        let referenceSimHash = "01100000100111000000000000101110"
        let scene = self.createScene(xmlFile: "SpeakAndWaitTwoInterruptingSpeakBricks")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = self.calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) > 0.80
    }
}
