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

import XCTest

@testable import Pocket_Code

final class AudioSubtreeTests: XCTestCase {

    var audioEngine: AudioEngine!
    var audioSubtree: AudioSubtree!

    override func setUp() {
        super.setUp()
        audioSubtree = AudioSubtree(audioPlayerFactory: MockAudioPlayerFactory())
        audioEngine = AudioEngine(audioPlayerFactory: MockAudioPlayerFactory())
    }

    override func tearDown() {
        super.tearDown()
        audioEngine.stop()
    }

    func testInitialVolumeExpectMax() {
        XCTAssertEqual(audioSubtree.subtreeOutputMixer.volume, 1)
    }

    func testSetupExpectAllNodesToBeConnected() {
        audioSubtree.setOutput(audioEngine.engineOutputMixer)
        XCTAssertTrue(audioEngine.engine.mainMixerNode!.hasInput(audioEngine.engineOutputMixer))
        XCTAssertTrue(audioEngine.engineOutputMixer.hasInput(audioSubtree.subtreeOutputMixer))
    }
}
