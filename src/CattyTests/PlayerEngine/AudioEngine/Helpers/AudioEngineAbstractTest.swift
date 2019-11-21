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
import XCTest

@testable import Pocket_Code

class AudioEngineAbstractTest: XMLAbstractTest {

    var tape: AKAudioFile!
    var audioEngine: AudioEngineFingerprintingStub!
    var recorder: AKNodeRecorder!

    override func setUp() {
        super.setUp()
        do {
            tape = try AKAudioFile()
            audioEngine = AudioEngineFingerprintingStub(audioPlayerFactory: FingerprintingAudioPlayerFactory())
            recorder = audioEngine.addNodeRecorderAtEngineOut(tape: tape)

        } catch {
            XCTFail("Could not set up audio engine integration test")
        }
    }

    override func tearDown() {
        super.tearDown()
        audioEngine.stop()
    }

    func runAndRecord(duration: Int, scene: CBScene, muted: Bool) -> AKAudioFile {
        do {
            audioEngine.postProcessingMixer.volume = muted ? 0.0 : 1.0
            audioEngine.speechSynth.utteranceVolume = muted ? 0.0 : 1.0
            try recorder.record()
            _ = scene.startProject()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))
            recorder.stop()
        } catch {
            XCTFail("Error occured")
        }
        return self.tape
    }

    func calculateSimilarity(tape: AKAudioFile, referenceHash: String) -> Double {
        let readTape: AKAudioFile
        do {
            readTape = try AKAudioFile(forReading: tape.url)
        } catch {
            print("Could not read audio file")
            return 0
        }

        let fingerprinter = ChromaprintFingerprinter()
        guard let (simHashString, duration) = fingerprinter.generateFingerprint(fromSongAtUrl: readTape.url) else {
            print("No fingerprint was generated")
            return 0
        }

        print("The recorded duration is \(duration)")
        print("The binary fingerprint is: \(simHashString)")

        let currentSimHash = Array(simHashString).map({ Int(String($0))! })
        let referenceSimHash = Array(referenceHash).map({ Int(String($0))! })

        if referenceSimHash.count != currentSimHash.count {
            return 0
        }

        var matchingDigits = 0
        for i in 0..<referenceSimHash.count where referenceSimHash[i] == currentSimHash[i] {
                matchingDigits += 1
        }

        let similarity: Double = matchingDigits / referenceSimHash.count
        print("The similarity is \(similarity)")

        return similarity
    }

    func createScene(xmlFile: String) -> CBScene {
        let project = self.getProjectForXML(xmlFile: xmlFile)
        let sceneBuilder = SceneBuilder(project: project).withFormulaManager(formulaManager: FormulaManager(sceneSize: Util.screenSize(true))).withAudioEngine(audioEngine: audioEngine)
        return sceneBuilder.build()
    }
}
