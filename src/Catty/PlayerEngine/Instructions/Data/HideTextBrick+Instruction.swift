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

@objc extension HideTextBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {

        guard let spriteObject = self.script?.object,
            let _ = spriteObject.program?.variables
            else { fatalError("This should never happen!") }

        let userVariable = self.userVariable

        return CBInstruction.execClosure { context, _ in
            //            self.logger.debug("Performing: HideTextBrick")
            if let userVariable = userVariable {
                userVariable.textLabel.isHidden = true
            }
            context.state = .runnable
        }

    }
}
