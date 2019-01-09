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

@objc extension GlideToBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        guard let durationFormula = self.durationInSeconds else { fatalError("This should never happen!") }

        return .longDurationAction(duration: CBDuration.varTime(formula: durationFormula), closure: {
            duration, context -> SKAction in
            self.action(duration, context.formulaInterpreter)
        })
    }

    @objc func action(_ duration: TimeInterval, _ formulaInterpreter: FormulaInterpreterProtocol) -> SKAction {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode
            else { fatalError("This should never happen!") }

        let xDestination = formulaInterpreter.interpretFloat(self.xDestination, for: object)
        let yDestination = formulaInterpreter.interpretFloat(self.yDestination, for: object)
        let duration = formulaInterpreter.interpretDouble(self.durationInSeconds, for: object)

        guard let scene = spriteNode.scene else {
            fatalError("This should never happen!")
        }
        let destPoint = CGPoint(x: scene.size.width / 2 + CGFloat(xDestination), y: scene.size.height / 2 + CGFloat(yDestination))

        let action = SKAction.move(to: destPoint, duration: duration)
        return action
    }
}
