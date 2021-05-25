/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#define kMarginBetweenLines 4.8
#define kLineWidth 1

@implementation BrickShapeFactory

#pragma mark Drawing Methods

+ (void)drawRoundedControlBrickShapeWithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width brickShape: (kBrickShapeType)shapeType
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, (height + marginBottomRoundedBrick - 8));

    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 6.1, 20, 10.6);


    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.21952 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.21952 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5)];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34865 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.34750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.55250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34865 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.66, CGRectGetMinY(frame) + 0.34865 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 0.66, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.21952 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = kLineWidth;
    [bezierPath stroke];

    [self drawThreeLeftLinesInFrame:&frame fillColor:fillColor strokeColor:strokeColor brickShape:shapeType];

    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
        [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath closePath];
        rectanglePath.lineCapStyle = kCGLineCapRound;

        rectanglePath.lineJoinStyle = kCGLineJoinRound;

        [fillColor setFill];
        [rectanglePath fill];
        [strokeColor setStroke];
        rectanglePath.lineWidth = kLineWidth;
        [rectanglePath stroke];


        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(group), CGRectGetMinY(group), 20, 5)];
        [fillColor setFill];
        [rectangle2Path fill];
    }
}

+ (void)drawSquareBrickShapeWithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, (height + marginBottomSquaredBrick - 0.5));

    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 6.1, 20, 10.6);


    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 0.46)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 5.44)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 5.44)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + 0.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.62, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.56, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = kLineWidth;
    [bezierPath stroke];


    [self drawThreeLeftLinesInFrame:&frame fillColor:fillColor strokeColor:strokeColor brickShape:kBrickShapeSquareSmall];


    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
        [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath closePath];
        rectanglePath.lineCapStyle = kCGLineCapRound;

        rectanglePath.lineJoinStyle = kCGLineJoinRound;

        [fillColor setFill];
        [rectanglePath fill];
        [strokeColor setStroke];
        rectanglePath.lineWidth = kLineWidth;
        [rectanglePath stroke];


        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(group), CGRectGetMinY(group), 20, 5)];
        [fillColor setFill];
        [rectangle2Path fill];
    }
}

+ (void)drawEndForeverLoopShape1WithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, (height - 0.5));


    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 0.46)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 5.44)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 5.44)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + 0.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.62, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.56, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = kLineWidth;
    [bezierPath stroke];


    [self drawThreeLeftLinesInFrame:&frame fillColor:fillColor strokeColor:strokeColor brickShape:kBrickShapeSquareSmall];
}

+ (void)drawEndForeverLoopShape2WithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, (height - 0.5));


    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 0.46)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 32.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + 0.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.62, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.56, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = kLineWidth;
    [bezierPath stroke];


    [self drawThreeLeftLinesInFrame:&frame fillColor:fillColor strokeColor:strokeColor brickShape:kBrickShapeSquareSmall];
}

+ (void)drawEndForeverLoopShape3WithFillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor height: (CGFloat)height width: (CGFloat)width
{

    //// Frames
    CGRect frame = CGRectMake(0, 0, width, (height - 0.5));

    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 6.1, 20, 10.6);


    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 0.46)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + 0.03)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.62, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.56, CGRectGetMaxY(frame) - 0.59)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 0.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;

    bezierPath.lineJoinStyle = kCGLineJoinRound;

    [fillColor setFill];
    [bezierPath fill];
    [strokeColor setStroke];
    bezierPath.lineWidth = kLineWidth;
    [bezierPath stroke];


    [self drawThreeLeftLinesInFrame:&frame fillColor:fillColor strokeColor:strokeColor brickShape:kBrickShapeSquareSmall];

    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
        [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 10.6)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 19.2, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 1.5)];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.8, CGRectGetMinY(group) + 10.6)];
        [rectanglePath closePath];
        rectanglePath.lineCapStyle = kCGLineCapRound;

        rectanglePath.lineJoinStyle = kCGLineJoinRound;

        [fillColor setFill];
        [rectanglePath fill];
        [strokeColor setStroke];
        rectanglePath.lineWidth = kLineWidth;
        [rectanglePath stroke];


        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(group), CGRectGetMinY(group), 20, 5)];
        [fillColor setFill];
        [rectangle2Path fill];
    }
}

+ (void)drawThreeLeftLinesInFrame: (CGRect*)frame fillColor: (UIColor*)fillColor strokeColor: (UIColor*)strokeColor brickShape: (kBrickShapeType) shapeType
{
    CGFloat offsetTop = 0.0f;
    CGFloat height = CGRectGetHeight(*frame);
    
    if (shapeType == kBrickShapeSquareSmall) {
        offsetTop = kBrickShapeNormalInlineViewOffsetY;
    } else if (shapeType == kBrickShapeRoundedSmall) {
        offsetTop = kBrickShapeRoundedSmallInlineViewOffsetY;
    } else if (shapeType == kBrickShapeRoundedBig) {
        offsetTop = kBrickShapeRoundedBigInlineViewOffsetY;
    }
    
    CGFloat yPositionFirstLine = CGRectGetMinY(*frame) + offsetTop + (height - offsetTop) / 2.0f - kMarginBetweenLines - kLineWidth;
    CGFloat yPositionSecondLine = yPositionFirstLine + kMarginBetweenLines;
    CGFloat yPositionThirdLine = yPositionSecondLine + kMarginBetweenLines;
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(*frame) + 16, yPositionFirstLine)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(*frame) + 34, yPositionFirstLine)];
    [fillColor setFill];
    [bezier2Path fill];
    [strokeColor setStroke];
    bezier2Path.lineWidth = kLineWidth;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(*frame) + 16, yPositionSecondLine)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(*frame) + 34, yPositionSecondLine)];
    [fillColor setFill];
    [bezier3Path fill];
    [strokeColor setStroke];
    bezier3Path.lineWidth = kLineWidth;
    [bezier3Path stroke];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(*frame) + 16, yPositionThirdLine)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(*frame) + 34, yPositionThirdLine)];
    [fillColor setFill];
    [bezier4Path fill];
    [strokeColor setStroke];
    bezier4Path.lineWidth = kLineWidth;
    [bezier4Path stroke];
}

@end
