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

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawLargeRoundedControlBrickShapeWithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width;
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, (width + 42), (height + 13));


    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 13.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 13.5)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 56.5, CGRectGetMinY(frame) + 0.83) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 13.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 0.83)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 119.5, CGRectGetMinY(frame) + 13.03) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 101.5, CGRectGetMinY(frame) + 0.83) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 119.5, CGRectGetMinY(frame) + 13.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 1.66, CGRectGetMinY(frame) + 13.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 1.66, CGRectGetMaxY(frame) - 4.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMaxY(frame) - 4.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMaxY(frame) - 0.53)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMaxY(frame) - 0.53)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMaxY(frame) - 4.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 4.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 13.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];


    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.48864 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.48864 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];


    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.57955 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.57955 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier3Path fill];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];


    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.67045 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.67045 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier4Path fill];
    [strokeColor setStroke];
    bezier4Path.lineWidth = 1;
    [bezier4Path stroke];
}

+ (void)drawSquareBrickShapeWithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width;
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, height);


    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 0.46)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 4.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 37.5, CGRectGetMinY(frame) + 4.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 37.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.66, CGRectGetMinY(frame) + 0.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.66, CGRectGetMaxY(frame) - 4.57)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMaxY(frame) - 4.57)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMaxY(frame) - 4.57)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 4.48)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];


    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.39394 * CGRectGetHeight(frame))];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.39394 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];


    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.48692 * CGRectGetHeight(frame))];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.48692 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier3Path fill];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];


    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.57989 * CGRectGetHeight(frame))];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 0.57989 * CGRectGetHeight(frame))];
    [fillColor setFill];
    [bezier4Path fill];
    [strokeColor setStroke];
    bezier4Path.lineWidth = 1;
    [bezier4Path stroke];
}

@end
