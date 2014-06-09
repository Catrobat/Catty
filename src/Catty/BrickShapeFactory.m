/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "BrickShapeFactory.h"

@implementation BrickShapeFactory

+ (instancetype)sharedBrickShapeFactory
{
    static BrickShapeFactory *_sharedCattyBrickShapeFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedCattyBrickShapeFactory = [BrickShapeFactory new]; });
    return _sharedCattyBrickShapeFactory;
}

// shapes created with www.paintcodeapp.com
+ (void)drawSmallSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(50.85, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(639, 1) controlPoint1: CGPointMake(50.84, 1) controlPoint2: CGPointMake(639, 1)];
    [brickShapePath addLineToPoint: CGPointMake(639, 38.71)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 38.71)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 43) controlPoint1: CGPointMake(50.84, 40.49) controlPoint2: CGPointMake(50.84, 43)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 43)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 38.71) controlPoint1: CGPointMake(15.95, 43) controlPoint2: CGPointMake(15.95, 40.49)];
    [brickShapePath addLineToPoint: CGPointMake(1, 38.71)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 5.29) controlPoint1: CGPointMake(15.95, 2.77) controlPoint2: CGPointMake(15.95, 5.29)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 5.29)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 1) controlPoint1: CGPointMake(50.84, 5.29) controlPoint2: CGPointMake(50.84, 2.77)];
    [brickShapePath addLineToPoint: CGPointMake(50.85, 1)];
    [brickShapePath closePath];
    [fillColor setFill];
    [brickShapePath fill];
    [strokeColor setStroke];
    brickShapePath.lineWidth = 1;
    [brickShapePath stroke];
    
    //// grip_line1 Drawing
    UIBezierPath* grip_line1Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 21, 35, 1)];
    [strokeColor setFill];
    [grip_line1Path fill];
    
    //// grip_line2 Drawing
    UIBezierPath* grip_line2Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 15, 35, 1)];
    [strokeColor setFill];
    [grip_line2Path fill];
    
    //// grip_line3 Drawing
    UIBezierPath* grip_line3Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 27, 35, 1)];
    [strokeColor setFill];
    [grip_line3Path fill];
    
}

+ (void)drawMediumSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(50.85, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(639, 1) controlPoint1: CGPointMake(50.84, 1) controlPoint2: CGPointMake(639, 1)];
    [brickShapePath addLineToPoint: CGPointMake(639, 65.46)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 65.46)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 70) controlPoint1: CGPointMake(50.84, 67.34) controlPoint2: CGPointMake(50.84, 70)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 70)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 65.46) controlPoint1: CGPointMake(15.95, 70) controlPoint2: CGPointMake(15.95, 67.34)];
    [brickShapePath addLineToPoint: CGPointMake(1, 65.46)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 5.54) controlPoint1: CGPointMake(15.95, 2.88) controlPoint2: CGPointMake(15.95, 5.54)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 5.54)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 1) controlPoint1: CGPointMake(50.84, 5.54) controlPoint2: CGPointMake(50.84, 2.88)];
    [brickShapePath addLineToPoint: CGPointMake(50.85, 1)];
    [brickShapePath closePath];
    [fillColor setFill];
    [brickShapePath fill];
    [strokeColor setStroke];
    brickShapePath.lineWidth = 1;
    [brickShapePath stroke];

    
    //// grip_line1 Drawing
    UIBezierPath* grip_line1Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 35.5, 35, 1)];
    [strokeColor setFill];
    [grip_line1Path fill];
    
    
    //// grip_line2 Drawing
    UIBezierPath* grip_line2Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 41.5, 35, 1)];
    [strokeColor setFill];
    [grip_line2Path fill];
    
    
    //// grip_line3 Drawing
    UIBezierPath* grip_line3Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 29.5, 35, 1)];
    [strokeColor setFill];
    [grip_line3Path fill];
    
    
    //// grip_line4 Drawing
    UIBezierPath* grip_line4Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 23.5, 35, 1)];
    [strokeColor setFill];
    [grip_line4Path fill];
    
    //// grip_line5 Drawing
    UIBezierPath* grip_line5Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 47.5, 35, 1)];
    [strokeColor setFill];
    [grip_line5Path fill];
}

+ (void)drawLargeSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(50.85, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(639, 1) controlPoint1: CGPointMake(50.84, 1) controlPoint2: CGPointMake(639, 1)];
    [brickShapePath addLineToPoint: CGPointMake(639, 88.35)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 88.35)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 93) controlPoint1: CGPointMake(50.84, 90.28) controlPoint2: CGPointMake(50.84, 93)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 93)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 88.35) controlPoint1: CGPointMake(15.95, 93) controlPoint2: CGPointMake(15.95, 90.28)];
    [brickShapePath addLineToPoint: CGPointMake(1, 88.35)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.95, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(15.95, 5.65) controlPoint1: CGPointMake(15.95, 2.92) controlPoint2: CGPointMake(15.95, 5.65)];
    [brickShapePath addLineToPoint: CGPointMake(50.84, 5.65)];
    [brickShapePath addCurveToPoint: CGPointMake(50.84, 1) controlPoint1: CGPointMake(50.84, 5.65) controlPoint2: CGPointMake(50.84, 2.92)];
    [brickShapePath addLineToPoint: CGPointMake(50.85, 1)];
    [brickShapePath closePath];
    [fillColor setFill];
    [brickShapePath fill];
    [strokeColor setStroke];
    brickShapePath.lineWidth = 1;
    [brickShapePath stroke];
    
    
    //// grip_line1 Drawing
    UIBezierPath* grip_line1Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 47.5, 35, 1)];
    [strokeColor setFill];
    [grip_line1Path fill];
    
    
    //// grip_line2 Drawing
    UIBezierPath* grip_line2Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 53.5, 35, 1)];
    [strokeColor setFill];
    [grip_line2Path fill];
    
    
    //// grip_line3 Drawing
    UIBezierPath* grip_line3Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 41.5, 35, 1)];
    [strokeColor setFill];
    [grip_line3Path fill];
    
    
    //// grip_line4 Drawing
    UIBezierPath* grip_line4Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 35.5, 35, 1)];
    [strokeColor setFill];
    [grip_line4Path fill];
    
    UIBezierPath* grip_line5Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 29.5, 35, 1)];
    [strokeColor setFill];
    [grip_line5Path fill];
    
    UIBezierPath* grip_line6Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 59.5, 35, 1)];
    [strokeColor setFill];
    [grip_line6Path fill];
    
    UIBezierPath* grip_line7Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 65.5, 35, 1)];
    [strokeColor setFill];
    [grip_line7Path fill];
}

@end
