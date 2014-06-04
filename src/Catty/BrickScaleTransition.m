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

#import "BrickScaleTransition.h"
#import "ScriptCollectionViewController.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@implementation BrickScaleTransition {
    CGFloat _yOffset;
    ScriptCollectionViewController *_scriptCollectionVC;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *move = nil;
    CGRect beginFrame = [container convertRect:self.cell.bounds fromView:self.cell];
    
    CGRect endFrame = CGRectMake(0.0f, CGRectGetMidY(UIScreen.mainScreen.bounds) - CGRectGetMidY(self.cell.bounds), CGRectGetWidth(self.cell.bounds), CGRectGetHeight(self.cell.bounds));
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            _scriptCollectionVC = (ScriptCollectionViewController *)fromVC.childViewControllers.lastObject;
            NSAssert(_scriptCollectionVC != nil, @"No ScriptCollectionViewController Class in ViewController Hierachie");
            _yOffset = self.touchRect.origin.y - _scriptCollectionVC.collectionView.contentOffset.y;
            
            move = [self.cell snapshotViewAfterScreenUpdates:YES];
            move.frame = beginFrame;
            [container addSubview:move];
            self.cell.hidden = YES;
            _scriptCollectionVC.blurView.hidden = NO;
            
            [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
                move.frame = endFrame;
                _scriptCollectionVC.blurView.alpha = 1.0f;
                _scriptCollectionVC.collectionView.alpha = 0.5f;
                _scriptCollectionVC.navigationController.navigationBar.alpha = 0.01f;
                _scriptCollectionVC.navigationController.navigationBar.tintColor = UIColor.lightGrayColor;
                _scriptCollectionVC.navigationController.toolbar.alpha = 0.01f;
            } completion:^(BOOL finished) {
                _scriptCollectionVC.blurView.dynamic = NO;
                toVC.view.frame = fromVC.view.frame;
                self.cell.hidden = NO;
                self.cell.frame = CGRectMake(0.0f, CGRectGetMidY(UIScreen.mainScreen.bounds) - CGRectGetMidY(self.cell.bounds), CGRectGetWidth(self.cell.bounds), CGRectGetHeight(self.cell.bounds));
                [toVC.view addSubview:self.cell];
                [container addSubview:toVC.view];
                [move removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }
            break;
            
        case TransitionModeDismiss: {
            _scriptCollectionVC.blurView.dynamic = YES;
            [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:1.7f initialSpringVelocity:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cell.frame = CGRectMake(0.0f, _yOffset, self.touchRect.size.width, self.touchRect.size.height);
                _scriptCollectionVC.blurView.alpha = 0.0f;
                _scriptCollectionVC.collectionView.alpha = 1.0f;
                _scriptCollectionVC.navigationController.navigationBar.alpha = 1.0f;
                _scriptCollectionVC.navigationController.navigationBar.tintColor = UIColor.lightOrangeColor;
                _scriptCollectionVC.navigationController.toolbar.alpha = 1.0f;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.cell.frame = self.touchRect;
                    [fromVC.view removeFromSuperview];
                    _scriptCollectionVC.blurView.hidden = YES;
                    [move removeFromSuperview];
                    [transitionContext completeTransition:YES];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
