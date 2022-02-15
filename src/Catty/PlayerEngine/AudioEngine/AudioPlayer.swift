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

import AudioKit
import Foundation

class AudioPlayer: NSDiscardableContent {
    var player: AudioKit.AudioPlayer
    var outputMixer: AudioKit.Mixer?

    var playerIsFinishedExpectation: CBExpectation?
    var fileName: String
    var soundCompletionHandler: (() -> Void)!
    var isDiscarded = false
    var isPlaying: Bool {
        player.status == .playing
    }
    var isPaused: Bool {
        player.status == .paused
    }

    let playingQueue = DispatchQueue(label: "PlayingQueue")

    init(soundFile: AVAudioFile) {
        fileName = soundFile.url.lastPathComponent
        player = AudioKit.AudioPlayer()
        player.file = soundFile
        player.isLooping = false
        soundCompletionHandler = standardSoundCompletionHandler
        player.completionHandler = soundCompletionHandler
    }

    func play(expectation: CBExpectation?) {
        if !(player.playerNode.engine?.isRunning ?? false) {
            return
        }

        playingQueue.sync {
            soundCompletionHandler()
            if !self.isDiscarded {
                if self.isPlaying {
                    player.stop()
                }
                addExpectation(expectation)
                player.play()
            }
        }
    }

    func stop() {
        soundCompletionHandler()
        player.stop()
    }

    func remove() {
        playingQueue.sync {
            self.isDiscarded = true
            self.stop()
            outputMixer?.removeInput(player)
            outputMixer = nil
        }
    }

    func pause() {
        if self.isPlaying {
            player.pause()
        }
    }

    func resume() {
        if self.isPaused {
            player.resume()
        }
    }

    func setOutput(_ mixer: AudioKit.Mixer) {
        if let previousMixer = outputMixer {
            previousMixer.removeInput(player)
        }
        mixer.addInput(player)
        outputMixer = mixer
    }

    func getFileName() -> String {
        fileName
    }

    func setSoundCompletionHandler(_ completionHandler: @escaping () -> Void) {
        soundCompletionHandler = completionHandler
        player.completionHandler = completionHandler
    }

    private func standardSoundCompletionHandler() {
        if let expectation = self.playerIsFinishedExpectation {
            expectation.fulfill()
            playerIsFinishedExpectation = nil
        }
    }

    private func addExpectation(_ expectation: CBExpectation?) {
        self.playerIsFinishedExpectation = expectation
    }

    func beginContentAccess() -> Bool {
        true // Only exists to conform with NSDiscardableContent. Prevents cache from being emptied when app enters background
    }

    func endContentAccess() {
        // Only exists to conform with NSDiscardableContent. Prevents cache from being emptied when app enters background
    }

    func discardContentIfPossible() {
        // Only exists to conform with NSDiscardableContent. Prevents cache from being emptied when app enters background
    }

    func isContentDiscarded() -> Bool {
        false // Only exists to conform with NSDiscardableContent. Prevents cache from being emptied when app enters background
    }
}
