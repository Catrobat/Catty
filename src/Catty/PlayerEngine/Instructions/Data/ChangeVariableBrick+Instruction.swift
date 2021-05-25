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

@objc extension ChangeVariableBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        guard let spriteObject = self.script?.object
            else { fatalError("This should never happen!") }

        let userVariable = self.userVariable
        let variableFormula = self.variableFormula

        return CBInstruction.execClosure { context, _ in
            if let userVariable = userVariable, let variableFormula = variableFormula {
                let result = context.formulaInterpreter.interpret(variableFormula, for: spriteObject)
                if userVariable.value == nil {
                    if result is NSNumber {
                        userVariable.value = NSNumber(value: 0 as Int32)
                    } else {
                        userVariable.value = ""
                    }
                }
                if let _ = (userVariable.value as? NSNumber)?.doubleValue,
                    let numberDoubleValue = (result as? NSNumber)?.doubleValue {
                    userVariable.change(by: numberDoubleValue)
                } else if userVariable.value is NSString {
                    // do nothing
                } else {
                    // do nothing
                }
            }
            context.state = .runnable
        }
    }
}
