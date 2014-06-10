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

#import "SingleBrickSelectionView.h"
#import "BrickCell.h"
#import "BrickManager.h"

@interface SingleBrickSelectionView () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) BrickCell *brickCell;
@property (strong, nonatomic) UIView *brickCellViewCopy;
@property (strong, nonatomic) UILongPressGestureRecognizer *longpressRecognizer;

@end

@implementation SingleBrickSelectionView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.dimview];
        self.longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longpressRecognizer.minimumPressDuration = 0.01;
    }
    return self;
}

- (void)showSingleBrickSelectionViewWithBrickCell:(BrickCell *)brickCell fromView:(UIView *)fromView
                                        belowView:(UIView *)belowView completion:(void(^)())completionBlock
{
    self.brickCell = brickCell;
    self.brickCellViewCopy = [self.brickCell snapshotViewAfterScreenUpdates:YES];
    self.brickCellViewCopy.center = self.center;
    [self addSubview:self.brickCellViewCopy];
    
    [fromView insertSubview:self aboveSubview:belowView];
    
    self.brickCellViewCopy.layer.shadowColor =  UIColor.whiteColor.CGColor;
    self.brickCellViewCopy.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.brickCellViewCopy.layer.shadowRadius = 15.0f;
    self.brickCellViewCopy.layer.shadowOpacity = 0.5f;
    
    [self.brickCellViewCopy addGestureRecognizer:self.longpressRecognizer];
    
    self.alpha = 0.0f;
    self.brickCellViewCopy.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0f;
        self.brickCellViewCopy.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.delegate singleBrickSelectionView:self didShowWithBrick:self.brickCell.brick replicantBrickView:self.brickCellViewCopy];
        if (completionBlock) completionBlock();
    }];
}

#pragma mark - Getters
- (UIView *)dimview
{
    if (!_dimview) {
        _dimview = [[UIView alloc] initWithFrame:self.bounds];
        _dimview.backgroundColor = UIColor.blackColor;
        _dimview.alpha = 0.6f;
        _dimview.userInteractionEnabled = NO;
    }
    return _dimview;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - helpers

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UILongPressGestureRecognizer.class]) {
        
        switch (sender.state) {
            case UIGestureRecognizerStateBegan: {
                [UIView animateWithDuration:0.45f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.brickCellViewCopy.transform = CGAffineTransformIdentity;
                    self.dimview.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    self.dimview.hidden = YES;
                    
                    if (self.delegate) {
                        [self.delegate singleBrickSelectionView:self didSelectBrick:self.brickCell.brick replicantBrickView:self.brickCellViewCopy];
                    }
                }];
            } break;
             
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                NSLog(@"Long Press cancelled");
                break;
                
            default:
                break;
        }
    }
}

@end
