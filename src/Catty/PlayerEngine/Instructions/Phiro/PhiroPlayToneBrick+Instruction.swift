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

@objc extension PhiroPlayToneBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        guard let object = self.script?.object
            else { fatalError("This should never happen!") }
        return CBInstruction.execClosure { context, _ in
            let durationInterpretation = context.formulaInterpreter.interpretDouble(self.durationFormula, for: object)

            guard let phiro = BluetoothService.swiftSharedInstance.phiro else { return }

            switch self.phiroTone() {
            case .DO:
                phiro.playTone(262, duration: durationInterpretation)
            case .RE:
                phiro.playTone(294, duration: durationInterpretation)
            case .MI:
                phiro.playTone(330, duration: durationInterpretation)
            case .FA:
                phiro.playTone(349, duration: durationInterpretation)
            case .SO:
                phiro.playTone(392, duration: durationInterpretation)
            case .LA:
                phiro.playTone(440, duration: durationInterpretation)
            case .TI:
                phiro.playTone(494, duration: durationInterpretation)
            @unknown default:
                print("ERROR: case not handled by switch statement")
            }
            context.state = .runnable
        }
    }
}
