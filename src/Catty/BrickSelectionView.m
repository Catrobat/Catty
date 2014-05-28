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

#import "BrickSelectionView.h"
#import "FXBlurView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIDefines.h"
#import "ScriptCollectionViewController.h"

@interface BrickSelectionView ()
@property (strong, nonatomic) CALayer *topBorder;
@property (assign, nonatomic, getter = isOnScreen) BOOL onScreen;

@end

@implementation BrickSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.brickCollectionView];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)showWithView:(UIView *)view fromViewController:(UIViewController *)viewController completion:(void(^)())completionBlock
{
    NSAssert(self.yOffset > 0.0f, @"no valid y offset value to show view");
    if (!self.isOnScreen) {
         self.onScreen = YES;
        
        self.frame = CGRectMake(0.0f, CGRectGetHeight(UIScreen.mainScreen.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        
        self.textLabel.textColor = self.tintColor;
        self.topBorder.backgroundColor = self.tintColor.CGColor;
        [self.layer addSublayer:self.topBorder];
        self.textLabel.alpha = 1.0f;
        self.textLabel.transform = CGAffineTransformIdentity;

        [viewController.view insertSubview:self aboveSubview:view];
        
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.origin.y + self.yOffset, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            [viewController.navigationController setNavigationBarHidden:YES animated:YES];
            view.alpha = 0.2f;
            view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0f, -20.0f), 0.95f, 0.95f);
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        self.textLabel.transform = CGAffineTransformMakeTranslation((-1) * self.textLabel.bounds.size.width, 0.0f);
                        self.textLabel.alpha = 0.0f;
                    }];
                });
            }
        }];
        
    } else {
        [self dismissView:viewController withView:view];
    }
    
    if (completionBlock) completionBlock();
}

- (void)dismissView:(UIViewController *)fromViewController withView:(UIView *)view
{
    if (self.onScreen) {
        self.onScreen = NO;
        
        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(0.0f, UIScreen.mainScreen.bounds.size.height, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            [fromViewController.navigationController setNavigationBarHidden:NO animated:YES];
            view.alpha = 1.0f;
            view.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }
}

#pragma mark - getter

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0f, 2.5f, 80.0f, 15.0f)];
        _textLabel.font = [UIFont systemFontOfSize:13.0f];
        _textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textLabel;
}

- (UICollectionView *)brickCollectionView
{
    if (!_brickCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        _brickCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) collectionViewLayout:layout];
        _brickCollectionView.backgroundColor = UIColor.blackColor;
        _brickCollectionView.scrollEnabled = YES;
        _brickCollectionView.bounces = YES;
        _brickCollectionView.delaysContentTouches = NO;
        _brickCollectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 55.0f, 0.0f);
    }
    return _brickCollectionView;
}

- (CALayer *)topBorder
{
    if (!_topBorder) {
        _topBorder = [CALayer new];
        _topBorder.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), 1.0f);
    }
    return _topBorder;
}

- (BOOL)active
{
    return self.onScreen;
}

@end
