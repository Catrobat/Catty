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
    var audioPlayerFactory: AudioPlayerFactory

    let playerCreationQueue = DispatchQueue(label: "PlayerCreationQueue")

    init(audioPlayerFactory: AudioPlayerFactory) {
        self.audioPlayerFactory = audioPlayerFactory
        super.init()
    }

    func setup(mainOut: AKInput) {
        subtreeOutputMixer.connect(to: mainOut)
        audioPlayerMixer.connect(to: subtreeOutputMixer)
    }

    func playSound(fileName: String, filePath: String, expectation: Expectation?) {
        if let audioPlayer = audioPlayerCache.object(forKey: fileName) {
            startExistingAudioPlayer(audioPlayer: audioPlayer, expectation: expectation)
        } else {
            let audioPlayer = audioPlayerFactory.createAudioPlayer(fileName: fileName, filePath: filePath)
            if let player = audioPlayer {
                startNonExistingAudioPlayer(audioPlayer: player, fileName: fileName, expectation: expectation)
            }
        }
    }

    func connectSubtreeTo(node: AKInput) -> AKInput {
        return subtreeOutputMixer.connect(to: node)
    }

    func setVolumeTo(percent: Double) {
        let volume = percent / 100
        subtreeOutputMixer.volume = MathUtil.moveValueIntoRange(volume, min: 0, max: 1)
    }

    func changeVolumeBy(percent: Double) {
        let newVolume = subtreeOutputMixer.volume + (percent / 100)
        subtreeOutputMixer.volume = MathUtil.moveValueIntoRange(newVolume, min: 0, max: 1)
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

    private func startNonExistingAudioPlayer(audioPlayer: AudioPlayer, fileName: String, expectation: Expectation?) {
        _ = playerCreationQueue.sync {
            if let audioPlayer = audioPlayerCache.object(forKey: fileName) {
                startExistingAudioPlayer(audioPlayer: audioPlayer, expectation: expectation)
            } else {
                audioPlayerCache.setObject(audioPlayer, forKey: fileName)
                audioPlayer.connect(to: audioPlayerMixer)
                audioPlayer.play(expectation: expectation)
            }
        }
    }

    private func startExistingAudioPlayer(audioPlayer: AudioPlayer, expectation: Expectation?) {
        audioPlayer.play(expectation: expectation)
    }
}
