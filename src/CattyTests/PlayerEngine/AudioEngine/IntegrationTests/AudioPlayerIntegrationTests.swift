/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

import Nimble
import XCTest

@testable import Pocket_Code

final class AudioPlayerIntegrationTests: AudioEngineAbstractTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPlaySoundSameSoundTwiceFromSameObjectExpectSoundToStopAndStartFromBeginningAgain() {
        let referenceSimHash = "11100010001011111011000000111000"
        let stage = self.createStage(xmlFile: "PlaySameSoundTwiceSameObject")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.85
    }

    func testPlaySoundSameSoundTwiceFromDifferentObjectsExpectSameSoundsToPlaySimultaneously() {
        let referenceSimHash = "01100011001111111111000000101011"
        let stage = self.createStage(xmlFile: "PlaySameSoundTwiceDifferentObjects")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.85
    }

    func testPlaySoundAndWaitExpectSoundInterruptedBySameSoundInSameObject() {
        let referenceSimHash = "01111100110011001010100110000100"
        let stage = self.createStage(xmlFile: "PlaySoundAndWaitBrickContinueWhenInterrupted")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.85
    }

    func testPlaySoundAndWaitExpectSoundNotInterruptedByDifferentSoundInSameObjet() {
        let referenceSimHash = "01100100000011101001101010100100"
        let stage = self.createStage(xmlFile: "PlaySoundAndWaitBrickSoundNotInterruptedByDifferentSound")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.85
    }

    func testPlaySoundAndWaitExpectScriptToStopUntilSoundFinished() {
        let referenceSimHash = "10100000000010001110111010100010"
        let stage = self.createStage(xmlFile: "PlaySoundAndWaitBrickStopUntilFinished")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 4, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.75
    }

    func testPlaySoundAndWaitExpectScriptToContinueWhenSoundFinished() {
        let referenceSimHash = "01100011001111101000000011001001"
        let stage = self.createStage(xmlFile: "PlaySoundAndWaitBrickContinueWhenFinished")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, stage: stage, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        expect(similarity) >= 0.75
    }
}
