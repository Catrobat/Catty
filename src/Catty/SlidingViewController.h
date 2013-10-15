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
#import <UIKit/UIKit.h>
#import "UIImage+ImageWithUIView.h"


extern NSString *const SlidingViewUnderRightWillAppear;
extern NSString *const SlidingViewUnderLeftWillAppear;
extern NSString *const SlidingViewUnderLeftWillDisappear;
extern NSString *const SlidingViewUnderRightWillDisappear;
extern NSString *const SlidingViewTopDidAnchorLeft;
extern NSString *const SlidingViewTopDidAnchorRight;
extern NSString *const SidingViewTopWillReset;
extern NSString *const SlidingViewTopDidReset;


typedef enum {
  FullWidth,
  FixedRevealWidth,
  VariableRevealWidth
} ViewWidthLayout;


typedef enum {
  Left,
  Right
} Side;


typedef enum {
  None = 0,
  Tapping = 1 << 0,
  Panning = 1 << 1
} ResetStrategy;


@interface SlidingViewController : UIViewController{
  CGPoint startTouchPosition;
  BOOL topViewHasFocus;
}


@property (nonatomic, strong) UIViewController *underLeftViewController;

@property (nonatomic, strong) UIViewController *underRightViewController;

@property (nonatomic, strong) UIViewController *topViewController;

@property (nonatomic, unsafe_unretained) CGFloat anchorLeftPeekAmount;

@property (nonatomic, unsafe_unretained) CGFloat anchorRightPeekAmount;

@property (nonatomic, unsafe_unretained) CGFloat anchorLeftRevealAmount;

@property (nonatomic, unsafe_unretained) CGFloat anchorRightRevealAmount;

@property (nonatomic, unsafe_unretained) BOOL shouldAllowUserInteractionsWhenAnchored;

@property (nonatomic, unsafe_unretained) BOOL shouldAddPanGestureRecognizerToTopViewSnapshot;

@property (nonatomic, unsafe_unretained) ViewWidthLayout underLeftWidthLayout;

@property (nonatomic, unsafe_unretained) ViewWidthLayout underRightWidthLayout;

@property (nonatomic, unsafe_unretained) ResetStrategy resetStrategy;


- (UIPanGestureRecognizer *)panGesture;

- (void)anchorTopViewTo:(Side)side;

- (void)anchorTopViewTo:(Side)side animations:(void(^)())animations onComplete:(void(^)())complete;


- (void)anchorTopViewOffScreenTo:(Side)side;

- (void)anchorTopViewOffScreenTo:(Side)side animations:(void(^)())animations onComplete:(void(^)())complete;


- (void)resetTopView;

- (void)resetTopViewWithAnimations:(void(^)())animations onComplete:(void(^)())complete;

- (BOOL)underLeftShowing;

- (BOOL)underRightShowing;

- (BOOL)topViewIsOffScreen;

@end

@interface UIViewController(SlidingViewExtension)

- (SlidingViewController *)slidingViewController;
@end