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

#import "BrickScaleTransition.h"
#import "ScriptCollectionViewController.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickCell.h"
#import "BrickDetailViewController.h"

#define kTopAnimationOffset 20.0f

@implementation BrickScaleTransition {
    CGFloat _animatedFromPositionY;
    CGRect _animatedFromRect;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BrickCell *brickCell = nil;
    ScriptCollectionViewController *scvc = nil;
    switch (self.transitionMode) {
        case TransitionModePresent: {
            for (UIViewController *controller in fromVC.childViewControllers) {
                if ([controller isKindOfClass:ScriptCollectionViewController.class]) {
                    scvc = (ScriptCollectionViewController *)controller;
                    break;
                }
            }
            scvc.blurView.hidden = NO;
            
            brickCell = (BrickCell *)[scvc.collectionView cellForItemAtIndexPath:scvc.selectedIndexPath];
            [transitionContext.containerView addSubview:brickCell];
            [transitionContext.containerView addSubview:toVC.view];
    
            CGPoint posBrickCell = brickCell.layer.position;
            _animatedFromPositionY = brickCell.frame.origin.y - scvc.collectionView.contentOffset.y;
            _animatedFromRect = brickCell.frame;
            posBrickCell.y = CGRectGetMidY(brickCell.layer.bounds) + kTopAnimationOffset;
            fromVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            UIView *animationView = [brickCell snapshotViewAfterScreenUpdates:NO];
            CGRect animationViewRect = [transitionContext.containerView convertRect:brickCell.bounds fromView:brickCell];
            if (scvc.collectionView.contentOffset.y >= 0.f) {
                CGPoint origin = animationViewRect.origin;
                origin.y -= scvc.collectionView.contentOffset.y;
                animationViewRect.origin = origin;
            }
            
            animationView.frame = animationViewRect;
            [transitionContext.containerView addSubview:animationView];
            
            brickCell.hidden = YES;
            [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:10.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                animationView.layer.position = posBrickCell;
                scvc.blurView.alpha = 1.0f;
                scvc.collectionView.alpha = 0.5f;
                scvc.navigationController.toolbar.alpha = 0.01f;
                scvc.navigationController.navigationBar.alpha = 0.01f;
            } completion:^(BOOL finished) {
                [animationView removeFromSuperview];
                scvc.blurView.dynamic = NO;
                brickCell.layer.position = posBrickCell;
                brickCell.hidden = NO;
                [toVC.view addSubview:brickCell];
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
            BrickDetailViewController *bdvc = (BrickDetailViewController *)fromVC;
            brickCell = bdvc.brickCell;
            scvc.blurView.dynamic = YES;
            toVC.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            
            CGPoint position = CGPointMake(brickCell.layer.position.x, _animatedFromPositionY + CGRectGetMidY(brickCell.bounds));
            CGRect brickCellFrame = _animatedFromRect;
    
            [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:10.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                brickCell.layer.position = position;
                scvc.blurView.alpha = 0.0f;
                scvc.collectionView.alpha = 1.0f;
                scvc.navigationController.toolbar.alpha = 1.0f;
                scvc.navigationController.navigationBar.alpha = 1.0f;
            } completion:^(BOOL finished) {
                brickCell.frame = brickCellFrame;
                scvc.blurView.hidden = YES;
                [transitionContext completeTransition:YES];
                [scvc viewDidAppear:NO];
            }];
        }
            break;
    }
}

@end
