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

#import "BrickSelectionView.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIDefines.h"
#import "ScriptCollectionViewController.h"
#import "FXBlurView.h"
#import "CellMotionEffect.h"

@interface BrickSelectionView ()
@property (strong, nonatomic) CALayer *topBorder;
@property (assign, nonatomic, getter = isOnScreen) BOOL onScreen;
@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) UIMotionEffectGroup *motionEffects;

@end

@implementation BrickSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.brickCollectionView];
        [self addSubview:self.textLabel];
        [CellMotionEffect addMotionEffectForView:self withDepthX:0.0f withDepthY:30.0f withMotionEffectGroup:self.motionEffects];
    }
    return self;
}

- (void)showWithView:(UIView *)view fromViewController:(UIViewController *)viewController completion:(void(^)())completionBlock
{
    NSAssert(self.yOffset > 0.0f, @"no valid y offset value to show view");
    if (!self.isOnScreen) {
         self.onScreen = YES;
        
        self.frame = CGRectMake(0.0f, CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        self.blurView.underlyingView = viewController.view;
        
        self.textLabel.textColor = self.tintColor;
        self.topBorder.backgroundColor = self.tintColor.CGColor;
        [self.layer addSublayer:self.topBorder];
        self.textLabel.alpha = 1.0f;
        self.textLabel.transform = CGAffineTransformIdentity;
        
        [viewController.view insertSubview:self aboveSubview:view];
        
        [self.brickCollectionView scrollToItemAtIndexPath:0 atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        __weak BrickSelectionView *weakself = self;
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:10.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.origin.y + self.yOffset, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            [viewController.navigationController setNavigationBarHidden:YES animated:YES];
            view.alpha = 0.2f;
            view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -20.0f), 0.95f, 0.95f);
        } completion:^(BOOL finished) {
            if (finished) {
                view.userInteractionEnabled = NO;
                weakself.blurView.dynamic = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        self.textLabel.alpha = 0.0f;
                        self.textLabel.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                    } completion:NULL];
                });
            }
        }];
        if (completionBlock) completionBlock();
    } else {
        [self dismissView:viewController withView:view fastDismiss:NO completion:NULL];
        if (completionBlock) completionBlock();
    }
}

- (void)dismissView:(UIViewController *)fromViewController withView:(UIView *)view fastDismiss:(BOOL)fastDimiss completion:(void(^)())completionBlock
{
    if (self.onScreen) {
        self.onScreen = NO;
        
        [UIView animateWithDuration:fastDimiss ? 0.15f : 0.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.size.height, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            [fromViewController.navigationController setNavigationBarHidden:NO animated:YES];
            view.alpha = 1.0f;
            view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            view.userInteractionEnabled = YES;
            if (completionBlock) completionBlock();
        }];
        
       
    }
}

#pragma mark - getter

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), 16.0f)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.center = CGPointMake(self.center.x, _textLabel.center.y + 2.5f);
        _textLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _textLabel;
}

- (UICollectionView *)brickCollectionView
{
    if (!_brickCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        _brickCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) collectionViewLayout:layout];
        _brickCollectionView.backgroundColor = UIColor.clearColor;
        _brickCollectionView.scrollEnabled = YES;
        _brickCollectionView.bounces = YES;
        _brickCollectionView.delaysContentTouches = NO;
        _brickCollectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 55.0f, 0.0f);
    }
    return _brickCollectionView;
}

- (CALayer *)topBorder
{
    if (!_topBorder) {
        _topBorder = [CALayer new];
        _topBorder.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), 1.0f);
    }
    return _topBorder;
}

- (FXBlurView *)blurView
{
    if (! _blurView) {
        _blurView = [[FXBlurView alloc] initWithFrame:self.bounds];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _blurView.userInteractionEnabled = NO;
        _blurView.tintColor = UIColor.clearColor;
        _blurView.blurRadius = 20.f;
        _blurView.alpha = 0.9f;
        [self addSubview:self.blurView];
        [self sendSubviewToBack:_blurView];
    }
    _blurView.dynamic = YES;
    return _blurView;
}

- (UIMotionEffectGroup *)motionEffects {
    if (!_motionEffects) {
        _motionEffects = [UIMotionEffectGroup new];
    }
    return _motionEffects;
}

- (BOOL)active
{
    return self.onScreen;
}

@end
