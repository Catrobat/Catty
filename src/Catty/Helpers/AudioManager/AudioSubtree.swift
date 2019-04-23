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

@objc class AudioSubtree: NSObject {
    var subtreeOutputMixer = AKMixer()
    var audioPlayerMixer = AKMixer()
    var audioPlayerCache = IterableCache<AudioPlayer>()
    var samplerCache = IterableCache<Sampler>()


    let panEffect = PanEffect()
    let pitchEffect = PitchEffect()
    var soundEffects = [SoundEffectType: SoundEffect]()
    var instrumentChoice = 0
    let playerCreationQueue = DispatchQueue(label: "PlayerCreationQueue")
    let samplerCreationQueue = DispatchQueue(label: "SamplerCreationQueue")
    let drumSamplerCreationQueue = DispatchQueue(label: "DrumSamplerCreationQueue")

    init(mainOut: AKInput) {
        super.init()
        setupSubtree(mainOut: mainOut)
    }

    func playSound(fileName: String, filePath: String, condition: NSCondition?) {
        if let audioPlayer = audioPlayerCache.object(forKey: fileName) {
            startExistingAudioPlayer(audioPlayer: audioPlayer, condition: condition)
        } else {
            let audioFileURL = createFileUrl(fileName: fileName, filePath: filePath)
            do {
                let file = try AKAudioFile(forReading: audioFileURL)
                let audioPlayer = AudioPlayer(soundFile: file, addCompletionHandler: true)
                startNonExistingAudioPlayer(audioPlayer: audioPlayer, fileName: fileName, condition: condition)
            } catch {
                print("Could not load audio file with url \(audioFileURL.absoluteString)")
            }
        }
    }

    func playNote(note: Note) {
        if samplerCache.object(forKey: SamplerType.instrument.rawValue) == nil {
            connectInstrumentSampler()
        }
        samplerCache.object(forKey: SamplerType.instrument.rawValue)?.playNote(note)
    }

    func stopNote(note: Note) {
        let sampler = samplerCache.object(forKey: SamplerType.instrument.rawValue)
        sampler?.stopNote(note)
    }

    func playDrum(note: Note) {
        if samplerCache.object(forKey: SamplerType.drum.rawValue) == nil {
            connectDrumSampler()
        }
        samplerCache.object(forKey: SamplerType.drum.rawValue)?.playNote(note)
    }

    func stopDrum(note: Note) {
        let drumSampler = samplerCache.object(forKey: SamplerType.drum.rawValue)
        drumSampler?.stopNote(note)
    }

    func setInstrumentTo(instrumentNumber: Int) {
        instrumentChoice = instrumentNumber
        let instrumentPath = Bundle.main.resourcePath!+"/Sample Instruments Compressed/" + AudioEngineConfig.instrumentPath[instrumentChoice]
        samplerCache.object(forKey: SamplerType.instrument.rawValue)?.loadSFZ(path: instrumentPath, fileName: AudioEngineConfig.instrumentPath[instrumentChoice] + ".sfz")
    }

    func setEffectTo(effectType: SoundEffectType, value: Double) {
        soundEffects[effectType]?.setEffectTo(value)
    }

    func changeEffectBy(effectType: SoundEffectType, value: Double) {
        soundEffects[effectType]?.changeEffectBy(value)
    }

    func clearSoundEffects() {
        for (_, soundEffect) in soundEffects {
            soundEffect.clear()
        }
    }

    func connectSubtreeTo(node: AKInput) -> AKInput {
        return subtreeOutputMixer.connect(to: node)
    }

    func setVolumeTo(percent: Double) {
        subtreeOutputMixer.volume = percent / 100
    }

    func changeVolumeBy(percent: Double) {
        subtreeOutputMixer.volume += percent / 100
    }

    func pauseAllAudioPlayers() {
        for audioPlayerKey in audioPlayerCache.getKeySet() {
            audioPlayerCache.object(forKey: audioPlayerKey)?.pause()
        }
    }

    func stopAllAudioPlayers() {
        for audioPlayerKey in audioPlayerCache.getKeySet() {
            audioPlayerCache.object(forKey: audioPlayerKey)?.stop()
        }
        audioPlayerCache.removeAllObjects()
    }

