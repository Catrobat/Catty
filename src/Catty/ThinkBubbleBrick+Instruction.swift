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

extension ThinkBubbleBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        return .Action(action: SKAction.runBlock(actionBlock()))
    }
    
    func actionBlock() -> dispatch_block_t {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode
            else { fatalError("This should never happen!") }
        
        return {
            var speakText = self.formula.interpretString(object)
            if(Double(speakText) !=  nil)
            {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            
            let label = SKLabelNode(text: speakText)
            label.name = "bubbleText"
            var bubbleWidth: CGFloat = 250
            let horizontalPadding: CGFloat = 45
            label.fontColor = UIColor.blackColor()
            
            if (label.frame.width > bubbleWidth)
            {
                while (label.frame.width > bubbleWidth)
                {
                    if var chars = label.text?.characters
                    {
                        let _ = chars.popLast()
                        label.text = String(chars)
                    }
                }
                label.text?.appendContentsOf("...")
            }
            
            if let oldBubble = spriteNode.childNodeWithName(kBubbleBrickNodeName)
            {
                oldBubble.runAction(SKAction.removeFromParent())
            }
            bubbleWidth = label.frame.width + horizontalPadding
            let sayBubble = SKShapeNode(path: self.bubblePath(withWidth: bubbleWidth))
            sayBubble.name = kBubbleBrickNodeName
            sayBubble.fillColor = UIColor.whiteColor()
            sayBubble.lineWidth = 3.0
            sayBubble.strokeColor = UIColor.blackColor()
            
            sayBubble.fillColor = UIColor.whiteColor()
            sayBubble.strokeColor = UIColor.blackColor()
            
            sayBubble.position = sayBubble.convertPoint(CGPointMake(spriteNode.position.x + spriteNode.frame.width / 2, spriteNode.position.y + spriteNode.frame.height / 2), toNode: spriteNode)
            
            label.position = CGPointMake(sayBubble.frame.width/2, sayBubble.frame.height*0.6)
            sayBubble.addChild(label)
            
            spriteNode.addChild(sayBubble)
        }
    }
    
    private func bubblePath(withWidth width: CGFloat) -> CGPath {
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(33.5, 29.5, 18, 18))

        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(22.5, 18.5, 14, 14))

        let oval3Path = UIBezierPath(ovalInRect: CGRectMake(11.5, 8.5, 12, 12))

        let oval4Path = UIBezierPath(ovalInRect: CGRectMake(2.5, 0.5, 7, 7))

        let thinkBubble = UIBezierPath(roundedRect: CGRectMake(1.5, 47.5, width, 50), cornerRadius: 15)
        
        thinkBubble.appendPath(ovalPath)
        thinkBubble.appendPath(oval2Path)
        thinkBubble.appendPath(oval3Path)
        thinkBubble.appendPath(oval4Path)
        
        return thinkBubble.CGPath
    }
}
