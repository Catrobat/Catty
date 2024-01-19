/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class AudioEngineFingerprintingStub: Pocket_Code.AudioEngine {
    private var recorder: AudioKit.NodeRecorder?
    var muted = true

    override func start() {
        super.start()
        if muted {
            engine.mainMixerNode?.volume = muted ? 0.0 : 1.0
            speechSynth.utteranceVolume = muted ? 0.0 : 1.0
        }

        recorder = try? AudioKit.NodeRecorder(node: engineOutputMixer)
        try? self.recorder?.record()
    }

    override func stop() {
        recorder?.stop()
        super.stop()
    }

    var tape: AVAudioFile? {
        recorder?.audioFile
    }
}
