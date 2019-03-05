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

@objc class AudioEngine: NSObject {
    var speechSynth: AVSpeechSynthesizer
    var mainOut: AKMixer
    var channels: [String: AudioChannel]
    var recorder: AKNodeRecorder?
    var tape: AKAudioFile?
    var bpm: Double
    var activeNotes: Set<Note>

    override init() {
        activeNotes = Set<Note>()
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
        activeNotes.insert(note)
        channel.playNote(note: note)
        note.setActive()
    }

    func stopNote(pitch: Int, key: String) {
        let channel = getAudioChannel(key: key)
        channel.stopNote(pitch: pitch)
    }

    func playDrum(note: Note, key: String) {
        let channel = getAudioChannel(key: key)
        activeNotes.insert(note)
        note.setActive()
        channel.playDrum(note: note)
    }

    func stopDrum(pitch: Int, key: String) {
        let channel = getAudioChannel(key: key)
        channel.stopDrum(pitch: pitch)
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
            channel.stopSampler()
        }
        pauseAllNotes()
    }

    private func resumeAllSamplers() {
        for (_, channel) in channels {
            channel.resumeSampler()
        }
        resumeAllNotes()
    }

    private func stopAllSamplers() {
        for (_, channel) in channels {
            channel.stopSampler()
        }
        activeNotes.removeAll()
    }

    private func pauseAllNotes() {
        for note in activeNotes {
            note.pause()
        }
    }

    private func resumeAllNotes() {
        for note in activeNotes {
            note.resume()
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
}
