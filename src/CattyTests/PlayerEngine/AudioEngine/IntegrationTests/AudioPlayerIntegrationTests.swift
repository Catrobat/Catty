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
import XCTest

@testable import Pocket_Code

final class AudioPlayerIntegrationTests: AudioEngineAbstractTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPlaySameSoundTwiceFromSameObjectExpectSoundToStopAndStartFromBeginningAgain() {
        let referenceSimHash = "11100010001011111011000000111000"
        let scene = self.createScene(xmlFile: "PlaySameSoundTwiceSameObject")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        XCTAssertGreaterThan(similarity, 0.8)
    }

    func testPlaySameSoundTwiceFromDifferentObjectsExpectSameSoundsToPlaySimultaneously() {
        let referenceSimHash = "01100011001111111111000000101011"
        let scene = self.createScene(xmlFile: "PlaySameSoundTwiceDifferentObjects")

        // Run program and record
        let recordedTape = self.runAndRecord(duration: 3, scene: scene, muted: true)

        let similarity = calculateSimilarity(tape: recordedTape, referenceHash: referenceSimHash)
        XCTAssertGreaterThan(similarity, 0.85)
    }
}
