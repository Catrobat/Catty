/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

final class AudioPlayerTests: XCTestCase {

    var player: AudioPlayer!

    override func setUp() {
        var file: AKAudioFile?
        let audioFileURL = Bundle(for: type(of: self)).url(forResource: "silence", withExtension: "mp3")
        do {
            file = try AKAudioFile(forReading: audioFileURL!)
        } catch {
            print("Could not load audio file with url \(audioFileURL!.absoluteString)")
        }

        let akPlayer = AKPlayer(audioFile: file!)
        player = AudioPlayer(soundFile: file!)

        player.akPlayer = akPlayer
        AudioKit.output = player.akPlayer
        do {
            try AudioKit.start()
        } catch {
            print("could not start audio engine")
        }
        super.setUp()
    }

    override func tearDown() {
        try? AudioKit.stop()
    }

    func testPlayDiscardedPlayerExpectPlayerNotToPlay() {
        player.isDiscarded = true
        player.play(expectation: nil)
        expect(self.player.akPlayer.isPlaying) == false
    }

    func testStopExpectWaitExpectationToBeFulfilled() {
        let soundIsFinishedExpectation = CBExpectation()

        player.play(expectation: soundIsFinishedExpectation)
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.stop()

        expect(soundIsFinishedExpectation.isFulfilled).toEventually(beTrue(), timeout: 3)
        expect(self.player.akPlayer.isPlaying) == false
    }

    func testPause() {
        player.play(expectation: nil)
        expect(self.player.akPlayer.isPlaying) == true
        player.pause()
        expect(self.player.akPlayer.isPaused) == true
        expect(self.player.isPaused) == true
        player.stop()
    }

    func testResume() {
        player.play(expectation: nil)
        expect(self.player.akPlayer.isPlaying) == true
        player.pause()
        expect(self.player.akPlayer.isPaused) == true
        expect(self.player.isPaused) == true
        player.resume()
        expect(self.player.akPlayer.isPlaying) == true
        player.stop()
    }

    func testRemoveExpectPlayerDiscardedAndStopped() {
        let soundIsFinishedExpectation = CBExpectation()

        expect(self.player.akPlayer.connectionPoints.count) == 1
        player.play(expectation: soundIsFinishedExpectation)
        expect(self.player.akPlayer.isPlaying) == true
        player.remove()
        expect(soundIsFinishedExpectation.isFulfilled).toEventually(beTrue(), timeout: 3)
        expect(self.player.akPlayer.isPlaying) == false
        expect(self.player.akPlayer.connectionPoints.count) == 0
    }
}
