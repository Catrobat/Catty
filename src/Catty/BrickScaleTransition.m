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
#import "UIColor+CatrobatUIColorExtensions.h"

@implementation BrickScaleTransition

#define NAVIGATION_BAR_HEIGHT 64

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *move = nil;
    CGRect beginFrame = [container convertRect:self.cell.bounds fromView:self.cell];
    
    CGRect endFrame = CGRectMake(0.f, NAVIGATION_BAR_HEIGHT, CGRectGetWidth(self.cell.bounds), CGRectGetHeight(self.cell.bounds));
    
    switch (self.transitionMode) {
        case TransitionModePresent: {
            move = [self.cell snapshotViewAfterScreenUpdates:YES];
            move.frame =beginFrame;
            [container addSubview:move];
            self.cell.hidden = YES;
            self.dimView.hidden = NO;
            
            [UIView animateWithDuration:.8f delay:0.f usingSpringWithDamping:0.75f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                move.frame = endFrame;
                self.dimView.alpha = 1.f;
                self.collectionView.alpha = .2f;
                self.navigationBar.tintColor = UIColor.brightGrayColor;
            } completion:^(BOOL finished) {
                if (finished) {
                    toVC.view.frame = endFrame;
                    self.cell.hidden = NO;
                    self.cell.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.cell.bounds), CGRectGetHeight(self.cell.bounds));
                    [toVC.view addSubview:self.cell];
                    [container addSubview:toVC.view];
                    [move removeFromSuperview];
                    [transitionContext completeTransition:YES];
                }
            }];
        }
            break;
            
        case TransitionModeDismiss: {
            [UIView animateKeyframesWithDuration:.4f
                                           delay:0.f
                                         options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                                      animations:^{
                                          self.cell.frame = self.touchRect;
                                          self.dimView.alpha = 0.f;
                                          self.collectionView.alpha = 1.f;
                                          self.navigationBar.tintColor = UIColor.lightOrangeColor;
                                      } completion:^(BOOL finished) {
                                          if (finished) {
                                              [fromVC.view removeFromSuperview];
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
