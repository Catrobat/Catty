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


#import "BrickSelectModalTransition.h"
#import "UIDefines.h"
#import "BricksCollectionViewController.h"

@implementation BrickSelectModalTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *move = nil;
    CGRect endFrame = CGRectZero;
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            BricksCollectionViewController *bricksCollectionViewController = (BricksCollectionViewController *)toVC;
            move = [bricksCollectionViewController.view snapshotViewAfterScreenUpdates:YES];
            move.frame = CGRectMake(0.0f, CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(fromVC.view.bounds), CGRectGetHeight(fromVC.view.bounds));
    
            endFrame = CGRectMake(0.0f, CGRectGetHeight(fromVC.view.bounds) / 2.0f + NAVIGATION_BAR_HEIGHT, CGRectGetWidth(fromVC.view.bounds), CGRectGetHeight(fromVC.view.bounds));
            [container addSubview:move];
            
            
            [UIView animateWithDuration:0.7f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{

                move.frame = endFrame;
                
            } completion:^(BOOL finished) {
                bricksCollectionViewController.view.frame = endFrame;
                [container addSubview:bricksCollectionViewController.view];
                [move removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        
        case TransitionModeDismiss: {
            move = [fromVC.view snapshotViewAfterScreenUpdates:YES];
            move.frame = fromVC.view.frame;
            endFrame = CGRectMake(0.0f, CGRectGetHeight(toVC.view.bounds), CGRectGetWidth(fromVC.view.bounds), CGRectGetHeight(fromVC.view.bounds));
            fromVC.view.frame = endFrame;

            [container addSubview:move];
            
            [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                move.frame = endFrame;
                
            } completion:^(BOOL finished) {
                [move removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
