//
//  YKImageCropperOverlayView.m
//  Copyright (c) 2013 yuyak. All rights reserved.
//

#import "YKImageCropperOverlayView.h"

#define SIZE 30.0f

@implementation YKImageCropperOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGRect)edgeRect {
    return CGRectMake(CGRectGetMinX(self.clearRect) - SIZE / 2,
                      CGRectGetMinY(self.clearRect) - SIZE / 2,
                      CGRectGetWidth(self.clearRect) + SIZE,
                      CGRectGetHeight(self.clearRect) + SIZE);
}

- (CGRect)topLeftCorner {
    return CGRectMake(CGRectGetMinX(self.clearRect) - SIZE / 2,
                      CGRectGetMinY(self.clearRect) - SIZE / 2,
                      SIZE, SIZE);
}

- (CGRect)topRightCorner {
    return CGRectMake(CGRectGetMaxX(self.clearRect) - SIZE / 2,
                      CGRectGetMinY(self.clearRect) - SIZE / 2,
                      SIZE, SIZE);
}

- (CGRect)bottomLeftCorner {
    return CGRectMake(CGRectGetMinX(self.clearRect) - SIZE / 2,
                      CGRectGetMaxY(self.clearRect) - SIZE / 2,
                      SIZE, SIZE);
}

- (CGRect)bottomRightCorner {
    return CGRectMake(CGRectGetMaxX(self.clearRect) - SIZE / 2,
                      CGRectGetMaxY(self.clearRect) - SIZE / 2,
                      SIZE, SIZE);
}

- (CGRect)topEdgeRect {
    return CGRectMake(CGRectGetMinX([self edgeRect]) + SIZE,
                      CGRectGetMinY([self edgeRect]),
                      CGRectGetWidth([self edgeRect]) - SIZE * 2, SIZE);
}

- (CGRect)rightEdgeRect {
    return CGRectMake(CGRectGetMaxX([self edgeRect]) - SIZE,
                      CGRectGetMinY([self edgeRect]) + SIZE,
                      SIZE, CGRectGetHeight([self edgeRect]) - SIZE * 2);
}

- (CGRect)bottomEdgeRect {
    return CGRectMake(CGRectGetMinX([self edgeRect]) + SIZE,
                      CGRectGetMaxY([self edgeRect]) - SIZE,
                      CGRectGetWidth([self edgeRect]) - SIZE * 2, SIZE);
}

- (CGRect)leftEdgeRect {
    return CGRectMake(CGRectGetMinX([self edgeRect]),
                      CGRectGetMinY([self edgeRect]) + SIZE,
                      SIZE, CGRectGetHeight([self edgeRect]) - SIZE * 2);
}

- (BOOL)isEdgeContainsPoint:(CGPoint)point {
    return CGRectContainsPoint([self topEdgeRect], point)
        || CGRectContainsPoint([self rightEdgeRect], point)
        || CGRectContainsPoint([self bottomEdgeRect], point)
        || CGRectContainsPoint([self leftEdgeRect], point);
}

- (BOOL)isCornerContainsPoint:(CGPoint)point {
    return CGRectContainsPoint([self topLeftCorner], point)
            || CGRectContainsPoint([self topRightCorner], point)
            || CGRectContainsPoint([self bottomLeftCorner], point)
            || CGRectContainsPoint([self bottomRightCorner], point);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(c, YES);

    // Fill black
    CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:0 alpha:0.7].CGColor);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGContextAddRect(c, CGRectMake(0, 0, screenRect.size.width, screenRect.size.height));
    CGContextFillPath(c);

    // Clear inside
    CGContextClearRect(c, self.clearRect);
    CGContextFillPath(c);

    // Draw corners
    CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:1 alpha:0.5].CGColor);

    CGContextSaveGState(c);
    CGContextSetShouldAntialias(c, NO);

    CGFloat margin = SIZE / 4;

    // Clear outside
    CGRect clip = CGRectOffset(self.clearRect, -margin * 0.4f, -margin * 0.4f);
    clip.size.width += margin * 0.8f, clip.size.height += margin * 0.8f;
    CGContextClipToRect(c, clip);

    CGContextAddRect(c, self.topLeftCorner);
    CGContextAddRect(c, self.topRightCorner);
    CGContextAddRect(c, self.bottomLeftCorner);
    CGContextAddRect(c, self.bottomRightCorner);
    CGContextFillPath(c);

    // Clear inside
    margin = SIZE / 8;
    clip = CGRectOffset(self.clearRect, margin, margin);
    clip.size.width -= margin * 2, clip.size.height -= margin * 2;
    CGContextClearRect(c, clip);
    CGContextRestoreGState(c);

    // Grid
    CGContextSetStrokeColorWithColor(c, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(c, 1);

    CGContextAddRect(c, self.clearRect);

    CGPoint from, to;

    // Vetical lines
    for (int i = 1; i <= 2; i++) {
        from = CGPointMake(self.clearRect.origin.x + self.clearRect.size.width / 3.0f * i, self.clearRect.origin.y);
        to = CGPointMake(from.x, CGRectGetMaxY(self.clearRect));
        CGContextMoveToPoint(c, from.x, from.y);
        CGContextAddLineToPoint(c, to.x, to.y);
    }

    // Horizontal Lines
    for (int i = 1; i <= 2; i++) {
        from = CGPointMake(self.clearRect.origin.x, self.clearRect.origin.y + self.clearRect.size.height / 3.0f * i);
        to = CGPointMake(CGRectGetMaxX(self.clearRect), from.y);
        CGContextMoveToPoint(c, from.x, from.y);
        CGContextAddLineToPoint(c, to.x, to.y);
    }

    CGContextStrokePath(c);
}

@end
