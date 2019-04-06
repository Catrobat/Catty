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

    @nonobjc func instruction(audioEngine: AudioEngine) -> CBInstruction {

        guard let objectName = self.script?.object?.name,
            let projectPath = self.script?.object?.projectPath()
            else { fatalError("This should never happen!") }

        guard let sound = self.sound,
            let fileName = sound.fileName
            else { return .invalidInstruction() }

        let filePath = projectPath + kProjectSoundsDirName

        return CBInstruction.waitExecClosure { context, _ in
            let waitUntilSoundPlayed = NSCondition()
            waitUntilSoundPlayed.accessibilityHint = "0"
            
            DispatchQueue.main.async {
                audioEngine.playSound(fileName: fileName, key: objectName, filePath: filePath, condition: waitUntilSoundPlayed)
            }
            
            waitUntilSoundPlayed.lock()
            while waitUntilSoundPlayed.accessibilityHint == "0" {
                waitUntilSoundPlayed.wait()
            }
            waitUntilSoundPlayed.unlock()
            usleep(10000) //will sleep for 0.01seconds. Needed to have consistent behaviour in the followin case: First Object has a "when tapped"
            //script with 2 "play sound and wait" bricks. 2nd object has a "when tapped" script with one "play sound and wait" brick. Tap first object,
            //then tap 2nd object. "play sound and wait" brick from 2nd object should not be audible because the 2nd "play sound and wait" brick from the
            //first object will stop the sound from the 2nd object immediately if all sounds are the same.
        }

    }

}
