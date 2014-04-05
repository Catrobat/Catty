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

@implementation BrickScaleTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    UIView *move = nil;
    CGRect beginFrame = [container convertRect:self.cell.bounds fromView:self.cell];
    
    CGFloat width;
    CGFloat height;
    
    if (self.transitionMode == TransitionModePresent) {
        width = toView.bounds.size.width;
        height = CGRectGetHeight(self.cell.bounds);
    } else {
        width = fromView.bounds.size.width;
        height = fromView.bounds.size.height;
    }
    
    CGRect endFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, width, height);


    switch (self.transitionMode) {
        case TransitionModePresent: {
            self.cell.hidden = YES;
            toView.frame = endFrame;
            
            move = [toView snapshotViewAfterScreenUpdates:YES];
        
            move.frame = beginFrame;
            [container addSubview:move];
            
            self.dimView.hidden = NO;
            
            [UIView animateWithDuration:.7f
                                  delay:0.f
                 usingSpringWithDamping:2.f
                  initialSpringVelocity:27.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 move.frame = endFrame;
                                 self.dimView.alpha = 0.9f;
                             }
                             completion:^(BOOL finished) {
                                 [toVC.view addSubview:self.cell.contentView];
                                 toView.frame = endFrame;
                                 [container addSubview:toView];
                                 [move removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                             }];
        }
            break;
            
        case TransitionModeDismiss: {
            move =[fromView snapshotViewAfterScreenUpdates:YES];
            [fromView removeFromSuperview];
            
            // move.center = toView.center;
            [container addSubview:move];
            
            [UIView animateKeyframesWithDuration:.5f
                                           delay:0.f
                                         options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                                      animations:^{
                                          move.frame = beginFrame;
                                          self.dimView.alpha = 0.f;
                                          
                                      } completion:^(BOOL finished) {
                                          self.cell.hidden = NO;
                                          self.dimView.hidden = YES;
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
