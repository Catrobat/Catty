/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
- (void)drawSmallSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(319, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 39.18f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 39.18f)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69f, 43) controlPoint1: CGPointMake(50.69f, 40.85f) controlPoint2: CGPointMake(50.69f, 43)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 43)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91f, 39.18f) controlPoint1: CGPointMake(15.91f, 43) controlPoint2: CGPointMake(15.91f, 40.85f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 39.18f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 4.82f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 4.82f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 1)];
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

- (void)drawMediumSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(319, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(319, 66.11f) controlPoint1: CGPointMake(319, 1) controlPoint2: CGPointMake(319, 66.11f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 66.11f)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69f, 70) controlPoint1: CGPointMake(50.69f, 67.81f) controlPoint2: CGPointMake(50.69f, 70)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 70)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91f, 66.11f) controlPoint1: CGPointMake(15.91f, 70) controlPoint2: CGPointMake(15.91f, 67.81f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 66.11f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 4.89f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 4.89f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 1)];
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

- (void)drawLargeSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(319, 1)];
    [brickShapePath addCurveToPoint: CGPointMake(319, 89.11f) controlPoint1: CGPointMake(319, 1) controlPoint2: CGPointMake(319, 89.11f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 89.11f)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69f, 94) controlPoint1: CGPointMake(50.69f, 90.78f) controlPoint2: CGPointMake(50.69f, 94)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 94)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91f, 89.11f) controlPoint1: CGPointMake(15.91f, 94) controlPoint2: CGPointMake(15.91f, 90.78f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 89.11f)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91f, 4.92f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 4.92f)];
    [brickShapePath addLineToPoint: CGPointMake(50.69f, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 1)];
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

- (void)drawSmallRoundedControlBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(183.63f, 22.73f)];
    [bezier2Path addLineToPoint: CGPointMake(319, 22.73f)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 29.06f) controlPoint1: CGPointMake(319, 22.73f) controlPoint2: CGPointMake(319, 25.9f)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 35.4f) controlPoint1: CGPointMake(319, 32.23f) controlPoint2: CGPointMake(319, 35.4f)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 57.13f) controlPoint1: CGPointMake(319, 43.68f) controlPoint2: CGPointMake(319, 57.13f)];
    [bezier2Path addLineToPoint: CGPointMake(50.69f, 57.13f)];
    [bezier2Path addCurveToPoint: CGPointMake(50.69f, 61) controlPoint1: CGPointMake(50.69f, 58.82f) controlPoint2: CGPointMake(50.69f, 61)];
    [bezier2Path addLineToPoint: CGPointMake(15.91f, 61)];
    [bezier2Path addCurveToPoint: CGPointMake(15.91f, 57.13f) controlPoint1: CGPointMake(15.91f, 61) controlPoint2: CGPointMake(15.91f, 58.82f)];
    [bezier2Path addLineToPoint: CGPointMake(1, 57.13f)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 43.69f) controlPoint1: CGPointMake(1, 57.13f) controlPoint2: CGPointMake(1, 50.5)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 35.4f) controlPoint1: CGPointMake(1, 41.1f) controlPoint2: CGPointMake(1, 38.29f)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 32.6f) controlPoint1: CGPointMake(1, 34.48f) controlPoint2: CGPointMake(1, 33.54f)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 29.06f) controlPoint1: CGPointMake(1, 30.45f) controlPoint2: CGPointMake(1, 29.06f)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 22.73f) controlPoint1: CGPointMake(1, 26.94f) controlPoint2: CGPointMake(1, 24.81f)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 17.41f) controlPoint1: CGPointMake(1, 20.91f) controlPoint2: CGPointMake(1, 19.13f)];
    [bezier2Path addCurveToPoint: CGPointMake(57.95f, 2.03f) controlPoint1: CGPointMake(12.07f, 10) controlPoint2: CGPointMake(31.87f, 4.3f)];
    [bezier2Path addCurveToPoint: CGPointMake(183.63f, 22.73f) controlPoint1: CGPointMake(106.47f, -2.19f) controlPoint2: CGPointMake(159.9f, 6.92f)];
    [bezier2Path closePath];
    [fillColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    //// grip_line1 Drawing
    UIBezierPath* grip_line1Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 36, 35, 1)];
    [strokeColor setFill];
    [grip_line1Path fill];
    
    //// grip_line2 Drawing
    UIBezierPath* grip_line2Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 42, 35, 1)];
    [strokeColor setFill];
    [grip_line2Path fill];
    
    
    //// grip_line3 Drawing
    UIBezierPath* grip_line3Path = [UIBezierPath bezierPathWithRect: CGRectMake(15, 30, 35, 1)];
    [strokeColor setFill];
    [grip_line3Path fill];
}

