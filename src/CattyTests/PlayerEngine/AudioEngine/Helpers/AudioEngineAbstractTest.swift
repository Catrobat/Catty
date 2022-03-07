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

import ChromaSwift
import XCTest

@testable import Pocket_Code

class AudioEngineAbstractTest: XMLAbstractTest {
    var audioEngine: AudioEngineFingerprintingStub!

    override func setUp() {
        super.setUp()
        audioEngine = AudioEngineFingerprintingStub(audioPlayerFactory: FingerprintingAudioPlayerFactory())
    }

    func runAndRecord(duration: Double, stage: Stage, muted: Bool) -> AVAudioFile {
        audioEngine.muted = muted

        _ = stage.startProject()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: duration))
        stage.stopProject()

        return audioEngine.tape!
    }

    func calculateSimilarity(tape: AVAudioFile, referenceHash: String) -> Double {
        guard let fingerprint = try? AudioFingerprint(from: tape.url) else {
            print("Could not generate fingerprint")
            return 0
        }

        print("The recorded duration is \(fingerprint.duration)")
        print("The binary fingerprint is \(fingerprint.hash)")

        guard let similarity = try? fingerprint.similarity(to: referenceHash) else {
            print("Could not calculate hash similarity")
            return 0
        }

        print("The similarity is \(similarity)")
        return similarity
    }

    func createStage(xmlFile: String) -> Stage {
        let project = self.getProjectForXML(xmlFile: xmlFile)
        let stageBuilder = StageBuilder(project: project)
            .withFormulaManager(formulaManager: FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false))
            .withAudioEngine(audioEngine: audioEngine)
        return stageBuilder.build()
    }
}