    func resumeAllAudioPlayers() {
        for audioPlayerKey in audioPlayerCache.getKeySet() {
            audioPlayerCache.object(forKey: audioPlayerKey)?.resume()
        }
    }

    func pauseAllSamplers() {
        for samplerKey in samplerCache.getKeySet() {
            let sampler = samplerCache.object(forKey: samplerKey)
            sampler?.pauseSampler()
        }
    }

    func stopAllSamplers() {
        for samplerKey in samplerCache.getKeySet() {
            let sampler = samplerCache.object(forKey: samplerKey)
            sampler?.stopSampler()
            sampler?.unloadAllSamples()
        }
        audioPlayerCache.removeAllObjects()
    }

    func resumeAllSamplers() {
        for samplerKey in samplerCache.getKeySet() {
            let sampler = samplerCache.object(forKey: samplerKey)
            sampler?.resumeSampler()
        }
    }

    internal func createFileUrl(fileName: String, filePath: String) -> URL {
        return URL.init(fileURLWithPath: filePath + "/" + fileName)
    }

    private func setupSampler(_ sampler: Sampler?) {
        sampler?.attackDuration = 0.01
        sampler?.decayDuration = 0.1
        sampler?.sustainLevel = 0.5
        sampler?.releaseDuration = 0.5
        setInstrumentTo(instrumentNumber: instrumentChoice)
    }

    private func setupDrumSampler(_ drumSampler: Sampler?) {
        drumSampler?.attackDuration = 0.01
        drumSampler?.decayDuration = 0.1
        drumSampler?.sustainLevel = 0.5
        drumSampler?.releaseDuration = 0.5
        let instrumentPath = Bundle.main.resourcePath!+"/Sample Instruments Compressed/" + AudioEngineConfig.instrumentPath[21]
        drumSampler?.loadSFZ(path: instrumentPath, fileName: AudioEngineConfig.instrumentPath[21] + ".sfz")
    }

    private func connectInstrumentSampler() {
        _ = samplerCreationQueue.sync {
            if samplerCache.object(forKey: SamplerType.instrument.rawValue) == nil {
                let sampler = Sampler(type: SamplerType.instrument)
                samplerCache.setObject(sampler, forKey: SamplerType.instrument.rawValue)
                setupSampler(sampler)
                sampler.connect(to: subtreeOutputMixer)
            }
        }
    }

    private func connectDrumSampler() {
        _ = drumSamplerCreationQueue.sync {
            if samplerCache.object(forKey: SamplerType.drum.rawValue) == nil {
                let drumSampler = Sampler(type: SamplerType.drum)
                setupDrumSampler(drumSampler)
                samplerCache.setObject(drumSampler, forKey: SamplerType.drum.rawValue)
                drumSampler.connect(to: subtreeOutputMixer)
            }
        }
    }

    private func setupSubtree(mainOut: AKInput) {
        let panEffect = PanEffect()
        let pitchEffect = PitchEffect()
        soundEffects[SoundEffectType.pan] = panEffect
        soundEffects[SoundEffectType.pitch] = pitchEffect

        subtreeOutputMixer.connect(to: mainOut)
        panEffect.connect(to: subtreeOutputMixer)
        pitchEffect.connect(to: panEffect)
        audioPlayerMixer.connect(to: pitchEffect)
    }

    private func startNonExistingAudioPlayer(audioPlayer: AudioPlayer, fileName: String, condition: NSCondition?) {
        _ = playerCreationQueue.sync {
            if let audioPlayer = audioPlayerCache.object(forKey: fileName) {
                startExistingAudioPlayer(audioPlayer: audioPlayer, condition: condition)
            } else {
                audioPlayerCache.setObject(audioPlayer, forKey: fileName)
                audioPlayer.connect(to: audioPlayerMixer)
                audioPlayer.play(condition: condition)
            }
        }
    }

    private func startExistingAudioPlayer(audioPlayer: AudioPlayer, condition: NSCondition?) {
        audioPlayer.play(condition: condition)
    }
}
