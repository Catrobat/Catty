//
//  UIViewController+CWPopup.h
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "UIViewController+CWPopup.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <float.h>
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIDefines.h"


@import Accelerate;

@interface UIImage (ImageBlur)
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius;

@end

@implementation UIImage (ImageBlur)

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSError (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSError (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }

    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;

    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    if (hasBlur) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);

        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);

        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);

        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = (NSUInteger)floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t) radius, (uint32_t) radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t) radius, (uint32_t) radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t) radius, (uint32_t) radius, 0, kvImageEdgeExtend);
        }
        
        effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);

    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);

    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }

    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}
@end

#define ANIMATION_TIME 0.25f

NSString const *CWPopupKey = @"CWPopupkey";
NSString const *CWBlurViewKey = @"CWFadeViewKey";
NSString const *CWUseBlurForPopup = @"CWUseBlurForPopup";
NSString const *CWPopupViewOffset = @"CWPopupViewOffset";

@implementation UIViewController (CWPopup)

@dynamic popupViewController;

#pragma mark - blur view methods

- (UIImage *)getScreenImageWithFrame:(CGRect)frame{
    // frame without status bar
   // CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    // begin image context
    UIGraphicsBeginImageContext(frame.size);
    // get current context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // draw current view
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    // clip context to frame
    CGContextClipToRect(currentContext, frame);
    // get resulting cropped screenshot
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    // end image context
    UIGraphicsEndImageContext();
    return screenshot;
}

- (void)addBlurViewWithFrame:(CGRect)frame {
    UIImageView *blurView = [UIImageView new];
    if (frame.origin.y > 0) {
        blurView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height+frame.origin.y);
    }else{
        blurView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    
    blurView.image = [[self getScreenImageWithFrame:CGRectMake(0, frame.size.height/4+frame.origin.y, frame.size.width, frame.size.height)] applyBlurWithRadius:15.0f];
    [self.view addSubview:blurView];
    [self.view bringSubviewToFront:self.popupViewController.view];
    objc_setAssociatedObject(self, &CWBlurViewKey, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - present/dismiss

//If factor == 1: the popup appears in the middle of the screen
//Everything >1: moves the popup more to the top
- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent WithFrame:(CGRect)frame Centered:(BOOL)centered
{
    if (self.popupViewController == nil) {
        // initial setup
        self.popupViewController = viewControllerToPresent;
        self.popupViewController.view.autoresizesSubviews = NO;
        self.popupViewController.view.autoresizingMask = UIViewAutoresizingNone;
        [self addChildViewController:viewControllerToPresent];
        
        // rounded corners
        viewControllerToPresent.view.layer.cornerRadius = 15.0f;
        viewControllerToPresent.view.layer.borderWidth = 2.0f;
        viewControllerToPresent.view.layer.borderColor = [UIColor globalTintColor].CGColor;
        
        // blurview
        if (frame.origin.y<0.0f) {
            frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
        } else {
            frame = CGRectMake(frame.origin.x, frame.origin.y+50, frame.size.width, frame.size.height);
        }
        if (centered) {
            [self addBlurViewWithFrame:frame];
        }
        UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);

        // animate
        viewControllerToPresent.view.center = CGPointMake(self.view.center.x, frame.size.height+frame.origin.y);
        viewControllerToPresent.view.alpha = 0.4f;
        blurView.alpha = 0.4f;
        
        [viewControllerToPresent beginAppearanceTransition:YES animated:YES];
        [self.view addSubview:viewControllerToPresent.view];
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             blurView.alpha = 1.0f;
                             viewControllerToPresent.view.alpha = 1.0f;
                             if (centered) {
                                 viewControllerToPresent.view.center = CGPointMake(self.view.center.x, frame.size.height/2-self.navigationController.navigationBar.frame.size.height/2-10);
                             }else{
                                  viewControllerToPresent.view.center = CGPointMake(self.view.center.x, 150+frame.origin.y);
                             }
                            
                             
                         } completion:^(BOOL finished) {
            [self.popupViewController didMoveToParentViewController:self];
            [self.popupViewController endAppearanceTransition];
        }];
        // if screen orientation changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)dismissPopupViewController {
    UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
    [self.popupViewController willMoveToParentViewController:nil];
    
    // animate
    [self.popupViewController beginAppearanceTransition:NO animated:YES];
    
    [UIView animateWithDuration:ANIMATION_TIME
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.popupViewController.view.center = CGPointMake(self.view.center.x,self.view.frame.size.height);
                         self.popupViewController.view.alpha = 0.0f;
                         blurView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.popupViewController removeFromParentViewController];
        [self.popupViewController endAppearanceTransition];
        [self.popupViewController.view removeFromSuperview];
        [blurView removeFromSuperview];
        self.popupViewController = nil;
    }];
}
#pragma mark - handling screen orientation change

- (CGRect)getPopupFrameForViewController:(UIViewController *)viewController {
    CGRect frame = viewController.view.frame;
    CGFloat x;
    CGFloat y;
    if (UIDeviceOrientationIsPortrait((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation) || NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        x = ([UIScreen mainScreen].bounds.size.width - frame.size.width)/2;
        y = ([UIScreen mainScreen].bounds.size.height - frame.size.height)/2;
    } else {
        x = ([UIScreen mainScreen].bounds.size.height - frame.size.width)/2-frame.size.width;
        y = ([UIScreen mainScreen].bounds.size.width - frame.size.height)/2-frame.size.height;
    }
    return CGRectMake(x, y, frame.size.width, frame.size.height);
}

- (void)screenOrientationChanged {
    // make blur view go away so that we can re-blur the original back
    UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.popupViewController.view.frame = [self getPopupFrameForViewController:self.popupViewController];
        if (UIDeviceOrientationIsPortrait((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation) || NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            blurView.frame = [UIScreen mainScreen].bounds;
        } else {
            blurView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        }
            [UIView animateWithDuration:1.0f animations:^{
                // for delay
            } completion:^(BOOL finished) {
                [blurView removeFromSuperview];
                // popup view alpha to 0 so its not in the blur image
                self.popupViewController.view.alpha = 0.0f;
//                [self addBlurView];
                self.popupViewController.view.alpha = 1.0f;
                // display blurView again
                UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
                blurView.alpha = 1.0f;
            }];
    }];
}

#pragma mark - popupViewController getter/setter

- (void)setPopupViewController:(UIViewController *)popupViewController {
    objc_setAssociatedObject(self, &CWPopupKey, popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)popupViewController {
    return objc_getAssociatedObject(self, &CWPopupKey);
}

@end
