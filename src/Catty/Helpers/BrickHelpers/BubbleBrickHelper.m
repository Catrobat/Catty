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

#import "BubbleBrickHelper.h"
#import "Pocket_Code-Swift.h"

@implementation BubbleBrickHelper

+ (void)addBubbleToSpriteNode:(CBSpriteNode*)spriteNode withText: (NSString*)text andType:(CBBubbleType)type
{
    SKLabelNode* label = [SKLabelNode labelNodeWithText:text];
    label.name = @"bubbleText";
    CGFloat bubbleWidth = 250;
    CGFloat horizontalPadding = 45;
    
    label.fontColor = [UIColor blackColor];

    if (label.frame.size.width > bubbleWidth)
    {
        while (label.frame.size.width > bubbleWidth)
        {
            if (label.text != nil)
            {
                label.text = [label.text substringToIndex:label.text.length - 1];
            }
        }
        label.text = [label.text stringByAppendingString:@"..."];
    }

    SKNode* oldBubble = [spriteNode childNodeWithName:kBubbleBrickNodeName];

    if (oldBubble != nil)
    {
        [oldBubble runAction:[SKAction removeFromParent]];
        [spriteNode removeChildrenInArray:@[oldBubble]];
    }
    bubbleWidth = label.frame.size.width + horizontalPadding;
    SKShapeNode* sayBubble = [SKShapeNode shapeNodeWithPath:[self bubblePathWithWidth:bubbleWidth andType:type]];
    sayBubble.name = kBubbleBrickNodeName;
    sayBubble.fillColor = [UIColor whiteColor];
    sayBubble.strokeColor = [UIColor blackColor];
    sayBubble.lineWidth = 3.5;
    
    sayBubble.position = [sayBubble convertPoint:CGPointMake(spriteNode.position.x + spriteNode.frame.size.width / 2, spriteNode.position.y + spriteNode.frame.size.height / 2) toNode:spriteNode];

    label.position = CGPointMake(sayBubble.frame.size.width/2, sayBubble.frame.size.height*0.6);
    [sayBubble addChild:label];
    [spriteNode addChild:sayBubble];
}

                        
+ (CGPathRef) bubblePathWithWidth:(CGFloat)width andType:(CBBubbleType)type
{
    
    UIBezierPath* bubblePath;
    
    switch (type) {
        case CBBubbleTypeThought:
        {
            bubblePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 47.5, width, 45) cornerRadius: 15];
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(33.5, 29.5, 18, 18)];
            UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(22.5, 18.5, 14, 14)];
            UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(11.5, 8.5, 12, 12)];
            UIBezierPath* oval4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2.5, 0.5, 7, 7)];
            
            [bubblePath appendPath:ovalPath];
            [bubblePath appendPath:oval2Path];
            [bubblePath appendPath:oval3Path];
            [bubblePath appendPath:oval4Path];
            break;
        }
        case CBBubbleTypeSpeech:
        {
            bubblePath = [UIBezierPath bezierPath];
            [bubblePath moveToPoint: CGPointMake(244.03, 83)];
            [bubblePath addCurveToPoint: CGPointMake(244.07, 83) controlPoint1: CGPointMake(243.86, 83) controlPoint2: CGPointMake(243.86, 83)];
            [bubblePath addCurveToPoint: CGPointMake(252.35, 81.53) controlPoint1: CGPointMake(244.73, 82.95) controlPoint2: CGPointMake(248.7, 82.73)];
            [bubblePath addLineToPoint: CGPointMake(253.21, 81.31)];
            [bubblePath addCurveToPoint: CGPointMake(267, 61.62) controlPoint1: CGPointMake(261.49, 78.3) controlPoint2: CGPointMake(267, 70.43)];
            [bubblePath addCurveToPoint: CGPointMake(267, 60.5) controlPoint1: CGPointMake(267, 60.5) controlPoint2: CGPointMake(267, 60.5)];
            [bubblePath addLineToPoint: CGPointMake(267, 59.38)];
            [bubblePath addCurveToPoint: CGPointMake(253.21, 39.69) controlPoint1: CGPointMake(267, 50.57) controlPoint2: CGPointMake(261.49, 42.7)];
            [bubblePath addCurveToPoint: CGPointMake(233.03, 38) controlPoint1: CGPointMake(247.88, 38) controlPoint2: CGPointMake(242.93, 38)];
            [bubblePath addLineToPoint: CGPointMake(168.56, 38)];
            [bubblePath addCurveToPoint: CGPointMake(0, 0) controlPoint1: CGPointMake(141.52, 31.9) controlPoint2: CGPointMake(0, 0)];
            [bubblePath addCurveToPoint: CGPointMake(64.31, 38) controlPoint1: CGPointMake(0, 0) controlPoint2: CGPointMake(53.99, 31.9)];
            [bubblePath addLineToPoint: CGPointMake(39.93, 38)];
            [bubblePath addCurveToPoint: CGPointMake(39.97, 38.01) controlPoint1: CGPointMake(39.98, 38) controlPoint2: CGPointMake(39.97, 38.01)];
            [bubblePath addCurveToPoint: CGPointMake(31.65, 39.47) controlPoint1: CGPointMake(41.07, 38) controlPoint2: CGPointMake(36.12, 38)];
            [bubblePath addLineToPoint: CGPointMake(30.79, 39.69)];
            [bubblePath addCurveToPoint: CGPointMake(17, 59.38) controlPoint1: CGPointMake(22.51, 42.7) controlPoint2: CGPointMake(17, 50.57)];
            [bubblePath addCurveToPoint: CGPointMake(17, 60.5) controlPoint1: CGPointMake(17, 60.5) controlPoint2: CGPointMake(17, 60.5)];
            [bubblePath addLineToPoint: CGPointMake(17, 61.63)];
            [bubblePath addCurveToPoint: CGPointMake(30.79, 81.31) controlPoint1: CGPointMake(17, 70.43) controlPoint2: CGPointMake(22.51, 78.3)];
            [bubblePath addLineToPoint: CGPointMake(46.52, 82.99)];
            [bubblePath addCurveToPoint: CGPointMake(50.97, 83) controlPoint1: CGPointMake(47.89, 83) controlPoint2: CGPointMake(49.37, 83)];
            [bubblePath addLineToPoint: CGPointMake(244.07, 83)];
            [bubblePath addLineToPoint: CGPointMake(244.03, 83)];
            [bubblePath closePath];
            
            [bubblePath applyTransform:CGAffineTransformMakeScale(width/250, 1.0)];
            bubblePath = [bubblePath bezierPathByReversingPath];//fixes jaggy stroke line on top, unable to figure out why.
            break;
        }
    }
    return bubblePath.CGPath;
}

@end
