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

#import "BrickSelectionView.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIDefines.h"

@interface BrickSelectionView ()
@property (strong, nonatomic) FXBlurView *blurView;
@property (assign, nonatomic, getter = isOnScreen) BOOL onScreen;

@end

@implementation BrickSelectionView {
    CGFloat _originalViewHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.alpha = 0.98f;
        
        CALayer *overlayLayer = CALayer.layer;
        overlayLayer.frame = self.blurView.bounds;
        overlayLayer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        [self.layer insertSublayer:overlayLayer atIndex:1];
        
        [self insertSubview:self.blurView atIndex:0];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)showWithView:(UIView *)view fromViewController:(UIViewController *)viewController completion:(void(^)())completionBlock
{
    NSAssert(self.yOffset > 0.0f, @"no valid y offset value to show view");
    
    _originalViewHeight = CGRectGetHeight(view.bounds);
    
    if (self.isOnScreen) {
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.size.height - self.yOffset, CGRectGetWidth(self.bounds), CGRectGetMidY(UIScreen.mainScreen.bounds));
            view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.bounds), CGRectGetMidY(UIScreen.mainScreen.bounds) + NAVIGATION_BAR_HEIGHT);
            [viewController.navigationController setNavigationBarHidden:YES animated:YES];
        } completion:^(BOOL finished) {
            self.onScreen = YES;
        }];
        
    } else {
        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.size.height + self.yOffset, CGRectGetWidth(self.bounds), CGRectGetMidY(UIScreen.mainScreen.bounds));
            view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.bounds), _originalViewHeight);
            [viewController.navigationController setNavigationBarHidden:YES animated:YES];
        } completion:^(BOOL finished) {
            self.onScreen = NO;
        }];
    }
    
    if (completionBlock) completionBlock();
}

#pragma mark - getter
- (FXBlurView *)blurView
{
    if (!_blurView) {
        _blurView = [[FXBlurView alloc] initWithFrame:self.bounds];
        _blurView.tintColor = UIColor.clearColor;
        _blurView.underlyingView = self.underlayingView;
        _blurView.updateInterval = 0.1f;
        _blurView.blurRadius = 20.f;
    }
    return _blurView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0f, 10.0f, 80.0f, 15.0f)];
        _textLabel.text = @"Brick Name";
        _textLabel.font = [UIFont systemFontOfSize:13.0f];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.textColor = UIColor.skyBlueColor;
    }
    return _textLabel;
}

@end
