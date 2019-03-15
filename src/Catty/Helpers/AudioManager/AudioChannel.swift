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
    var audioPlayers = [String: AKPlayer]()
    var sampler: Sampler
    var drumSampler: Sampler
    var soundEffects: [SoundEffectType: SoundEffect]

//    var panEffect: PanEffect
//    var pitchEffect: PitchEffect

    override init() {
        audioPlayerMixer = AKMixer()
        let panEffect = PanEffect()
        let pitchEffect = PitchEffect()
        soundEffects = [SoundEffectType: SoundEffect]()
        soundEffects[.pan] = panEffect
        soundEffects[.pitch] = pitchEffect
        subtreeOutputMixer = AKMixer()
        sampler = Sampler()
        drumSampler = Sampler()
        audioPlayerMixer.connect(to: pitchEffect)
        pitchEffect.connect(to: panEffect)
        panEffect.connect(to: subtreeOutputMixer)
        sampler.connect(to: subtreeOutputMixer)
        drumSampler.connect(to: subtreeOutputMixer)

        super.init()
        setupSampler()
    }

    func playSound(fileName: String, filePath: String, condition: NSCondition?) {
        if let audioPlayer = audioPlayers[fileName] {
            audioPlayer.soundCompletionHandler()
            audioPlayer.stop()
            if let cond = condition {
                audioPlayer.accessibilityElements = [cond]
            }
            audioPlayer.play()
        } else {
            let audioFileURL = createFileUrl(fileName: fileName, filePath: filePath)
            do {
                let file = try AKAudioFile(forReading: audioFileURL)
                let audioPlayer = AKPlayer(soundFile: file, addCompletionHandler: true)
                audioPlayers[fileName] = audioPlayer
                audioPlayer.connect(to: audioPlayerMixer)
                if let cond = condition {
                    audioPlayer.accessibilityElements = [cond]
                }
                audioPlayer.play()
            } catch {
                print("Could not load audio file with url \(audioFileURL.absoluteString)")
            }
        }
    }

    func playNote(note: Note) {
        sampler.playNote(note)
    }

    func stopNote(note: Note) {
        sampler.stopNote(note)
    }

    func playDrum(note: Note) {
        drumSampler.playNote(note)
    }

    func stopDrum(note: Note) {
        drumSampler.stopNote(note)
    }

    func setInstrumentTo(instrumentNumber: Int) {
        let instrumentPath = Bundle.main.resourcePath!+"/Sample Instruments Compressed/" + AudioEngineConfig.instrumentPath[instrumentNumber]
        sampler.loadSFZ(path: instrumentPath, fileName: AudioEngineConfig.instrumentPath[instrumentNumber] + ".sfz")
    }

    func setEffectTo(effectType: SoundEffectType, value: Double) {
        var effect = getEffect(effectType)
        effect.setEffectTo(value)

    }

    func changeEffectBy(effectType: SoundEffectType, value: Double) {
        var effect = getEffect(effectType)
        effect.changeEffectBy(value)
    }

    func clearSoundEffects() {
        for (_, soundEffect) in soundEffects {
            soundEffect.clear()
        }
    }

    private func getEffect(_ effectType: SoundEffectType) -> SoundEffect {
        return soundEffects[effectType]!
    }

    func loadDrums() {
        let instrumentPath = Bundle.main.resourcePath!+"/Sample Instruments Compressed/" + AudioEngineConfig.instrumentPath[21]
        drumSampler.loadSFZ(path: instrumentPath, fileName: AudioEngineConfig.instrumentPath[21] + ".sfz")
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
            audioPlayer.stop()
            audioPlayer.soundCompletionHandler()
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

    func pauseAllSamplers() {
        sampler.pauseSampler()
        drumSampler.pauseSampler()
    }

    func stopAllSamplers() {
        sampler.stopSampler()
        drumSampler.stopSampler()
    }

    func resumeAllSamplers() {
        sampler.resumeSampler()
        drumSampler.resumeSampler()
    }

    func setupSampler() {
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.5
        sampler.releaseDuration = 0.5
        drumSampler.attackDuration = 0.01
        drumSampler.decayDuration = 0.1
        drumSampler.sustainLevel = 0.5
        drumSampler.releaseDuration = 0.5
        setInstrumentTo(instrumentNumber: 0)
        loadDrums()
    }
}
