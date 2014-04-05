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
    CGRect beginFrame = [container convertRect:self.cell.backgroundView.bounds fromView:self.cell];
    
    CGFloat width;
    CGFloat height;
    
    if (self.transitionMode == TransitionModePresent) {
        width = toView.bounds.size.width;
        height = toView.bounds.size.height / 4.f;
    } else {
        width = fromView.bounds.size.width;
        height = fromView.bounds.size.height;
    }
    
    CGRect endFrame = CGRectMake(0.f, 0.f, width, height);


    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            self.cell.hidden = YES;
            toView.frame = endFrame;
            
            move = [self.cell snapshotViewAfterScreenUpdates:YES];
        
            move.frame = beginFrame;
            [container addSubview:move];
            
            self.dimView.hidden = NO;
            
            [UIView animateWithDuration:.6f
                                  delay:0.f
                 usingSpringWithDamping:2.f
                  initialSpringVelocity:17.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 move.frame = endFrame;
                                 self.dimView.alpha = 0.6f;
                             }
                             completion:^(BOOL finished) {
                                 [toVC.view addSubview:self.cell.backgroundView];
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
                                          move.alpha = 0.f;
                                          move.frame = beginFrame;
                                          self.cell.alpha = 1.f;
                                          self.dimView.alpha = 0.f;
                                          self.cell.hidden = NO;
                                          
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
