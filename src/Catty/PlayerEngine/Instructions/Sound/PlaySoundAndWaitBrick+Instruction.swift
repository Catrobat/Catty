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

@objc extension PlaySoundAndWaitBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        guard let objectName = self.script?.object?.name,
            let projectPath = self.script?.object?.projectPath()
            else { fatalError("This should never happen!") }

        guard let sound = self.sound,
            let fileName = sound.fileName
            else { return .invalidInstruction }

        let filePath = projectPath + kProjectSoundsDirName

        return CBInstruction.waitExecClosure { _, scheduler in
            let audioEngine = (scheduler as! CBScheduler).getAudioEngine()
            let soundIsFinishedExpectation = CBExpectation()

            DispatchQueue.main.async {
                audioEngine.playSound(fileName: fileName, key: objectName, filePath: filePath, expectation: soundIsFinishedExpectation)
            }

            soundIsFinishedExpectation.wait()
        }
    }
}
