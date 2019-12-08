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

final class AudioEngineTests: XCTestCase {

    var audioEngine: AudioEngine!

    override func setUp() {
        super.setUp()
        audioEngine = AudioEngine(audioPlayerFactory: MockAudioPlayerFactory())
    }

    override func tearDown() {
        super.tearDown()
        audioEngine.stop()
    }

    func testGetSubtreeAndCreateNewSubtree() {
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees.count, 1)
        audioEngine.playSound(fileName: "sound2", key: "object1", filePath: "sound2", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees.count, 1)
    }

    func testGetSubtreeAndCreateNewSubtree2() {
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees.count, 1)
        audioEngine.playSound(fileName: "sound2", key: "object2", filePath: "sound2", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees.count, 2)
    }

    func testSetVolumeToInsideBounds_expectCorrectValueInsideBounds() {
        audioEngine.setVolumeTo(percent: 70, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 0.7)
    }

    func testSetVolumeToLowerThanMinExpectMin() {
        audioEngine.setVolumeTo(percent: -20, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 0)
    }

    func testSetVolumeToHigherThanMaxExpectMax() {
        audioEngine.setVolumeTo(percent: 120, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 1)
    }

    func testChangeVolumeByTurnUpVolumeInsideBoundsExpectCorrectValueInsideBounds() {
        audioEngine.setVolumeTo(percent: 50, key: "object1")
        audioEngine.changeVolumeBy(percent: 20, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 0.7)
    }

    func testChangeVolumeByTurnDownVolumeInsideBoundsExpectCorrectValueInsideBounds() {
        audioEngine.setVolumeTo(percent: 50, key: "object1")
        audioEngine.changeVolumeBy(percent: -20, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 0.3)
    }

    func testChangeVolumeByTurnUpVolumeOutsideBoundsExpectMax() {
        audioEngine.setVolumeTo(percent: 50, key: "object1")
        audioEngine.changeVolumeBy(percent: 80, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 1)
    }

    func testChangeVolumeByTurnDownVolumeOutsideBoundsExpectMin() {
        audioEngine.setVolumeTo(percent: 50, key: "object1")
        audioEngine.changeVolumeBy(percent: -80, key: "object1")
        XCTAssertEqual(audioEngine.subtrees["object1"]?.subtreeOutputMixer.volume, 0)
    }

    func testPlayOneSoundExpectOneSoundInCache() {
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees["object1"]?.audioPlayerCache.getKeySet().count, 1)
        XCTAssertTrue((audioEngine.subtrees["object1"]!.audioPlayerCache.getKeySet().contains("sound1")))
    }

    func testPlayOneSoundTwiceExpectOneSoundInCache() {
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees["object1"]?.audioPlayerCache.getKeySet().count, 1)
        XCTAssertTrue(audioEngine.subtrees["object1"]!.audioPlayerCache.getKeySet().contains("sound1"))
    }

    func testPlayTwoSoundsExpectTwoSoundsInCache() {
        audioEngine.playSound(fileName: "sound1", key: "object1", filePath: "sound1", expectation: nil)
        audioEngine.playSound(fileName: "sound2", key: "object1", filePath: "sound2", expectation: nil)
        XCTAssertEqual(audioEngine.subtrees["object1"]?.audioPlayerCache.getKeySet().count, 2)
        XCTAssertTrue(audioEngine.subtrees["object1"]!.audioPlayerCache.getKeySet().contains("sound1"))
        XCTAssertTrue(audioEngine.subtrees["object1"]!.audioPlayerCache.getKeySet().contains("sound2"))
    }

    func testPauseAudioEngineExpectAllPlayersPaused() {
        createPauseStopResumeExpectationSetup(methodUnderTest: "pause")
        audioEngine.pause()
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testStopAudioEngineExpectAllPlayersStopped() {
        createPauseStopResumeExpectationSetup(methodUnderTest: "stop")
        audioEngine.stop()
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testResumeAudioEngineExpectAllPlayersResumed() {
        createPauseStopResumeExpectationSetup(methodUnderTest: "resume")
        audioEngine.resume()
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testPlaySoundExpectAllPlayersPlayed() {
        createPauseStopResumeExpectationSetup(methodUnderTest: "play")
        audioEngine.playSound(fileName: "player1", key: "object1", filePath: "player1", expectation: nil)
        audioEngine.playSound(fileName: "player2", key: "object1", filePath: "player2", expectation: nil)
        audioEngine.playSound(fileName: "player3", key: "object2", filePath: "player3", expectation: nil)
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    private func createPauseStopResumeExpectationSetup(methodUnderTest: String) {
        let expectation1 = self.expectation(description: "Expect " + methodUnderTest + " to be called on player.")
        let expectation2 = self.expectation(description: "Expect " + methodUnderTest + " to be called on player.")
        let expectation3 = self.expectation(description: "Expect " + methodUnderTest + " to be called on player.")
        let player1 = AudioPlayerMock(testExpectationKey: methodUnderTest + "Expectation", testExpectation: expectation1)
        let player2 = AudioPlayerMock(testExpectationKey: methodUnderTest + "Expectation", testExpectation: expectation2)
        let player3 = AudioPlayerMock(testExpectationKey: methodUnderTest + "Expectation", testExpectation: expectation3)
        let audioSubtree1 = AudioSubtree(audioPlayerFactory: MockAudioPlayerFactory())
        let audioSubtree2 = AudioSubtree(audioPlayerFactory: MockAudioPlayerFactory())

        audioSubtree1.audioPlayerCache.setObject(player1, forKey: "player1")
        audioSubtree1.audioPlayerCache.setObject(player2, forKey: "player2")
        audioSubtree2.audioPlayerCache.setObject(player3, forKey: "player3")
        audioEngine.subtrees["object1"] = audioSubtree1
        audioEngine.subtrees["object2"] = audioSubtree2
    }
}
