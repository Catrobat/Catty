/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc extension SetVariableBrick: CBInstructionProtocol {
    
    @nonobjc func instruction() -> CBInstruction {
        
        guard let spriteObject = self.script?.object,
            let variables = spriteObject.program?.variables
            else { fatalError("This should never happen!") }
        
        let userVariable = self.userVariable
        let variableFormula = self.variableFormula
        
        return CBInstruction.execClosure { (context, _) in
//            self.logger.debug("Performing: SetVariableBrick")
            
            let result = variableFormula?.interpretVariableData(forSprite: spriteObject)
            variables.setUserVariable(userVariable, toValue: result)
            
            //update visible userVariable
            var value = ""
            if let userVariable = userVariable {
                if let userVariableNumber = userVariable.value as? NSNumber {
                    value = userVariableNumber.stringValue
                } else if let userVariableValue = userVariable.value as? String {
                    value = userVariableValue
                } else {
                    value = ""
                }
                userVariable.textLabel.text = value
            }
            context.state = .runnable
        }
        
    }
}
