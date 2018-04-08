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

@objc extension SayForBubbleBrick: CBInstructionProtocol {
    
    @nonobjc func instruction() -> CBInstruction {
        guard let object = self.script?.object,
            let _ = object.spriteNode
            else { fatalError("This should never happen!") }
        
        let cachedDuration = self.intFormula.isIdempotent()
            ? CBDuration.fixedTime(duration: self.intFormula.interpretDouble(forSprite: object))
            : CBDuration.varTime(formula: self.intFormula)
        
        return .longDurationAction(duration: cachedDuration, actionCreateClosure: {
            (duration) -> SKAction in
            return SKAction.sequence([SKAction.run(self.actionBlock(object: object)), SKAction.wait(forDuration: duration), SKAction.run(self.removeActionBlock(object: object))])
        })
    }
    
    @objc func actionBlock(object: SpriteObject) -> ()->() {
        return {
            var speakText = self.stringFormula.interpretString(object)
            if(Double(speakText!) !=  nil)
            {
                let num = (speakText! as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            BubbleBrickHelper.addBubble(to: object.spriteNode, withText: speakText, andType: CBBubbleType.speech)
        }
    }
    
    @nonobjc func removeActionBlock(object: SpriteObject) -> ()->() {
        return {
            let oldBubble = object.spriteNode.childNode(withName: kBubbleBrickNodeName);
            
            if (oldBubble != nil)
            {
                oldBubble!.run(SKAction.removeFromParent());
                object.spriteNode.removeChildren(in: [oldBubble!]);
            }
        }
    }
}
