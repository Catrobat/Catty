//
//  BrickSelectionMenuSwipe.h
//  Catty
//
//  Created by luca on 20/05/14.
//
//

#import <UIKit/UIKit.h>
#import "BricksCollectionViewController.h"

@interface BrickSelectionSwipe : UIPercentDrivenInteractiveTransition
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

- (void)attachToViewController:(UIViewController *)viewController;

@end
