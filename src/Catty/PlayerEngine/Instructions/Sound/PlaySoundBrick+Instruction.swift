/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

extension PlaySoundBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        
        guard let objectName = self.script?.object?.name,
            let filePath = self.script?.object?.soundsDirectory()
            else { fatalError("This should never happen!") }

        guard let sound = self.sound,
              let fileName = sound.fileName
        else { return .InvalidInstruction() }

        let audioManager = AudioManager.sharedAudioManager()

        return CBInstruction.ExecClosure { (context, _) in
            //            self.logger.debug("Performing: PlaySoundBrick")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
                audioManager.playSoundWithFileName(fileName, andKey: objectName, atFilePath: filePath)
            }
            context.state = .Runnable
        }

    }

}
