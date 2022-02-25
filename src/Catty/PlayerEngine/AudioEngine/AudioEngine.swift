/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
    let audioPlayerFactory: AudioPlayerFactory

    var engine = AudioKit.AudioEngine()
    var engineOutputMixer = AudioKit.Mixer()

    var audioEngineHelper = AudioEngineHelper()
    var speechSynth = SpeechSynthesizer()

    var tempo = Int()

    var subtrees = [String: AudioSubtree]()
    let subtreeCreationQueue = DispatchQueue(label: "SubtreeCreationQueue")

    init(audioPlayerFactory: AudioPlayerFactory = StandardAudioPlayerFactory()) {
        self.audioPlayerFactory = audioPlayerFactory
        self.engine.output = self.engineOutputMixer
        super.init()
    }

    @objc func start() {
        AudioKit.Settings.disableAVAudioSessionCategoryManagement = true
        audioEngineHelper.activateAudioSession()

        do {
            try engine.start()
        } catch let error as NSError {
            print("Could not start audio engine:", error)
        }
    }

    @objc func pause() {
        pauseAllAudioSources()
        engine.pause()
    }

    @objc func resume() {
        do {
            try engine.start()
        } catch let error as NSError {
            print("Could not resume audio engine:", error)
        }

        resumeAllAudioSources()
    }

    @objc func stop() {
        stopAllAudioSources()
        engine.stop()
    }

    private func pauseAllAudioSources() {
        speechSynth.pauseSpeaking(at: AVSpeechBoundary.immediate)
        pauseAllAudioPlayers()
    }

    private func resumeAllAudioSources() {
        speechSynth.continueSpeaking()
        resumeAllAudioPlayers()
    }

    private func stopAllAudioSources() {
        stopAllAudioPlayers()
        speechSynth.stopSpeaking(at: AVSpeechBoundary.immediate)
    }

    func playSound(fileName: String, key: String, filePath: String, expectation: CBExpectation?) {
        let subtree = getSubtree(key: key)
        subtree.playSound(fileName: fileName, filePath: filePath, expectation: expectation)
    }

    func setVolumeTo(percent: Double, key: String?) {
        if let key = key {
            let subtree = getSubtree(key: key)
            subtree.setVolumeTo(percent: percent)
        } else {
            let volume = percent / 100
            engineOutputMixer.volume = AudioKit.AUValue(MathUtil.moveValueIntoRange(volume, min: 0, max: 1))
        }
    }

    func changeVolumeBy(percent: Double, key: String?) {
        if let key = key {
            let subtree = getSubtree(key: key)
            subtree.changeVolumeBy(percent: percent)
        } else {
            let newVolume = Double(engineOutputMixer.volume) + (percent / 100)
            engineOutputMixer.volume = AudioKit.AUValue(MathUtil.moveValueIntoRange(newVolume, min: 0, max: 1))
        }
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
        speechSynth
    }

    func setInstrument(_ instrument: Instrument, key: String) {
        let subtree = getSubtree(key: key)
        subtree.setInstrument(instrument)
    }

    func setTempo(tempo: Int) {
        self.tempo = tempo
        if self.tempo < 20 { self.tempo = 20 }
        if self.tempo > 500 { self.tempo = 500 }
    }

    private func getSubtree(key: String) -> AudioSubtree {
        subtreeCreationQueue.sync {
            if subtrees[key] == nil {
                let subtree = AudioSubtree(audioPlayerFactory: audioPlayerFactory)
                subtree.setOutput(engineOutputMixer)
                subtrees[key] = subtree
            }
        }
        return subtrees[key]!
    }
}
