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
            
            if let oldBubble = spriteNode.childNodeWithName("textBubble")
            {
                oldBubble.runAction(SKAction.removeFromParent())
            }
            bubbleWidth = label.frame.width + horizontalPadding
            let sayBubble = SKShapeNode(path: self.bubblePath(withWidth: bubbleWidth))
            sayBubble.name = "textBubble"
            sayBubble.fillColor = UIColor.whiteColor()
            sayBubble.lineWidth = 3.0
            sayBubble.strokeColor = UIColor.blackColor()
            
            sayBubble.fillColor = UIColor.whiteColor()
            sayBubble.strokeColor = UIColor.blackColor()
            
            sayBubble.position = CGPointMake(spriteNode.size.width - sayBubble.frame.width / 2, spriteNode.size.height - sayBubble.frame.height / 2)
            
            label.position = CGPointMake(sayBubble.frame.width/2, sayBubble.frame.height*0.6)
            sayBubble.addChild(label)
            
            spriteNode.addChild(sayBubble)
        }
    }
    
    private func bubblePath(withWidth width: CGFloat) -> CGPath {

        //Bubble's bezier path with width = 1
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(0.96, 99.03))
        bezier2Path.addLineToPoint(CGPointMake(0.97, 98.89))
        bezier2Path.addCurveToPoint(CGPointMake(1, 90.67), controlPoint1: CGPointMake(0.98, 97.5), controlPoint2: CGPointMake(0.99, 94.49))
        bezier2Path.addCurveToPoint(CGPointMake(1, 77.41), controlPoint1: CGPointMake(1, 87.17), controlPoint2: CGPointMake(1, 83.91))
        bezier2Path.addLineToPoint(CGPointMake(1, 73.33))
        bezier2Path.addCurveToPoint(CGPointMake(1, 60.64), controlPoint1: CGPointMake(1, 66.82), controlPoint2: CGPointMake(1, 63.57))
        bezier2Path.addLineToPoint(CGPointMake(1, 60.07))
        bezier2Path.addCurveToPoint(CGPointMake(0.97, 51.85), controlPoint1: CGPointMake(0.99, 56.25), controlPoint2: CGPointMake(0.98, 53.24))
        bezier2Path.addCurveToPoint(CGPointMake(0.92, 50.74), controlPoint1: CGPointMake(0.95, 50.74), controlPoint2: CGPointMake(0.94, 50.74))
        bezier2Path.addLineToPoint(CGPointMake(0.58, 50.74))
        bezier2Path.addCurveToPoint(CGPointMake(0, 0.11), controlPoint1: CGPointMake(0.52, 45.64), controlPoint2: CGPointMake(0.03, 2.59))
        bezier2Path.addCurveToPoint(CGPointMake(0, 0), controlPoint1: CGPointMake(0, 0.04), controlPoint2: CGPointMake(0, 0.01))
        bezier2Path.addCurveToPoint(CGPointMake(0.21, 50.74), controlPoint1: CGPointMake(0, 0.03), controlPoint2: CGPointMake(0.21, 50.74))
        bezier2Path.addLineToPoint(CGPointMake(0.18, 50.74))
        bezier2Path.addCurveToPoint(CGPointMake(0.14, 51.71), controlPoint1: CGPointMake(0.16, 50.74), controlPoint2: CGPointMake(0.15, 50.74))
        bezier2Path.addLineToPoint(CGPointMake(0.14, 51.85))
        bezier2Path.addCurveToPoint(CGPointMake(0.11, 60.07), controlPoint1: CGPointMake(0.12, 53.24), controlPoint2: CGPointMake(0.11, 56.25))
        bezier2Path.addCurveToPoint(CGPointMake(0.1, 73.33), controlPoint1: CGPointMake(0.1, 63.57), controlPoint2: CGPointMake(0.1, 66.82))
        bezier2Path.addLineToPoint(CGPointMake(0.1, 77.41))
        bezier2Path.addCurveToPoint(CGPointMake(0.11, 90.1), controlPoint1: CGPointMake(0.1, 83.91), controlPoint2: CGPointMake(0.1, 87.17))
        bezier2Path.addLineToPoint(CGPointMake(0.11, 90.67))
        bezier2Path.addCurveToPoint(CGPointMake(0.14, 98.89), controlPoint1: CGPointMake(0.11, 94.49), controlPoint2: CGPointMake(0.12, 97.5))
        bezier2Path.addCurveToPoint(CGPointMake(0.18, 100), controlPoint1: CGPointMake(0.15, 100), controlPoint2: CGPointMake(0.16, 100))
        bezier2Path.addLineToPoint(CGPointMake(0.92, 100))
        bezier2Path.addCurveToPoint(CGPointMake(0.96, 99.03), controlPoint1: CGPointMake(0.94, 100), controlPoint2: CGPointMake(0.95, 100))
        bezier2Path.closePath()
        
        //Since width is 1, scaling along x times width.
        bezier2Path.applyTransform(CGAffineTransformMakeScale(width, 1.0))
        
        return bezier2Path.CGPath
    }
}
