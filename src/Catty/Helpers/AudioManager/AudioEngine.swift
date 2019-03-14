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
    var speechSynth: AVSpeechSynthesizer
    var mainOut: AKMixer
    var channels: [String: AudioChannel]
    var recorder: AKNodeRecorder?
    var tape: AKAudioFile?
    var bpm: Double

    override init() {
        bpm = 60
        speechSynth = AVSpeechSynthesizer()
        mainOut = AKMixer()
        AudioKit.output = mainOut
        channels = [String: AudioChannel]()
        do {
            try AudioKit.start()
        } catch {
            print("could not start audio engine")
        }
        super.init()
        speechSynth.delegate = self

//        do {
//            tape = try AKAudioFile()
//            recorder = try AKNodeRecorder(node: mainOut, file: tape)
//            AKLog((recorder?.audioFile?.directoryPath.absoluteString)!)
//            AKLog((recorder?.audioFile?.fileNamePlusExtension)!)
//        } catch {
//
//        }
//        do {
//            try recorder?.record()
//        } catch {
//            AKLog("Couldn't record")
//        }
    }

    @objc func pauseAudioEngine() {
        pauseAllAudioPlayers()
        pauseAllSamplers()
    }

    @objc func resumeAudioEngine() {
        resumeAllAudioPlayers()
        resumeAllSamplers()
    }

    @objc func stopAudioEngine() {
        stopAllAudioPlayers()
        stopAllSamplers()
    }

    func playSound(fileName: String, key: String, filePath: String) {
        let channel = getAudioChannel(key: key)
        channel.playSound(fileName: fileName, filePath: filePath)
    }

    func playNote(note: Note, key: String) {
        let channel = getAudioChannel(key: key)
        channel.playNote(note: note)
    }

    func stopNote(note: Note, key: String) {
        let channel = getAudioChannel(key: key)
        channel.stopNote(note: note)
    }

    func playDrum(note: Note, key: String) {
        let channel = getAudioChannel(key: key)
        channel.playDrum(note: note)
    }

    func stopDrum(note: Note, key: String) {
        let channel = getAudioChannel(key: key)
        channel.stopDrum(note: note)
    }

    func setInstrumentTo(instrumentNumber: Int, key: String) {
        let channel = getAudioChannel(key: key)
        channel.setInstrumentTo(instrumentNumber: instrumentNumber)
    }

    func setVolumeTo(percent: Double, key: String) {
        let channel = getAudioChannel(key: key)
        channel.setVolumeTo(percent: percent)
    }

    func changeVolumeBy(percent: Double, key: String) {
        let channel = getAudioChannel(key: key)
        channel.changeVolumeBy(percent: percent)
    }

    func setEffectTo(effectType: SoundEffectType, value: Double, key: String) {
        let channel = getAudioChannel(key: key)
        channel.setEffectTo(effectType: effectType, value: value)
    }

    func changeEffectBy(effectType: SoundEffectType, value: Double, key: String) {
        let channel = getAudioChannel(key: key)
        channel.changeEffectBy(effectType: effectType, value: value)
    }

    func clearSoundEffects(key: String) {
        let channel = getAudioChannel(key: key)
        channel.clearSoundEffects()
    }

    func stopTheNodeRecorder() {
        recorder?.stop()
        print(" ------- Recorded \(recorder?.recordedDuration) Seconds ------- ")
    }

    func addNodeRecorderAtMainOut(tape: AKAudioFile) -> AKNodeRecorder {
        do {
            recorder = try AKNodeRecorder(node: mainOut, file: tape)
        } catch {
            print("Should not happen")
        }

        return recorder!
    }

    @objc func pauseAllAudioPlayers() {
        for (_, channel) in channels {
            channel.pauseAllAudioPlayers()
        }
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Could not deactivate audio engine")
        }
    }

    @objc func resumeAllAudioPlayers() {
        for (_, channel) in channels {
            channel.resumeAllAudioPlayers()
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Could not deactivate audio engine")
        }
    }

    @objc func stopAllAudioPlayers() {
        for (_, channel) in channels {
            channel.stopAllAudioPlayers()
        }
    }

    func getSpeechSynth() -> AVSpeechSynthesizer {
        return speechSynth
    }

    func getOutputVolumeOfChannel(objName: String) -> Double? {
        return channels[objName]?.getOutputVolume()
    }

    @objc func shutdown() {
        do {
            try AudioKit.stop()
            try AudioKit.shutdown()
        } catch {
            print("Something went wrong!")
        }
    }

    private func getAudioChannel(key: String) -> AudioChannel {
        if let channel = channels[key] {
            return channel
        } else {
            return createNewAudioChannel(key: key)
        }
    }

    private func pauseAllSamplers() {
        for (_, channel) in channels {
            channel.pauseAllSamplers()
        }
    }

    private func resumeAllSamplers() {
        for (_, channel) in channels {
            channel.resumeAllSamplers()
        }
    }

    private func stopAllSamplers() {
        for (_, channel) in channels {
            channel.stopAllSamplers()
        }
    }

    internal func createNewAudioChannel(key: String) -> AudioChannel {
        let channel = AudioChannel()
        channel.connectTo(node: mainOut)
        channels[key] = channel
        return channel
    }

    @objc func stopNodeRecorder() {
//        recorder?.stop()
//        tape?.exportAsynchronously(name: "test", baseDir: .documents, exportFormat: .caf){ [weak self] _, _ in}
//        AKLog(recorder?.recordedDuration)
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // self.speechSynthFinishedOrCanceled(synthesizer: synthesizer)
        self.signalAllSynthConditions(synthesizer: synthesizer)
    }

    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // self.speechSynthFinishedOrCanceled(synthesizer: synthesizer)
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
        condition.accessibilityLabel = accessibilityLabel
        condition.accessibilityHint = accessibilityHint

        if synthesizer.accessibilityElements != nil {
            synthesizer.accessibilityElements?.append(condition)
        } else {
            synthesizer.accessibilityElements = [condition]
        }

        return condition
    }
}