- (void)drawLargeRoundedControlBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(86.23f, 2)];
    [bezierPath addLineToPoint: CGPointMake(91.65f, 2)];
    [bezierPath addCurveToPoint: CGPointMake(186.25f, 21.57f) controlPoint1: CGPointMake(129.41f, 2.33f) controlPoint2: CGPointMake(165.05f, 9.57f)];
    [bezierPath addLineToPoint: CGPointMake(319, 21.57f)];
    [bezierPath addCurveToPoint: CGPointMake(319, 42.08f) controlPoint1: CGPointMake(319, 21.57f) controlPoint2: CGPointMake(319, 32.96f)];
    [bezierPath addCurveToPoint: CGPointMake(319, 53.26f) controlPoint1: CGPointMake(319, 48.18f) controlPoint2: CGPointMake(319, 53.26f)];
    [bezierPath addCurveToPoint: CGPointMake(319, 83.09f) controlPoint1: CGPointMake(319, 65.41f) controlPoint2: CGPointMake(319, 83.09f)];
    [bezierPath addLineToPoint: CGPointMake(50.69f, 83.09f)];
    [bezierPath addCurveToPoint: CGPointMake(50.69f, 87) controlPoint1: CGPointMake(50.69f, 84.8f) controlPoint2: CGPointMake(50.69f, 87)];
    [bezierPath addLineToPoint: CGPointMake(15.91f, 87)];
    [bezierPath addCurveToPoint: CGPointMake(15.91f, 83.09f) controlPoint1: CGPointMake(15.91f, 87) controlPoint2: CGPointMake(15.91f, 84.8f)];
    [bezierPath addLineToPoint: CGPointMake(1, 83.09f)];
    [bezierPath addCurveToPoint: CGPointMake(1, 57.82f) controlPoint1: CGPointMake(1, 83.09f) controlPoint2: CGPointMake(1, 69.38f)];
    [bezierPath addCurveToPoint: CGPointMake(1, 16.98f) controlPoint1: CGPointMake(1, 47.13f) controlPoint2: CGPointMake(1, 29.55f)];
    [bezierPath addCurveToPoint: CGPointMake(49.01f, 4.64f) controlPoint1: CGPointMake(13.55f, 11.58f) controlPoint2: CGPointMake(29.8f, 7.26f)];
    [bezierPath addCurveToPoint: CGPointMake(86.23f, 2) controlPoint1: CGPointMake(61.3f, 2.96f) controlPoint2: CGPointMake(73.85f, 2.11f)];
    [bezierPath closePath];
    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Rectangle Drawing
    UIBezierPath* grip_line1 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 44.5, 35, 1)];
    [strokeColor setFill];
    [grip_line1 fill];
    
    UIBezierPath* grip_line2 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 51.5, 35, 1)];
    [strokeColor setFill];
    [grip_line2 fill];
    
    UIBezierPath* grip_line3 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 57.5, 35, 1)];
    [strokeColor setFill];
    [grip_line3 fill];
    
    UIBezierPath* grip_line4 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 38.5, 35, 1)];
    [strokeColor setFill];
    [grip_line4 fill];
    
    UIBezierPath* grip_line5 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 32.5, 35, 1)];
    [strokeColor setFill];
    [grip_line5 fill];
    
    UIBezierPath* grip_line6 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 63.5, 35, 1)];
    [strokeColor setFill];
    [grip_line6 fill];
    
    UIBezierPath* grip_line7 = [UIBezierPath bezierPathWithRect: CGRectMake(15, 69.5, 35, 1)];
    [strokeColor setFill];
    [grip_line7 fill];
}

@end
