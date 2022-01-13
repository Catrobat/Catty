/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

extension AskBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        guard let question = self.question else { fatalError("Unexpected found nil.") }

        return CBInstruction.waitExecClosure { context, scheduler in
            var displayString = context.formulaInterpreter.interpretString(question, for: self.script.object)
            if let number = Double(displayString) {
                displayString = number.displayString
            }

            DispatchQueue.main.async {
                AlertControllerBuilder.textFieldAlert(title: nil, message: displayString)
                    .placeholder(kLocalizedAskBrickAnswer)
                    .addDefaultActionWithTitle(kLocalizedOK, handler: { answer in self.callbackSubmit(with: answer, scheduler: scheduler) })
                    .build()
                    .showWithController(Util.topmostViewController())
            }
            scheduler.pause()
        }
    }

    func callbackSubmit(with input: String, scheduler: CBSchedulerProtocol) {
        if let userVariable = self.userVariable, input.isNotEmpty {
            userVariable.value = input
        }
        scheduler.resume()
    }
}
