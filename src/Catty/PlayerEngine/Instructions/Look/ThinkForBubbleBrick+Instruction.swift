/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

extension ThinkForBubbleBrick: CBInstructionProtocol {
    func instruction() -> CBInstruction {
        guard let object = self.script?.object,
            let _ = object.spriteNode
            else { fatalError("This should never happen!") }
        
        let cachedDuration = self.intFormula.isIdempotent()
            ? CBDuration.FixedTime(duration: self.intFormula.interpretDoubleForSprite(object))
            : CBDuration.VarTime(formula: self.intFormula)
        
        return .LongDurationAction(duration: cachedDuration, actionCreateClosure: {
            (duration) -> SKAction in
            return SKAction.sequence([SKAction.runBlock(self.actionBlock(object)), SKAction.waitForDuration(duration), SKAction.runBlock(self.removeActionBlock(object))])
        })
    }
    
    func actionBlock(object: SpriteObject) -> dispatch_block_t {
        return {
            var speakText = self.stringFormula.interpretString(object)
            if(Double(speakText) !=  nil)
            {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            BubbleBrickHelper.addBubbleToSpriteNode(object.spriteNode, withText: speakText, andType: CBBubbleType.Thought)
        }
    }
    
    func removeActionBlock(object: SpriteObject) -> dispatch_block_t {
        return {
            let oldBubble = object.spriteNode.childNodeWithName(kBubbleBrickNodeName);
            
            if (oldBubble != nil)
            {
                oldBubble!.runAction(SKAction.removeFromParent());
                object.spriteNode.removeChildrenInArray([oldBubble!]);
            }
        }
    }
}
