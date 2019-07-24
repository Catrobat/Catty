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
        player = AudioPlayer(soundFile: file!, addCompletionHandler: true)
        AudioKit.output = player.akPlayer
        do {
            try AudioKit.start()
        } catch {
            print("could not start audio engine")
        }
        super.setUp()
    }

    override func tearDown() {
        do {
            try AudioKit.stop()
            try AudioKit.shutdown()
        } catch {
            print("Something went wrong when stopping the audio engine!")
        }
    }

    func testPlay_playerDiscarded_expectCompletionHandlerCalled() {
        let completionExpectation = self.expectation(description: "Expect sound completion handler to be called on player.")
        player.setSoundCompletionHandler {
            completionExpectation.fulfill()
        }
        player.isDiscarded = true
        player.play(expectation: nil)
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testStop_expectCompletionHandlerCalled() {
        let completionExpectation = self.expectation(description: "Expect sound completion handler to be called on player.")
        player.setSoundCompletionHandler {
            completionExpectation.fulfill()
        }
        player.play(expectation: nil)
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.stop()
        self.waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(player.akPlayer.isPlaying)
    }

    func testPause_expectPlayerPaused() {
        player.play(expectation: nil)
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.pause()
        XCTAssertTrue(player.akPlayer.isPaused)
        XCTAssertTrue(player.isPaused)
        player.stop()
    }

    func testResume_expectPlayerResumed() {
        player.play(expectation: nil)
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.pause()
        XCTAssertTrue(player.akPlayer.isPaused)
        XCTAssertTrue(player.isPaused)
        player.resume()
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.stop()
    }

    func testRemove_expectPlayerDiscardedAndStopped() {
        let completionExpectation = self.expectation(description: "Expect sound completion handler to be called on player.")
        player.setSoundCompletionHandler {
            completionExpectation.fulfill()
        }
        XCTAssertEqual(player.akPlayer.connectionPoints.count, 1)
        player.play(expectation: nil)
        XCTAssertTrue(player.akPlayer.isPlaying)
        player.remove()
        self.waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(player.akPlayer.isPlaying)
        XCTAssertEqual(player.akPlayer.connectionPoints.count, 0)
    }
}
