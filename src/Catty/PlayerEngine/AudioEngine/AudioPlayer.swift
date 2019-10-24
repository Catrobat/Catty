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
import Foundation

class AudioPlayer {

    let akPlayer: AKPlayer
    var playerIsFinishedExpectation: Expectation?
    var fileName: String
    var soundCompletionHandler: (() -> Void)!
    var isPaused = false
    var isDiscarded = false

    let playingQueue = DispatchQueue(label: "PlayingQueue")

    init(soundFile: AVAudioFile, addCompletionHandler: Bool) {
        fileName = soundFile.fileNamePlusExtension
        akPlayer = AKPlayer(audioFile: soundFile)
        akPlayer.isLooping = false
        if addCompletionHandler {
            soundCompletionHandler = standardSoundCompletionHandler
            akPlayer.completionHandler = soundCompletionHandler
        }
    }

    func play(expectation: Expectation?) {
        _ = playingQueue.sync {
            addExpectation(expectation)
            if !self.isDiscarded {
                if akPlayer.isPlaying {
                    self.stop()
                }
                akPlayer.play()
            } else {
                soundCompletionHandler()
            }
        }
    }

    func stop() {
        self.soundCompletionHandler()
        akPlayer.stop()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01)) //Hack. Otherwise a player might not play at all if play is executed too fast after the stop command
    }

    func remove() {
        _ = playingQueue.sync {
            self.isDiscarded = true
            self.stop()
            akPlayer.detach()
        }
    }

    func pause() {
        if akPlayer.isPlaying {
            akPlayer.pause()
            self.isPaused = true
        }
    }

    func resume() {
        if self.isPaused {
            akPlayer.resume()
            self.isPaused = false
        }
    }

    func connect(to node: AKInput) {
        akPlayer.connect(to: node)
    }

    func isPlaying() -> Bool {
        return akPlayer.isPlaying
    }

    func getFileName() -> String {
        return fileName
    }

    func setSoundCompletionHandler(_ completionHandler: @escaping () -> Void) {
        soundCompletionHandler = completionHandler
        akPlayer.completionHandler = completionHandler
    }

    private func standardSoundCompletionHandler() {
        if let expectation = self.playerIsFinishedExpectation {
            expectation.fulfill()
            playerIsFinishedExpectation = nil
        }
    }

    private func addExpectation(_ expectation: Expectation?) {
        self.playerIsFinishedExpectation = expectation
    }
}
