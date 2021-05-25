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

@objc extension ThinkForBubbleBrick: CBInstructionProtocol {
    @nonobjc func instruction() -> CBInstruction {
        guard let object = self.script?.object,
            let _ = object.spriteNode
            else { fatalError("This should never happen!") }

        return .longDurationAction(duration: CBDuration.varTime(formula: self.intFormula), closure: { duration, context -> SKAction in
            SKAction.sequence([SKAction.run(self.actionBlock(object, context.formulaInterpreter)), SKAction.wait(forDuration: duration), SKAction.run(self.removeActionBlock(object))])
        })
    }

    @objc func actionBlock(_ object: SpriteObject, _ formulaInterpreter: FormulaInterpreterProtocol) -> () -> Void { {
            var speakText = formulaInterpreter.interpretString(self.stringFormula, for: object)

            if Double(speakText) != nil {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            BubbleBrickHelper.addBubble(to: object.spriteNode, withText: speakText, andType: CBBubbleType.thought)
        }
    }

    @objc func removeActionBlock(_ object: SpriteObject) -> () -> Void { {
            let oldBubble = object.spriteNode.childNode(withName: SpriteKitDefines.bubbleBrickNodeName)

            if oldBubble != nil {
                oldBubble!.run(SKAction.removeFromParent())
                object.spriteNode.removeChildren(in: [oldBubble!])
            }
        }
    }
}
