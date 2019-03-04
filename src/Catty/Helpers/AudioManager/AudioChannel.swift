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

@objc class AudioChannel: NSObject {
    var subtreeOutputMixer: AKMixer
    var audioPlayerMixer: AKMixer
    var audioPlayers: [String: AKAudioPlayer]
    var sampler: AKSampler

    override init() {
        subtreeOutputMixer = AKMixer()
        audioPlayerMixer = AKMixer()
        audioPlayerMixer.connect(to: subtreeOutputMixer)
        sampler = AKSampler()
        sampler.connect(to: subtreeOutputMixer)
        audioPlayers = [String: AKAudioPlayer]()
        super.init()
        setupSampler()
    }

    func playSound(fileName: String, filePath: String) {
        if let audioPlayer = audioPlayers[fileName] {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
            audioPlayer.play()
        } else {
        let audioFileURL = createFileUrl(fileName: fileName, filePath: filePath)
            do {
                let file = try AKAudioFile(forReading: audioFileURL)
                let akPlayer = try AKAudioPlayer(file: file)
                audioPlayers[fileName] = akPlayer
                akPlayer.connect(to: audioPlayerMixer)
                akPlayer.play()
            } catch {
                print("oops \(error)")
                print("could not start audio engine")
            }
        }
    }

    func playNote(note: Note) {
        sampler.play(noteNumber: UInt8(note.pitch), velocity: 127)
    }

    func stopNote(pitch: Int) {
        sampler.stop(noteNumber: UInt8(pitch))
    }

    func setInstrumentTo(instrumentNumber: Int) {
        let instrumentPath = Bundle.main.resourcePath!+"/Sample Instruments Compressed/" + AudioEngineConfig.instrumentPath[instrumentNumber]
        sampler.loadSFZ(path: instrumentPath, fileName: AudioEngineConfig.instrumentPath[instrumentNumber] + ".sfz")
    }

    internal func createFileUrl(fileName: String, filePath: String) -> URL {
        return URL.init(fileURLWithPath: filePath + "/" + fileName)
    }

    func connectTo(node: AKInput) -> AKInput {
        return subtreeOutputMixer.connect(to: node)
    }

    func setVolumeTo(percent: Double) {
        subtreeOutputMixer.volume = percent / 100
    }

    func changeVolumeBy(percent: Double) {
        subtreeOutputMixer.volume += percent / 100
    }

    func pauseAllAudioPlayers() {
        for (_, audioPlayer) in audioPlayers where audioPlayer.isPlaying {
                audioPlayer.pause()
        }
    }

    func stopAllAudioPlayers() {
        for (_, audioPlayer) in audioPlayers {
            audioPlayer.resume()
            audioPlayer.stop()
        }
    }

    func resumeAllAudioPlayers() {
        for (_, audioPlayer) in audioPlayers {
            audioPlayer.resume()
        }
    }

    func getOutputVolume() -> Double {
        return subtreeOutputMixer.volume
    }

    func stopSampler() {
        sampler.stopAllVoices()
    }

    func resumeSampler() {
        sampler.restartVoices()
    }

    func setupSampler() {
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.5
        sampler.releaseDuration = 0.5
        setInstrumentTo(instrumentNumber: 0)
    }

    func sequencerCallback(status: MIDIByte, noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        print("bli bla blub \(status)")
        if status == 144 { // 144 is a the note on event for MIDI Channel 0
            self.sampler.play(noteNumber: noteNumber, velocity: velocity)
        } else if status == 128 { // 128 is a the note off event for MIDI Channel 0
            self.sampler.stop(noteNumber: noteNumber)
        }
    }
}
