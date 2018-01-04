/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@implementation BrickSelectModalTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame;
    CGRect beginFrame;
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            [container addSubview:toVC.view];
            
            endFrame = toVC.view.frame;
           
            beginFrame = toVC.view.frame;
            beginFrame.origin.y = CGRectGetHeight(toVC.view.frame);
            endFrame.origin.y += fromVC.view.bounds.size.height / 2.0f;

            toVC.view.frame = beginFrame;
            
            [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:20.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                toVC.view.frame = endFrame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
            break;
        }
        
        case TransitionModeDismiss: {
            endFrame = toVC.view.frame;
            endFrame.origin.y = CGRectGetHeight(toVC.view.frame);
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                 fromVC.view.frame = endFrame;
                
            } completion:^(BOOL finished) {
                if ([transitionContext transitionWasCancelled]) {
                    [transitionContext completeTransition:NO];
                } else {
                    [fromVC.view removeFromSuperview];
                    [transitionContext completeTransition:YES];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

@end
