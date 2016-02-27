/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

extension ChangeVariableBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {

        guard let spriteObject = self.script?.object,
              let variables = spriteObject.program?.variables
        else { fatalError("This should never happen!") }

        let userVariable = self.userVariable
        let variableFormula = self.variableFormula

        return CBInstruction.ExecClosure { (context, _) in
//            self.logger.debug("Performing: ChangeVariableBrick")
            let result = variableFormula.interpretDoubleForSprite(spriteObject)
            variables.changeVariable(userVariable, byValue: result)
            
            //update active UserVariable
            userVariable.textLabel.text = String(Int(userVariable.value.doubleValue))
            
            context.state = .Runnable
        }

    }
}
