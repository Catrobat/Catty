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

class Audio1Player: AKAudioPlayer {

    public init(soundFile: AVAudioFile, addCompletionHandler: Bool) throws {
        try super.init(file: soundFile as! AKAudioFile)

        if addCompletionHandler {
            self.completionHandler = soundCompletionHandler
        }
    }

    func soundCompletionHandler() {
        if let conditionArray = self.accessibilityElements as? [NSCondition] {
            for condition in conditionArray {
                condition.accessibilityHint = "1"
                condition.signal()
            }
            self.accessibilityElements = nil
        }
    }

    func playSound(condition: NSCondition?) {
        if self.isPlaying {
            self.stopSound()
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.005))
        if let cond = condition {
            self.accessibilityElements = [cond]
        }
        self.play()
    }

    func stopSound() {
        self.soundCompletionHandler()
        self.stop()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.005))
    }
}
