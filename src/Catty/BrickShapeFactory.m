//
//  BrickShapeFactory.m
//  Catty
//
//  Created by luca on 09/06/14.
//
//

#import "BrickShapeFactory.h"

@implementation BrickShapeFactory

+ (void)drawSmallSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(50, 0)];
    [brickShapePath addCurveToPoint: CGPointMake(640, 0) controlPoint1: CGPointMake(50, -0) controlPoint2: CGPointMake(640, 0)];
    [brickShapePath addLineToPoint: CGPointMake(640, 39.51)];
    [brickShapePath addLineToPoint: CGPointMake(50, 39.51)];
    [brickShapePath addCurveToPoint: CGPointMake(50, 44) controlPoint1: CGPointMake(50, 41.37) controlPoint2: CGPointMake(50, 44)];
    [brickShapePath addLineToPoint: CGPointMake(15, 44)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 39.51) controlPoint1: CGPointMake(15, 44) controlPoint2: CGPointMake(15, 41.37)];
    [brickShapePath addLineToPoint: CGPointMake(0, 39.51)];
    [brickShapePath addLineToPoint: CGPointMake(0, 0)];
    [brickShapePath addLineToPoint: CGPointMake(15, 0)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 4.49) controlPoint1: CGPointMake(15, 1.86) controlPoint2: CGPointMake(15, 4.49)];
    [brickShapePath addLineToPoint: CGPointMake(50, 4.49)];
    [brickShapePath addCurveToPoint: CGPointMake(50, 0) controlPoint1: CGPointMake(50, 4.49) controlPoint2: CGPointMake(50, 1.86)];
    [brickShapePath addLineToPoint: CGPointMake(50, 0)];
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
    [brickShapePath moveToPoint: CGPointMake(50, -0)];
    [brickShapePath addCurveToPoint: CGPointMake(640, -0) controlPoint1: CGPointMake(50, -0) controlPoint2: CGPointMake(640, -0)];
    [brickShapePath addLineToPoint: CGPointMake(640, 66.33)];
    [brickShapePath addLineToPoint: CGPointMake(50, 66.33)];
    [brickShapePath addCurveToPoint: CGPointMake(50, 71) controlPoint1: CGPointMake(50, 68.26) controlPoint2: CGPointMake(50, 71)];
    [brickShapePath addLineToPoint: CGPointMake(15, 71)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 66.33) controlPoint1: CGPointMake(15, 71) controlPoint2: CGPointMake(15, 68.26)];
    [brickShapePath addLineToPoint: CGPointMake(0, 66.33)];
    [brickShapePath addLineToPoint: CGPointMake(0, -0)];
    [brickShapePath addLineToPoint: CGPointMake(15, -0)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 4.67) controlPoint1: CGPointMake(15, 1.93) controlPoint2: CGPointMake(15, 4.67)];
    [brickShapePath addLineToPoint: CGPointMake(50, 4.67)];
    [brickShapePath addCurveToPoint: CGPointMake(50, -0) controlPoint1: CGPointMake(50, 4.67) controlPoint2: CGPointMake(50, 1.93)];
    [brickShapePath addLineToPoint: CGPointMake(50, -0)];
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
}

+ (void)drawLargeSquareBrickShape:(UIColor *)strokeColor fillColor:(UIColor *)fillColor
{
    // brickShape Drawing
    UIBezierPath* brickShapePath = UIBezierPath.bezierPath;
    [brickShapePath moveToPoint: CGPointMake(50, 0)];
    [brickShapePath addCurveToPoint: CGPointMake(640, 0) controlPoint1: CGPointMake(50, 0) controlPoint2: CGPointMake(640, 0)];
    [brickShapePath addLineToPoint: CGPointMake(640, 89.25)];
    [brickShapePath addLineToPoint: CGPointMake(50, 89.25)];
    [brickShapePath addCurveToPoint: CGPointMake(50, 94) controlPoint1: CGPointMake(50, 91.22) controlPoint2: CGPointMake(50, 94)];
    [brickShapePath addLineToPoint: CGPointMake(15, 94)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 89.25) controlPoint1: CGPointMake(15, 94) controlPoint2: CGPointMake(15, 91.22)];
    [brickShapePath addLineToPoint: CGPointMake(0, 89.25)];
    [brickShapePath addLineToPoint: CGPointMake(0, 0)];
    [brickShapePath addLineToPoint: CGPointMake(15, 0)];
    [brickShapePath addCurveToPoint: CGPointMake(15, 4.75) controlPoint1: CGPointMake(15, 1.96) controlPoint2: CGPointMake(15, 4.75)];
    [brickShapePath addLineToPoint: CGPointMake(50, 4.75)];
    [brickShapePath addCurveToPoint: CGPointMake(50, 0) controlPoint1: CGPointMake(50, 4.75) controlPoint2: CGPointMake(50, 1.96)];
    [brickShapePath addLineToPoint: CGPointMake(50, 0)];
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
}

@end
