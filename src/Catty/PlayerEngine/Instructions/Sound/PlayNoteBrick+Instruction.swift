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

@objc extension PlayNoteBrick: CBInstructionProtocol {

    @nonobjc func instruction(audioEngine: AudioEngine) -> CBInstruction {
        guard let spriteObject = self.script?.object else { fatalError("This should never happen") }
        let spriteObjectName = spriteObject.name

        return CBInstruction.waitExecClosure { context, _ in
            let pitch = context.formulaInterpreter.interpretInteger(self.pitch, for: spriteObject)
            let durationInBeats = context.formulaInterpreter.interpretDouble(self.duration, for: spriteObject)
            let durationInSeconds = durationInBeats * 60 / audioEngine.bpm

            let waitUntilNoteFinished = NSCondition()
            waitUntilNoteFinished.accessibilityHint = "0"

            let noteDurationTimer = Timer.init(timeInterval: durationInSeconds, target: self, selector: #selector(PlayNoteBrick.noteOff(timer:)), userInfo: waitUntilNoteFinished, repeats: false)
            let note = Note(pitch: pitch, noteDurationTimer: noteDurationTimer)

            audioEngine.playNote(note: note, key: spriteObjectName!)

            waitUntilNoteFinished.lock()
            while waitUntilNoteFinished.accessibilityHint == "0" { //accessibilityHint used because synthesizer.speaking not yet true.
                waitUntilNoteFinished.wait()
            }
            waitUntilNoteFinished.unlock()
            audioEngine.stopNote(pitch: pitch, key: spriteObjectName!)
            audioEngine.activeNotes.remove(note)
        }
    }

    func noteOff(timer: Timer) {
        let condition = timer.userInfo as! NSCondition
        condition.accessibilityHint = "1"
        condition.signal()
    }
}
