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

#define NAVIGATION_BAR_HEIGHT 64

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    UIView *move = nil;
    CGRect beginFrame = [container convertRect:self.cell.bounds fromView:self.cell];
    
    CGRect endFrame = CGRectMake(0.f, NAVIGATION_BAR_HEIGHT, CGRectGetWidth(self.cell.bounds), CGRectGetHeight(self.cell.bounds));
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            move = [self.cell snapshotViewAfterScreenUpdates:YES];
            move.frame = beginFrame;
            [container addSubview:move];
            self.dimView.hidden = NO;
            
            [UIView animateKeyframesWithDuration:.4f
                                           delay:0.f
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:^{
                                          move.frame = endFrame;
                                          self.dimView.alpha = 1.f;
                                      } completion:^(BOOL finished) {
                                          if (finished) {
                                              self.cell.frame = endFrame;
                                              [toVC.view addSubview:self.cell];
                                              self.cell.hidden = NO;
                                              [toVC.view addSubview:self.cell];
                                              [container addSubview:toView];
                                              [move removeFromSuperview];
                                              [transitionContext completeTransition:YES];
                                          }
                                      }];
            
        }
            break;
            
        case TransitionModeDismiss: {
            move = [fromView snapshotViewAfterScreenUpdates:YES];
            [container addSubview:move];
            
            [UIView animateKeyframesWithDuration:.4f
                                           delay:0.f
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:^{
                                          move.frame = self.touchRect;
                                          self.cell.frame = self.touchRect;
                                          self.dimView.alpha = 0.f;
                                      } completion:^(BOOL finished) {
                                          if (finished) {
                                              [fromView removeFromSuperview];
                                              self.dimView.hidden = YES;
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
