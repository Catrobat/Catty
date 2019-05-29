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

@objc extension PlayDrumBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        guard let spriteObject = self.script?.object else { fatalError("This should never happen") }
        let spriteObjectName = spriteObject.name

        return CBInstruction.waitExecClosure { context, scheduler in
            let audioEngine = (scheduler as! CBScheduler).getAudioEngine()
            let noteFinishedExpectation = Expectation()

            let durationInSeconds = AudioEngineConfig.beatsToSeconds(beatsFormula: self.duration, bpm: audioEngine.bpm, spriteObject: spriteObject, context: context)
            if durationInSeconds <= 0.0 { return }

            let durationTimer = ExtendedTimer.init(timeInterval: durationInSeconds,
                                                   repeats: false,
                                                   execOnMainRunLoop: true,
                                                   startTimerImmediately: false) {_ in
                                                    noteFinishedExpectation.fulfill()
            }

            let note = Note(pitch: self.drumChoice)
            audioEngine.playDrum(note: note, key: spriteObjectName!)

            scheduler.registerTimer(durationTimer)
            noteFinishedExpectation.wait()
            audioEngine.stopDrum(note: note, key: spriteObjectName!)
            scheduler.removeTimer(durationTimer)
        }
    }
}
