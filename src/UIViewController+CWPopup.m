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
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
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
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
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
    blurView.frame = frame;//CGRectMake(0, 0, frame.size.width, frame.size.height);
    blurView.image = [[self getScreenImageWithFrame:frame] applyBlurWithRadius:15.0f];
    [self.view addSubview:blurView];
    [self.view bringSubviewToFront:self.popupViewController.view];
    objc_setAssociatedObject(self, &CWBlurViewKey, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - present/dismiss

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent WithFrame:(CGRect)frame
{
    if (self.popupViewController == nil) {
        // initial setup
        self.popupViewController = viewControllerToPresent;
        self.popupViewController.view.autoresizesSubviews = NO;
        self.popupViewController.view.autoresizingMask = UIViewAutoresizingNone;
        [self addChildViewController:viewControllerToPresent];
        
        // rounded corners
        viewControllerToPresent.view.layer.cornerRadius = 15.0f;
        viewControllerToPresent.view.layer.borderWidth = 4.0f;
        viewControllerToPresent.view.layer.borderColor = [UIColor skyBlueColor].CGColor;
        
        // blurview
        [self addBlurViewWithFrame:frame];
        UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);

        

        // animate
        viewControllerToPresent.view.center = CGPointMake(self.view.center.x,self.view.frame.size.height*0.1f);
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
                             viewControllerToPresent.view.center = CGPointMake(self.view.center.x,viewControllerToPresent.view.frame.size.height/2);
        } completion:^(BOOL finished) {
            [self.popupViewController didMoveToParentViewController:self];
            [self.popupViewController endAppearanceTransition];
        }];
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
                         self.popupViewController.view.center = CGPointMake(self.view.center.x,self.view.frame.size.height*0.1f);
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

#pragma mark - popupViewController getter/setter

- (void)setPopupViewController:(UIViewController *)popupViewController {
    objc_setAssociatedObject(self, &CWPopupKey, popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)popupViewController {
    return objc_getAssociatedObject(self, &CWPopupKey);
}

@end
