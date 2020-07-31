/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@objc extension GoNStepsBackBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context.formulaInterpreter)) }
    }

    @objc func actionBlock(_ formulaInterpreter: FormulaInterpreterProtocol) -> () -> Void {
        guard let currentObject = self.script?.object,
            let currentSpriteNode = currentObject.spriteNode,
            let stepsFormula = self.steps,
            let objectList = self.script?.object?.scene.objects()
            else { fatalError("This should never happen!") }

        return {
            let currentLayer = currentSpriteNode.catrobatLayer
            let steps = formulaInterpreter.interpretDouble(stepsFormula, for: currentObject)
            currentSpriteNode.catrobatLayer -= steps

            for spriteObject in objectList {
                guard let spriteNode = spriteObject.spriteNode else {
                    continue
                }
                if spriteNode.catrobatLayer < currentLayer && spriteNode.catrobatLayer >= currentSpriteNode.catrobatLayer && spriteObject != currentObject {
                    spriteNode.catrobatLayer += 1
                }
            }
        }
    }
}
