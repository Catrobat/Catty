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

extension SayBubbleBrick: CBInstructionProtocol {
    
    func instruction() -> CBInstruction {
        
        guard let object = self.script?.object,
        let spriteNode = object.spriteNode
        else { fatalError("This should never happen!") }
        
        return CBInstruction.ExecClosure { (context, _) in
            var speakText = self.formula.interpretString(object)
            if(Double(speakText) !=  nil)
            {
                let num = (speakText as NSString).doubleValue
                speakText = (num as NSNumber).stringValue
            }
            
            let label = SKLabelNode(text: speakText)
            var bubbleWidth: CGFloat = 250
            let horizontalPadding: CGFloat = 5
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
            
            bubbleWidth = label.frame.width + horizontalPadding
            let sayBubble = SKShapeNode(path: self.bubblePath(withWidth: bubbleWidth))
            
            sayBubble.fillColor = UIColor.whiteColor()
            sayBubble.strokeColor = UIColor.blackColor()
            sayBubble.position = CGPoint(x: spriteNode.size.width/4, y: spriteNode.size.height/2)
            
            label.position = CGPointMake(sayBubble.frame.width/2, 0)
            sayBubble.addChild(label)
            
            spriteNode.addChild(sayBubble)
        }
        
    }
    
    private func bubblePath(withWidth width: CGFloat) -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(0, 30))
        bezierPath.addLineToPoint(CGPointMake(width, 30))
        bezierPath.addLineToPoint(CGPointMake(width, -25))
        bezierPath.addLineToPoint(CGPointMake(width/4, -25))
        bezierPath.addLineToPoint(CGPointMake(0, -77))
        bezierPath.addLineToPoint(CGPointMake(width/10, -25))
        bezierPath.addLineToPoint(CGPointMake(0, -25))
        bezierPath.addLineToPoint(CGPointMake(0, 25))
        bezierPath.closePath()
        bezierPath.lineWidth = 1
        bezierPath.stroke()

        return bezierPath.CGPath
    }
    
}
