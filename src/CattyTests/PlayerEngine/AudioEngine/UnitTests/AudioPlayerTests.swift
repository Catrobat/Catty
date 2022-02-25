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

import AudioKit
import Nimble
import XCTest

@testable import Pocket_Code

final class AudioPlayerTests: XCTestCase {
    var audioPlayer: Pocket_Code.AudioPlayer!
    var testMixer = AudioKit.Mixer()
    var audioEngine = AudioKit.AudioEngine()

    override func setUp() {
        var file: AVAudioFile?
        let audioFileURL = Bundle(for: type(of: self)).url(forResource: "silence", withExtension: "mp3")
        do {
            file = try AVAudioFile(forReading: audioFileURL!)
        } catch {
            print("Could not load audio file with url \(audioFileURL!.absoluteString)")
        }

        audioPlayer = Pocket_Code.AudioPlayer(soundFile: file!)
        audioPlayer.setOutput(testMixer)
        audioEngine.output = testMixer

        do {
            try audioEngine.start()
        } catch {
            print("could not start audio engine")
        }
        super.setUp()
    }

    override func tearDown() {
        audioEngine.stop()
    }

    func testPlayDiscardedPlayerExpectPlayerNotToPlay() {
        audioPlayer.isDiscarded = true
        audioPlayer.play(expectation: nil)
        expect(self.audioPlayer.isPlaying) == false
    }

    func testStopExpectWaitExpectationToBeFulfilled() {
        let soundIsFinishedExpectation = CBExpectation()

        audioPlayer.play(expectation: soundIsFinishedExpectation)
        XCTAssertTrue(audioPlayer.isPlaying)
        audioPlayer.stop()

        expect(soundIsFinishedExpectation.isFulfilled).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(3))
        expect(self.audioPlayer.isPlaying) == false
    }

    func testPause() {
        audioPlayer.play(expectation: nil)
        expect(self.audioPlayer.isPlaying) == true
        audioPlayer.pause()
        expect(self.audioPlayer.isPaused) == true
        audioPlayer.stop()
    }

    func testResume() {
        audioPlayer.play(expectation: nil)
        expect(self.audioPlayer.isPlaying) == true
        audioPlayer.pause()
        expect(self.audioPlayer.isPaused) == true
        audioPlayer.resume()
        expect(self.audioPlayer.isPlaying) == true
        audioPlayer.stop()
    }

    func testRemoveExpectPlayerDiscardedAndStopped() {
        let soundIsFinishedExpectation = CBExpectation()

        expect(self.testMixer.hasInput(self.audioPlayer.player)) == true
        audioPlayer.play(expectation: soundIsFinishedExpectation)
        expect(self.audioPlayer.isPlaying) == true
        audioPlayer.remove()
        expect(soundIsFinishedExpectation.isFulfilled).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(3))
        expect(self.audioPlayer.isPlaying) == false
        expect(self.testMixer.hasInput(self.audioPlayer.player)) == false
    }
}
