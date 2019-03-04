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

final class AudioEngineTests: XMLAbstractTest {

    override func setUp() {
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
                let data1 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![0], count: Int(readTape.pcmBuffer.frameLength))).bytes
                let data2 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![1], count: Int(readTape.pcmBuffer.frameLength))).bytes

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

    func testParseSoundProgram() {
        let audioEngine = AudioEngineMock()
        let formulaInterpreter = FormulaManager(sceneSize: Util.screenSize(true))
        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler, formulaInterpreter: formulaInterpreter)

        let program = self.getProjectForXML(xmlFile: "soundtest")
        let spriteObject = program.objectList[0] as? SpriteObject
        let script = spriteObject?.scriptList[0] as? WhenScript
        let soundBrick = script?.brickList[0] as? PlaySoundBrick
        let file = soundBrick?.sound.fileName

        let context = CBScriptContext(script: script!, spriteNode: CBSpriteNode(spriteObject: spriteObject!), formulaInterpreter: formulaInterpreter)

        let instruction = soundBrick!.instruction(audioEngine: audioEngine)

        switch instruction {
        case let .execClosure(closure):
            closure(context!, scheduler)
        default:
            XCTFail("Undifined error occured")
        }

        // let existsPredicate = NSPredicate(format: "exists == true")

        let existsPredicate = NSPredicate(block: { any, _ in
            guard let engine = any as? AudioEngine else { return false }
            let chn = engine.channels["Background"]
            let player = chn?.audioPlayers[file!]
            return chn != nil && player != nil
        })
        expectation(for: existsPredicate, evaluatedWith: audioEngine, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSpeakAndWait() {
        do {
            var soundEngine = AudioEngineMock()
            let tape = try AKAudioFile()
            let recorder = soundEngine.addNodeRecorderAtMainOut(tape: tape)
            let project = self.getProjectForXML(xmlFile: "speakandwaittest")
            let scene = self.createScene(project: project, soundEngine: soundEngine)
            try recorder.record()
            scene.startProject()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 6))
            recorder.stop()
            play(tape: tape)
        } catch {
            XCTFail("Error occured")
        }
    }

    func testStartSound() {
        do {
            let soundEngine = AudioEngineMock()
            let tape = try AKAudioFile()
            let recorder = soundEngine.addNodeRecorderAtMainOut(tape: tape)
            let project = self.getProjectForXML(xmlFile: "StartSoundTest")
            let scene = self.createScene(project: project, soundEngine: soundEngine)
            try recorder.record()

            scene.startProject()

            RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))
            recorder.stop()
            print("Recorded \(recorder.recordedDuration) Seconds")
            play(tape: tape)
            //RunLoop.current.run(until: Date(timeIntervalSinceNow: 11))
            let bla = ""
        } catch {
            XCTFail("Error occured")
        }
    }

    func play(tape: AKAudioFile) {
        do {
            let readTape = try AKAudioFile(forReading: tape.url)

            guard let (fingerprintString, duration) = generateFingerprint(fromSongAtUrl: readTape.url) else {
                print("No fingerprint was generated")
                return
            }

            print("The song duration is \(duration)")
            print("The fingerprint is: \(fingerprintString)")

            let data1 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![0], count: Int(readTape.pcmBuffer.frameLength))).bytes
            let data2 = Data(buffer: UnsafeBufferPointer(start: readTape.pcmBuffer.floatChannelData![1], count: Int(readTape.pcmBuffer.frameLength))).bytes

            do {
                var digest = MD5()
                _ = try digest.update(withBytes: data1)
                _ = try digest.update(withBytes: data2)
                let result = try digest.finish()
                print("The Hash is \(result)")
            } catch {}

            //            let akPlayer = try AKAudioPlayer(file: readTape)
            //            let mix = AKMixer(akPlayer)
            //            AudioKit.output = mix
            //            try AudioKit.start()
            //            akPlayer.play()

        } catch {
            print("error")
        }
    }

    private func createScene(project: Project, soundEngine: AudioEngine) -> CBScene {
        let sceneBuilder = SceneBuilder(project: project).withFormulaManager(formulaManager: FormulaManager(sceneSize: Util.screenSize(true))).withSoundEngine(soundEngine: soundEngine)
        return sceneBuilder.build()
    }
}

class AudioEngineMock: AudioEngine {
    override internal func createNewAudioChannel(key: String) -> AudioChannel {
        let channel = AudioChannelMock()
        channel.connectTo(node: mainOut)
        channels[key] = channel
        return channel
    }
}

class AudioChannelMock: AudioChannel {
    override internal func createFileUrl(fileName: String, filePath: String) -> URL {
        let bundle = Bundle.init(for: self.classForCoder)
        let path = bundle.path(forResource: fileName, ofType: nil)
        return URL.init(fileURLWithPath: path!)
    }
}
