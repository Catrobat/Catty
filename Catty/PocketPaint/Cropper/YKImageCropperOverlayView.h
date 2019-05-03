//
//  YKImageCropperOverlayView.h
//  Copyright (c) 2013 yuyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKImageCropperOverlayView : UIView

@property (nonatomic, assign) CGRect clearRect;
@property (nonatomic, assign) CGSize maxSize;

// Corners
@property (readonly) CGRect topLeftCorner;
@property (readonly) CGRect topRightCorner;
@property (readonly) CGRect bottomLeftCorner;
@property (readonly) CGRect bottomRightCorner;

// Edges
@property (readonly) CGRect topEdgeRect;
@property (readonly) CGRect rightEdgeRect;
@property (readonly) CGRect bottomEdgeRect;
@property (readonly) CGRect leftEdgeRect;

- (BOOL)isCornerContainsPoint:(CGPoint)point;
- (BOOL)isEdgeContainsPoint:(CGPoint)point;

@end
