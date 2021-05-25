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

@objc extension MoveNStepsBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context.formulaInterpreter)) }
    }

    @objc func actionBlock(_ formulaInterpreter: FormulaInterpreterProtocol) -> () -> Void {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode,
            let stepsFormula = self.steps
            else { fatalError("This should never happen!") }

        return {
            let steps = formulaInterpreter.interpretDouble(stepsFormula, for: object)
            let standardizedRotation = spriteNode.catrobatRotation
            let rotationRadians = Util.degree(toRadians: Double(standardizedRotation))

            let position = spriteNode.catrobatPosition
            let xPosition = position.x + (steps * sin(rotationRadians))
            let yPosition = position.y + (steps * cos(rotationRadians))

            spriteNode.catrobatPosition = CBPosition(x: xPosition, y: yPosition)
        }
    }
}
