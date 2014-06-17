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
- (void)drawSmallSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(319, 1)];
    [brickShapePath addLineToPoint: CGPointMake(319, 39.18)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 39.18)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69, 43) controlPoint1: CGPointMake(50.69, 40.85) controlPoint2: CGPointMake(50.69, 43)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 43)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91, 39.18) controlPoint1: CGPointMake(15.91, 43) controlPoint2: CGPointMake(15.91, 40.85)];
    [brickShapePath addLineToPoint: CGPointMake(1, 39.18)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 4.82)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 4.82)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 1)];
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
    [brickShapePath addCurveToPoint: CGPointMake(319, 66.11) controlPoint1: CGPointMake(319, 1) controlPoint2: CGPointMake(319, 66.11)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 66.11)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69, 70) controlPoint1: CGPointMake(50.69, 67.81) controlPoint2: CGPointMake(50.69, 70)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 70)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91, 66.11) controlPoint1: CGPointMake(15.91, 70) controlPoint2: CGPointMake(15.91, 67.81)];
    [brickShapePath addLineToPoint: CGPointMake(1, 66.11)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 4.89)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 4.89)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 1)];
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
    [brickShapePath addCurveToPoint: CGPointMake(319, 89.11) controlPoint1: CGPointMake(319, 1) controlPoint2: CGPointMake(319, 89.11)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 89.11)];
    [brickShapePath addCurveToPoint: CGPointMake(50.69, 94) controlPoint1: CGPointMake(50.69, 90.78) controlPoint2: CGPointMake(50.69, 94)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 94)];
    [brickShapePath addCurveToPoint: CGPointMake(15.91, 89.11) controlPoint1: CGPointMake(15.91, 94) controlPoint2: CGPointMake(15.91, 90.78)];
    [brickShapePath addLineToPoint: CGPointMake(1, 89.11)];
    [brickShapePath addLineToPoint: CGPointMake(1, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 1)];
    [brickShapePath addLineToPoint: CGPointMake(15.91, 4.92)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 4.92)];
    [brickShapePath addLineToPoint: CGPointMake(50.69, 1)];
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
    [bezier2Path moveToPoint: CGPointMake(183.63, 22.73)];
    [bezier2Path addLineToPoint: CGPointMake(319, 22.73)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 29.06) controlPoint1: CGPointMake(319, 22.73) controlPoint2: CGPointMake(319, 25.9)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 35.4) controlPoint1: CGPointMake(319, 32.23) controlPoint2: CGPointMake(319, 35.4)];
    [bezier2Path addCurveToPoint: CGPointMake(319, 57.13) controlPoint1: CGPointMake(319, 43.68) controlPoint2: CGPointMake(319, 57.13)];
    [bezier2Path addLineToPoint: CGPointMake(50.69, 57.13)];
    [bezier2Path addCurveToPoint: CGPointMake(50.69, 61) controlPoint1: CGPointMake(50.69, 58.82) controlPoint2: CGPointMake(50.69, 61)];
    [bezier2Path addLineToPoint: CGPointMake(15.91, 61)];
    [bezier2Path addCurveToPoint: CGPointMake(15.91, 57.13) controlPoint1: CGPointMake(15.91, 61) controlPoint2: CGPointMake(15.91, 58.82)];
    [bezier2Path addLineToPoint: CGPointMake(1, 57.13)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 43.69) controlPoint1: CGPointMake(1, 57.13) controlPoint2: CGPointMake(1, 50.5)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 35.4) controlPoint1: CGPointMake(1, 41.1) controlPoint2: CGPointMake(1, 38.29)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 32.6) controlPoint1: CGPointMake(1, 34.48) controlPoint2: CGPointMake(1, 33.54)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 29.06) controlPoint1: CGPointMake(1, 30.45) controlPoint2: CGPointMake(1, 29.06)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 22.73) controlPoint1: CGPointMake(1, 26.94) controlPoint2: CGPointMake(1, 24.81)];
    [bezier2Path addCurveToPoint: CGPointMake(1, 17.41) controlPoint1: CGPointMake(1, 20.91) controlPoint2: CGPointMake(1, 19.13)];
    [bezier2Path addCurveToPoint: CGPointMake(57.95, 2.03) controlPoint1: CGPointMake(12.07, 10) controlPoint2: CGPointMake(31.87, 4.3)];
    [bezier2Path addCurveToPoint: CGPointMake(183.63, 22.73) controlPoint1: CGPointMake(106.47, -2.19) controlPoint2: CGPointMake(159.9, 6.92)];
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
    [bezierPath moveToPoint: CGPointMake(86.23, 2)];
    [bezierPath addLineToPoint: CGPointMake(91.65, 2)];
    [bezierPath addCurveToPoint: CGPointMake(186.25, 21.57) controlPoint1: CGPointMake(129.41, 2.33) controlPoint2: CGPointMake(165.05, 9.57)];
    [bezierPath addLineToPoint: CGPointMake(319, 21.57)];
    [bezierPath addCurveToPoint: CGPointMake(319, 42.08) controlPoint1: CGPointMake(319, 21.57) controlPoint2: CGPointMake(319, 32.96)];
    [bezierPath addCurveToPoint: CGPointMake(319, 53.26) controlPoint1: CGPointMake(319, 48.18) controlPoint2: CGPointMake(319, 53.26)];
    [bezierPath addCurveToPoint: CGPointMake(319, 83.09) controlPoint1: CGPointMake(319, 65.41) controlPoint2: CGPointMake(319, 83.09)];
    [bezierPath addLineToPoint: CGPointMake(50.69, 83.09)];
    [bezierPath addCurveToPoint: CGPointMake(50.69, 87) controlPoint1: CGPointMake(50.69, 84.8) controlPoint2: CGPointMake(50.69, 87)];
    [bezierPath addLineToPoint: CGPointMake(15.91, 87)];
    [bezierPath addCurveToPoint: CGPointMake(15.91, 83.09) controlPoint1: CGPointMake(15.91, 87) controlPoint2: CGPointMake(15.91, 84.8)];
    [bezierPath addLineToPoint: CGPointMake(1, 83.09)];
    [bezierPath addCurveToPoint: CGPointMake(1, 57.82) controlPoint1: CGPointMake(1, 83.09) controlPoint2: CGPointMake(1, 69.38)];
    [bezierPath addCurveToPoint: CGPointMake(1, 16.98) controlPoint1: CGPointMake(1, 47.13) controlPoint2: CGPointMake(1, 29.55)];
    [bezierPath addCurveToPoint: CGPointMake(49.01, 4.64) controlPoint1: CGPointMake(13.55, 11.58) controlPoint2: CGPointMake(29.8, 7.26)];
    [bezierPath addCurveToPoint: CGPointMake(86.23, 2) controlPoint1: CGPointMake(61.3, 2.96) controlPoint2: CGPointMake(73.85, 2.11)];
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
