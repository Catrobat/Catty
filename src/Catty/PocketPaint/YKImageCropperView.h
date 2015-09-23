//
//  YKImageCropperView.h
//  Copyright (c) 2013 yuyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKImageCropperView : UIView

@property (nonatomic, strong) UIImage *image;

- (UIImage *)editedImage;
- (id) initWithImage:(UIImage *)image andFrame:(CGRect)frame;
- (void)reset;
- (void)square;
- (void)setConstrain:(CGSize)size;
//- (UIColor *)colorAtPoint:(CGPoint)pixelPoint fromImage:(UIImage *)image;


@end
