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
import XCTest

class AudioPlayerMock: AudioPlayer {

    private var testExpectations = [String: XCTestExpectation]()

    init(testExpectationKey: String? = nil, testExpectation: XCTestExpectation? = nil) {
        var file: AKAudioFile?
        if let key = testExpectationKey, let exp = testExpectation {
            testExpectations[key] = exp
        }
        let audioFileURL = Bundle(for: type(of: self)).url(forResource: "silence", withExtension: "mp3")
        do {
            file = try AKAudioFile(forReading: audioFileURL!)
        } catch {
            print("Could not load audio file with url \(audioFileURL!.absoluteString)")
        }
        super.init(soundFile: file!, addCompletionHandler: true)

    }

    override func play(expectation: Expectation?) {
        let testExpectation = testExpectations["playExpectation"]
        testExpectations.removeValue(forKey: "playExpectation")
        testExpectation?.fulfill()
    }

    override func resume() {
        let testExpectation = testExpectations["resumeExpectation"]
        testExpectations.removeValue(forKey: "resumeExpectation")
        testExpectation?.fulfill()
    }

    override func stop() {
        let testExpectation = testExpectations["stopExpectation"]
        testExpectations.removeValue(forKey: "stopExpectation")
        testExpectation?.fulfill()
    }

    override func pause() {
        let testExpectation = testExpectations["pauseExpectation"]
        testExpectations.removeValue(forKey: "pauseExpectation")
        testExpectation?.fulfill()
    }

}
