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
import CryptoSwift
import XCTest

@testable import Pocket_Code

class AudioEngineTests: XCTestCase {

    override func setUp( ) {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testHash() {

        let testBundle = Bundle(for: type(of: self))
        let audioFileURL1 = testBundle.url(forResource: "russianfolk", withExtension: "wav")
        let audioFileURL2 = testBundle.url(forResource: "explode", withExtension: "mp3")

        do {
            let file1 = try AKAudioFile(forReading: audioFileURL1!)
            let file2 = try AKAudioFile(forReading: audioFileURL2!)
            let akPlayer1 = try AKAudioPlayer(file: file1)
            let akPlayer2 = try AKAudioPlayer(file: file2)
            let tape = try AKAudioFile()
            let mix = AKMixer()
            // recorder = try AKNodeRecorder(node: mix, file: tape)
            // try recorder?.record()
            AudioKit.output = mix
            try AudioKit.start()

            let mix1 = AKMixer()
            let mix2 = AKMixer()
            akPlayer1.connect(to: mix1)
            akPlayer2.connect(to: mix2)
            mix1.connect(to: mix)
            mix2.connect(to: mix)

            if #available(iOS 11, *) {
                try AudioKit.renderToFile(tape, duration: 5, prerender: {
                    //                    var scheduleTime : TimeInterval = 0
                    let dspTime = AVAudioTime(sampleTime: AVAudioFramePosition(0.13 * AKSettings.sampleRate), atRate: AKSettings.sampleRate)
                    //                    let dspTime2 = AVAudioTime(sampleTime: AVAudioFramePosition(2 * AKSettings.sampleRate), atRate: AKSettings.sampleRate)
                    //                    akPlayer1.play(at: dspTime)
                    //                    akPlayer2.play(at: dspTime2)
                    akPlayer1.play()
                    akPlayer2.play(at: dspTime)
                })
            }

            let readTape = try AKAudioFile(forReading: tape.url)
            measure() {
                let data1 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![0], count:Int(readTape.pcmBuffer.frameLength))).bytes
                let data2 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![1], count:Int(readTape.pcmBuffer.frameLength))).bytes

                do {
                    var digest = MD5()
                    _ = try digest.update(withBytes: data1)
                    _ = try digest.update(withBytes: data2)
                    let result = try digest.finish()
                    print(result)
                } catch {}
            }

        } catch {
            print("error")
        }
    }
}
