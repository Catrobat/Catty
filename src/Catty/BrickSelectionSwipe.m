//
//  BrickSelectionMenuSwipe.m
//  Catty
//
//  Created by luca on 20/05/14.
//
//

#import "BrickSelectionSwipe.h"

@implementation BrickSelectionSwipe {
    BOOL _complete;
}

- (void)attachToViewController:(UIViewController *)viewController
{
    self.viewController = viewController;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.viewController.view addGestureRecognizer:self.panGesture];
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer
{
    NSAssert(self.viewController != nil, @"view controller not set");
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    
    CGFloat percent = 0.0f;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
                [self.viewController dismissViewControllerAnimated:YES completion:NULL];
            break;
            
        case UIGestureRecognizerStateChanged: {
            const CGFloat DragAmount = 400.0f;
            const CGFloat Treshold = 0.06f;
            percent = translation.y / DragAmount;
            percent = fmaxf(percent, 0.0f);
            percent = fminf(percent, 0.99999f);
            [self updateInteractiveTransition:percent];
//            NSLog(@"percent = %f", percent);
            
            if (percent >= Treshold) {
                _complete = YES;
            } else {
                _complete = NO;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled: {
            if (!_complete) {
                [self cancelInteractiveTransition];
                NSLog(@"cancelInteractiveTransition");
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if (_complete) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            break;
        }
            
        default:
            break;
    }
}

- (CGFloat)completionSpeed
{
    return 5 - self.percentComplete;
}

@end
