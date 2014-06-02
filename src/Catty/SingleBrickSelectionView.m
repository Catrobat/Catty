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
@property (nonatomic, strong) UIView *brickViewPlaceHolder;

@end

@implementation SingleBrickSelectionView

+ (instancetype)singleBrickSelectionViewWithBrickCell:(BrickCell *)brickCell
{
    SingleBrickSelectionView *view = [self new];
    view.frame = UIScreen.mainScreen.bounds;
    view.brickCell = brickCell;
    [view.brickViewPlaceHolder addSubview:view.brickCell];
    return view;
}

- (id)init
{
    if (self = [super init]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.dimview];
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

- (UIView *)brickViewPlaceHolder
{
    if (!_brickViewPlaceHolder) {
        _brickViewPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMidY(self.bounds), CGRectGetWidth(self.bounds), [self.brickCell.class cellHeight])];
        _brickViewPlaceHolder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = UIColor.clearColor;
    }
    return _brickViewPlaceHolder;
}

@end
