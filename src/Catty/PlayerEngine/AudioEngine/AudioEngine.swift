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

@objc class AudioEngine: NSObject, AudioEngineProtocol {
    var speechSynth = SpeechSynthesizer()

    var engineOutputMixer = AKMixer()
    var postProcessingMixer = AKMixer()

    var subtrees = [String: AudioSubtree]()
    let subtreeCreationQueue = DispatchQueue(label: "SubtreeCreationQueue")
    let audioPlayerFactory: AudioPlayerFactory

    init(audioPlayerFactory: AudioPlayerFactory = StandardAudioPlayerFactory()) {
        self.audioPlayerFactory = audioPlayerFactory
        super.init()
    }

    @objc func start() {
        AudioKit.output = postProcessingMixer
        engineOutputMixer.connect(to: postProcessingMixer)
        do {
            try AudioKit.start()
        } catch {
            print("COULD NOT START AUDIO ENGINE! MAKE SURE TO ALWAYS SHUT DOWN AUDIO ENGINE BEFORE" +
                "INSTANTIATING IT AGAIN (AFTER EVERY TEST CASE)! USE AN AUDIOENGINEMOCK IN TESTS" +
                "WHEN A SCENE DOES NOT NEED THE AUDIO ENGINE.")
        }
    }

    @objc func pause() {
        speechSynth.pauseSpeaking(at: AVSpeechBoundary.immediate)
        pauseAllAudioPlayers()
    }

    @objc func resume() {
        speechSynth.continueSpeaking()
        resumeAllAudioPlayers()
    }

    @objc func stop() {
        stopAllAudioPlayers()
        do {
            speechSynth.stopSpeaking(at: AVSpeechBoundary.immediate)
            try AudioKit.stop()
            try AudioKit.shutdown()
        } catch {
            print("Something went wrong when stopping the audio engine!")
        }
    }

    func playSound(fileName: String, key: String, filePath: String, expectation: CBExpectation?) {
        let subtree = getSubtree(key: key)
        subtree.playSound(fileName: fileName, filePath: filePath, expectation: expectation)
    }

    func setVolumeTo(percent: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.setVolumeTo(percent: percent)
    }

    func changeVolumeBy(percent: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.changeVolumeBy(percent: percent)
    }

    func speak(_ utterance: AVSpeechUtterance, expectation: CBExpectation?) {
        speechSynth.speak(utterance, expectation: expectation)
    }

    private func pauseAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.pauseAllAudioPlayers()
        }
    }

    private func resumeAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.resumeAllAudioPlayers()
        }
    }

    func stopAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.stopAllAudioPlayers()
        }
    }

    func getSpeechSynth() -> SpeechSynthesizer {
        return speechSynth
    }

    private func getSubtree(key: String) -> AudioSubtree {
        subtreeCreationQueue.sync {
            if subtrees[key] == nil {
                _ = createNewAudioSubtree(key: key)
            }
        }
        return subtrees[key]!
    }

    internal func createNewAudioSubtree(key: String) -> AudioSubtree {
        let subtree = AudioSubtree(audioPlayerFactory: audioPlayerFactory)
        subtree.setup(engineOut: engineOutputMixer)
        subtrees[key] = subtree
        return subtree
    }
}
