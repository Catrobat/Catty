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

@interface SingleBrickSelectionView ()
@property (strong, nonatomic) UIView *dimview;
@property (nonatomic, strong) BrickCell *brickCell;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation SingleBrickSelectionView

- (void)showSingleBrickSelectionViewWithBrickCell:(BrickCell *)brickCell fromView:(UIView *)fromView
                                        belowView:(UIView *)belowView completion:(void(^)())completionBlock
{
    self.brickCell = brickCell;
    self.brickCell.center = self.center;
    [self addSubview:self.brickCell];
    
    [fromView insertSubview:self aboveSubview:belowView];
    
    self.brickCell.clipsToBounds = NO;
    self.brickCell.layer.shadowColor = UIColor.whiteColor.CGColor;
    self.brickCell.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.brickCell.layer.shadowRadius = 7.0f;
    self.brickCell.layer.shadowOpacity = 0.7f;
    
    [self.brickCell addGestureRecognizer:self.tapRecognizer];
    
    self.alpha = 0.0f;
    self.brickCell.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1.0f;
        self.brickCell.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
    } completion:^(BOOL finished) {
        if (completionBlock) completionBlock();
    }];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.dimview];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapRecognizer.numberOfTapsRequired = 1;
    }
    return self;
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

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class] && sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.brickCell.transform = CGAffineTransformIdentity;
            self.dimview.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.dimview.hidden = YES;
            
            if (self.delegate) {
                [self.delegate singleBrickSelectionView:self didSelectBrick:self.brickCell];
            }
        }];
    }
}

@end
