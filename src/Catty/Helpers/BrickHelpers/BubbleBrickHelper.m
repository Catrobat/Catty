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

@interface BubbleBrickHelper()

@property (nonatomic) AVCaptureSession* session;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic) UIView* camView;

@end


@implementation BubbleBrickHelper

+ (void)addBubbleToSpriteNode:(CBSpriteNode*)spriteNode withText: (NSString*)text andType:(CBBubbleType)type
{
    [self addBubbleToSpriteNode:spriteNode withText:text andType:type forDuration:-1];
}


+ (void)addBubbleToSpriteNode:(CBSpriteNode*)spriteNode withText: (NSString*)text andType:(CBBubbleType)type forDuration:(double)duration
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
    sayBubble.lineWidth = 3.0;
    sayBubble.strokeColor = [UIColor blackColor];
    
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
            bubblePath = [[UIBezierPath alloc] init];
            //Bubble's bezier path with width = 1
            [bubblePath moveToPoint: CGPointMake(0.96, 99.03)];
            [bubblePath addLineToPoint: CGPointMake(0.97, 98.89)];
            [bubblePath addCurveToPoint: CGPointMake(1, 90.67) controlPoint1: CGPointMake(0.98, 97.5) controlPoint2: CGPointMake(0.99, 94.49)];
            [bubblePath addCurveToPoint: CGPointMake(1, 77.41) controlPoint1: CGPointMake(1, 87.17) controlPoint2: CGPointMake(1, 83.91)];
            [bubblePath addLineToPoint: CGPointMake(1, 73.33)];
            [bubblePath addCurveToPoint: CGPointMake(1, 60.64) controlPoint1: CGPointMake(1, 66.82) controlPoint2: CGPointMake(1, 63.57)];
            [bubblePath addLineToPoint: CGPointMake(1, 60.07)];
            [bubblePath addCurveToPoint: CGPointMake(0.97, 51.85) controlPoint1: CGPointMake(0.99, 56.25) controlPoint2: CGPointMake(0.98, 53.24)];
            [bubblePath addCurveToPoint: CGPointMake(0.92, 50.74) controlPoint1: CGPointMake(0.95, 50.74) controlPoint2: CGPointMake(0.94, 50.74)];
            [bubblePath addLineToPoint: CGPointMake(0.58, 50.74)];
            [bubblePath addCurveToPoint: CGPointMake(0, 0.11) controlPoint1: CGPointMake(0.52, 45.64) controlPoint2: CGPointMake(0.03, 2.59)];
            [bubblePath addCurveToPoint: CGPointMake(0, 0) controlPoint1: CGPointMake(0, 0.04) controlPoint2: CGPointMake(0, 0.01)];
            [bubblePath addCurveToPoint: CGPointMake(0.21, 50.74) controlPoint1: CGPointMake(0, 0.03) controlPoint2: CGPointMake(0.21, 50.74)];
            [bubblePath addLineToPoint: CGPointMake(0.18, 50.74)];
            [bubblePath addCurveToPoint: CGPointMake(0.14, 51.71) controlPoint1: CGPointMake(0.16, 50.74) controlPoint2: CGPointMake(0.15, 50.74)];
            [bubblePath addLineToPoint: CGPointMake(0.14, 51.85)];
            [bubblePath addCurveToPoint: CGPointMake(0.11, 60.07) controlPoint1: CGPointMake(0.12, 53.24) controlPoint2: CGPointMake(0.11, 56.25)];
            [bubblePath addCurveToPoint: CGPointMake(0.1, 73.33) controlPoint1: CGPointMake(0.1, 63.57) controlPoint2: CGPointMake(0.1, 66.82)];
            [bubblePath addLineToPoint: CGPointMake(0.1, 77.41)];
            [bubblePath addCurveToPoint: CGPointMake(0.11, 90.1) controlPoint1: CGPointMake(0.1, 83.91) controlPoint2: CGPointMake(0.1, 87.17)];
            [bubblePath addLineToPoint: CGPointMake(0.11, 90.67)];
            [bubblePath addCurveToPoint: CGPointMake(0.14, 98.89) controlPoint1: CGPointMake(0.11, 94.49) controlPoint2: CGPointMake(0.12, 97.5)];
            [bubblePath addCurveToPoint: CGPointMake(0.18, 100) controlPoint1: CGPointMake(0.15, 100) controlPoint2: CGPointMake(0.16, 100)];
            [bubblePath addLineToPoint: CGPointMake(0.92, 100)];
            [bubblePath addCurveToPoint: CGPointMake(0.96, 99.03) controlPoint1: CGPointMake(0.94, 100) controlPoint2: CGPointMake(0.95, 100)];
            [bubblePath closePath];
            //Since width is 1, scaling along x times width.
            [bubblePath applyTransform:CGAffineTransformMakeScale(width, 1.0)];
            break;
        }
    }
    return bubblePath.CGPath;
}

@end
