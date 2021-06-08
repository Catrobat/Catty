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

import AudioKit
import DunneAudioKit
import Foundation

@objc class AudioSubtree: NSObject {
    var audioPlayerFactory: AudioPlayerFactory

    var subtreeOutputMixer = AudioKit.Mixer()

    var instrument = AudioEngineDefines.defaultInstrument
    var samplerCache = IterableCache<DunneAudioKit.Sampler>()

    var audioPlayerCache = IterableCache<AudioPlayer>()
    let playerCreationQueue = DispatchQueue(label: "PlayerCreationQueue")

    init(audioPlayerFactory: AudioPlayerFactory) {
        self.audioPlayerFactory = audioPlayerFactory
        super.init()
    }

    func setOutput(_ mixer: AudioKit.Mixer) {
        mixer.addInput(subtreeOutputMixer)
    }

    func playSound(fileName: String, filePath: String, expectation: CBExpectation?) {
        getAudioPlayer(fileName: fileName, filePath: filePath)?.play(expectation: expectation)
    }

    func setVolumeTo(percent: Double) {
        let volume = percent / 100
        subtreeOutputMixer.volume = AudioKit.AUValue(MathUtil.moveValueIntoRange(volume, min: 0, max: 1))
    }

    func changeVolumeBy(percent: Double) {
        let newVolume = Double(subtreeOutputMixer.volume) + (percent / 100)
        subtreeOutputMixer.volume = AudioKit.AUValue(MathUtil.moveValueIntoRange(newVolume, min: 0, max: 1))
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

    func setInstrument(_ instrument: Instrument) {
        self.instrument = instrument
        if let instrumentURL = instrument.url {
            samplerCache.object(forKey: SamplerType.instrument.rawValue)?.loadSFZ(url: instrumentURL)
        }
    }

    private func getAudioPlayer(fileName: String, filePath: String) -> AudioPlayer? {
        playerCreationQueue.sync {
            if audioPlayerCache.object(forKey: fileName) == nil {
                if let audioPlayer = audioPlayerFactory.createAudioPlayer(fileName: fileName, filePath: filePath) {
                    audioPlayer.setOutput(self.subtreeOutputMixer)
                    audioPlayerCache.setObject(audioPlayer, forKey: fileName)
                }
            }
        }
        return audioPlayerCache.object(forKey: fileName)
    }
}
