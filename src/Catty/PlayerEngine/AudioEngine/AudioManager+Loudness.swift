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

extension AudioEngine: AudioManagerProtocol {
       func startLoudnessRecorder() {
           if !self.isRecording {
               self.inputNode = self.loudnessEngine.inputNode
               self.recordingFormat = self.inputNode.outputFormat(forBus: 0)
               self.inputNode.installTap(onBus: 0, bufferSize: 2048, format: self.recordingFormat) { buffer, _ in
                   let db = self.decibelFullScale(from: buffer)
                   if !db.isNaN { self.dbSamples.append(db) }
               }
           }
           self.loudnessEngine.prepare()
           try? self.loudnessEngine.start()
           self.isRecording = true

       }

       func stopLoudnessRecorder() {
           if self.isRecording {
               self.inputNode.removeTap(onBus: 0)
               self.loudnessEngine.stop()
               self.dbSamples.removeAll() // dot return sound if stop was called
               self.isRecording = false
           }
       }

       func pauseLoudnessRecorder() {
           if self.isRecording {
               self.loudnessEngine.pause()
               self.isRecording = false
           }
       }

       func resumeLoudnessRecorder() {
           if !self.isRecording {
               try? self.loudnessEngine.start()
               self.isRecording = true
           }
       }

       func loudness() -> Double? {
           if self.dbSamples.isEmpty { return nil }
           return (self.dbSamples.reduce(0, +) / Double(self.dbSamples.count))
       }

    private func decibelFullScale(from buffer: AVAudioPCMBuffer) -> Double {
        let arraySize = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: arraySize))
        let dBFS = 20 * log10(abs(samples.max()!))
        return Double(dBFS)
    }

       func loudnessAvailable() -> Bool {
           var isGranted = false
           let dispatchGroup = DispatchGroup()

           switch AVAudioSession.sharedInstance().recordPermission {
           case AVAudioSession.RecordPermission.denied:
               isGranted = false
           case AVAudioSession.RecordPermission.undetermined:
               dispatchGroup.enter()
               AVAudioSession.sharedInstance().requestRecordPermission({ (granted: Bool) in
                   isGranted = granted
                   dispatchGroup.leave()
               })
               dispatchGroup.wait()
           case AVAudioSession.RecordPermission.granted:
               isGranted = true
           @unknown default:
               print("ERROR: case not handled by switch statement")
           }

           return isGranted
       }
}
