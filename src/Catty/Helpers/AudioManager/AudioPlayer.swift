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
    var waitCondition: NSCondition?
    var isPaused = false
    var isDiscarded = false

    let playingQueue = DispatchQueue(label: "PlayingQueue")

    init(soundFile: AVAudioFile, addCompletionHandler: Bool) {
        akPlayer = AKPlayer(audioFile: soundFile)
        akPlayer.isLooping = false
        if addCompletionHandler {
            akPlayer.completionHandler = soundCompletionHandler
        }
    }

    func soundCompletionHandler() {
        if let cond = self.waitCondition {
            cond.accessibilityHint = "1"
            cond.signal()
            waitCondition = nil
        }
    }

    func play(condition: NSCondition?) {
        _ = playingQueue.sync {
            addCondition(condition)
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
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01)) //Hack. Sonst spielt manchmal nichts mehr stop und play zu schnell nacheinander kommen.
    }

    func remove() {
        _ = playingQueue.sync {
            self.isDiscarded = true
            self.soundCompletionHandler()
            akPlayer.stop()
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
        if let file = akPlayer.audioFile {
            return file.fileNamePlusExtension
        } else {
            debugPrint("No file found for player")
            return "no file found"
        }
    }

    private func addCondition(_ condition: NSCondition?) {
        self.waitCondition = condition
    }
}
