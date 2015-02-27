/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BrickTransition.h"
#import "ScriptCollectionViewController.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickCell.h"
#import "BrickDetailViewController.h"
#import "FXBlurView.h"
#import "math.h"

#define kTopAnimationOffset 20.0f

@interface BrickTransition ()
@property (nonatomic, strong) UIView *animateView;
@property (nonatomic, strong) UIView *originalView;
@property (nonatomic, strong) FXBlurView *blurView;

@end

@implementation BrickTransition {
    CGPoint _animatedFromPosition;
}

- (instancetype)initWithViewToAnimate:(UIView *)view
{
    if (self = [super init]) {
        _animateView = view;
    }
    return self;
}

- (void)updateAnimationViewWithView:(UIView *)view
{
    self.animateView = [view snapshotViewAfterScreenUpdates:YES];
    self.originalView = view;
    
    _animatedFromPosition = view.layer.position;
    self.animateView.frame = view.frame;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CBAssert(self.animateView, @"Error, no view to animate.");
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    ScriptCollectionViewController *scvc = nil;
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            for (UIViewController *controller in fromVC.childViewControllers) {
                if ([controller isKindOfClass:ScriptCollectionViewController.class]) {
                    scvc = (ScriptCollectionViewController *)controller;
                    break;
                }
            }

            CGPoint positionTo = self.animateView.layer.position;
            positionTo.y = ceilf(CGRectGetMidY(self.animateView.layer.bounds) + kTopAnimationOffset);
            
            CGPoint origin = self.animateView.frame.origin;
            origin.y -= scvc.collectionView.contentOffset.y;
            
            CGRect frame = self.animateView.frame;
            frame.origin = origin;
            self.animateView.frame = frame;
            
            CGRect animationViewRect = self.animateView.frame;
            if (scvc.collectionView.contentOffset.y >= 0.f) {
                CGPoint origin = animationViewRect.origin;
                origin.y -= scvc.collectionView.contentOffset.y;
                animationViewRect.origin = origin;
            }
            
            self.originalView.hidden = YES;
            [self setupBlurViewWithFrame:scvc.view.frame underLayingView:scvc.collectionView];
            
            [transitionContext.containerView addSubview:self.blurView];
            [transitionContext.containerView addSubview:toVC.view];
            [transitionContext.containerView addSubview:self.animateView];
            
            __weak BrickTransition *weakself = self;
            fromVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            [UIView animateWithDuration:0.5f
                                  delay:0.0f
                 usingSpringWithDamping:10.0f
                  initialSpringVelocity:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 weakself.animateView.layer.position = positionTo;
                                 weakself.blurView.layer.opacity = 1.0f;
                                 scvc.navigationController.toolbar.alpha = 0.01f;
                                 scvc.navigationController.navigationBar.alpha = 0.01f;
                             } completion:^(BOOL finished) {
                                 weakself.blurView.dynamic = NO;
                                 [transitionContext completeTransition:YES];
                             }];
        }
            break;
            
        case TransitionModeDismiss: {
            for (UIViewController *controller in toVC.childViewControllers) {
                if ([controller isKindOfClass:ScriptCollectionViewController.class]) {
                    scvc = (ScriptCollectionViewController *)controller;
                    break;
                }
            }

            self.blurView.dynamic = YES;
            toVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            
            CGPoint position = self.animateView.layer.position;
            position.y = _animatedFromPosition.y;
            position.y -= scvc.collectionView.contentOffset.y;
            position.y = ceilf(position.y);
            
            __weak BrickTransition *weakself = self;
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                 usingSpringWithDamping:10.0f
                  initialSpringVelocity:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 weakself.animateView.layer.position = position;
                                 weakself.blurView.layer.opacity = 0.0f;
                                 scvc.navigationController.toolbar.alpha = 1.0f;
                                 scvc.navigationController.navigationBar.alpha = 1.0f;
                             } completion:^(BOOL finished) {
                                 weakself.originalView.hidden = NO;
                                 weakself.blurView = nil;
                                 [transitionContext completeTransition:YES];
                             }];
        }
            break;
    }
}

#pragma mark - Private

- (void)setupBlurViewWithFrame:(CGRect)frame underLayingView:(UIView *)underlayingView
{
    self.blurView = [[FXBlurView alloc] initWithFrame:frame];
    self.blurView.underlyingView = underlayingView;
    self.blurView.tintColor = [UIColor blackColor];
    self.blurView.blurRadius = 20.f;
    self.blurView.updateInterval = 0.2f;
    self.blurView.layer.opacity = 0.0f;
}

@end
