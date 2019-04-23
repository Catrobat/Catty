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

@objc class AudioEngine: NSObject, AVSpeechSynthesizerDelegate {
    var speechSynth = AVSpeechSynthesizer()
    var mainOut = AKMixer()
    var subtrees = [String: AudioSubtree]()
    var recorder: AKNodeRecorder?
    var tape: AKAudioFile?
    var bpm = 60.0
    let subtreeCreationQueue = DispatchQueue(label: "SubtreeCreationQueue")

    override init() {
        AudioKit.output = mainOut
        do {
            try AudioKit.start()
        } catch {
            print("could not start audio engine")
        }
        super.init()
        speechSynth.delegate = self
    }

    @objc func pauseAudioEngine() {
        pauseAllAudioPlayers()
        pauseAllSamplers()
        speechSynth.pauseSpeaking(at: AVSpeechBoundary.immediate)
    }

    @objc func resumeAudioEngine() {
        resumeAllAudioPlayers()
        resumeAllSamplers()
        speechSynth.continueSpeaking()
    }

    @objc func stopAudioEngine() {
        stopAllAudioPlayers()
        stopAllSamplers()
        speechSynth.stopSpeaking(at: AVSpeechBoundary.immediate)
    }

    func playSound(fileName: String, key: String, filePath: String, condition: NSCondition?) {
        let subtree = getSubtree(key: key)
        subtree.playSound(fileName: fileName, filePath: filePath, condition: condition)
    }

    func playNote(note: Note, key: String) {
        let subtree = getSubtree(key: key)
        subtree.playNote(note: note)
    }

    func stopNote(note: Note, key: String) {
        let subtree = getSubtree(key: key)
        subtree.stopNote(note: note)
    }

    func playDrum(note: Note, key: String) {
        let subtree = getSubtree(key: key)
        subtree.playDrum(note: note)
    }

    func stopDrum(note: Note, key: String) {
        let subtree = getSubtree(key: key)
        subtree.stopDrum(note: note)
    }

    func setInstrumentTo(instrumentNumber: Int, key: String) {
        let subtree = getSubtree(key: key)
        subtree.setInstrumentTo(instrumentNumber: instrumentNumber)
    }

    func setVolumeTo(percent: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.setVolumeTo(percent: percent)
    }

    func changeVolumeBy(percent: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.changeVolumeBy(percent: percent)
    }

    func setEffectTo(effectType: SoundEffectType, value: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.setEffectTo(effectType: effectType, value: value)
    }

    func changeEffectBy(effectType: SoundEffectType, value: Double, key: String) {
        let subtree = getSubtree(key: key)
        subtree.changeEffectBy(effectType: effectType, value: value)
    }

    func clearSoundEffects(key: String) {
        let subtree = getSubtree(key: key)
        subtree.clearSoundEffects()
    }

    @objc func pauseAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.pauseAllAudioPlayers()
        }
    }

    @objc func resumeAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.resumeAllAudioPlayers()
        }
    }

    @objc func stopAllAudioPlayers() {
        for (_, subtree) in subtrees {
            subtree.stopAllAudioPlayers()
        }
    }

    func getSpeechSynth() -> AVSpeechSynthesizer {
        return speechSynth
    }

    @objc func shutdown() {
        do {
            try AudioKit.stop()
            try AudioKit.shutdown()
        } catch {
            print("Something went wrong!")
        }
    }

    private func getSubtree(key: String) -> AudioSubtree {
        subtreeCreationQueue.sync {
            if subtrees[key] == nil {
                _ = createNewAudioSubtree(key: key)
            }
        }
        return subtrees[key]!
    }

    private func pauseAllSamplers() {
        for (_, subtree) in subtrees {
            subtree.pauseAllSamplers()
        }
    }

    private func resumeAllSamplers() {
        for (_, subtree) in subtrees {
            subtree.resumeAllSamplers()
        }
    }

    private func stopAllSamplers() {
        for (_, subtree) in subtrees {
            subtree.stopAllSamplers()
        }
    }

    internal func createNewAudioSubtree(key: String) -> AudioSubtree {
        let subtree = AudioSubtree(mainOut: mainOut)
        subtrees[key] = subtree
        return subtree
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.signalAllSynthConditions(synthesizer: synthesizer)
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.signalAllSynthConditions(synthesizer: synthesizer)
    }

    private func signalAllSynthConditions(synthesizer: AVSpeechSynthesizer) {
        while !synthesizer.accessibilityElements!.isEmpty {
            let object = synthesizer.accessibilityElements!.first
            if let condition = object as? NSCondition {
                synthesizer.accessibilityElements?.remove(at: 0)
                condition.accessibilityHint = "1"
                condition.signal()
            }
        }
    }

    func addConditionToSpeechSynth(accessibilityHint: String, synthesizer: AVSpeechSynthesizer) -> NSCondition {
        let condition = NSCondition()
        condition.accessibilityHint = accessibilityHint

        if synthesizer.accessibilityElements != nil {
            synthesizer.accessibilityElements?.append(condition)
        } else {
            synthesizer.accessibilityElements = [condition]
        }

        return condition
    }
}
