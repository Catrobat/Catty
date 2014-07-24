/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "PlaceHolderView.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface PlaceHolderView ()
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;

@end


@implementation PlaceHolderView

- (id)initWithTitle:(NSString *)tile
{
    if (self = [super init]) {
        _title = tile;
        [self initPlaceHolderView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initPlaceHolderView];
    }
    return self;
}

- (void)initPlaceHolderView
{
    self.userInteractionEnabled = NO;
    _placeholderDescriptionLabel = [UILabel new];
    _placeholderDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                        UIViewAutoresizingFlexibleRightMargin |
                                                        UIViewAutoresizingFlexibleTopMargin |
                                                        UIViewAutoresizingFlexibleBottomMargin;
    _placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    [_placeholderDescriptionLabel setFont:[UIFont systemFontOfSize:25]];
    _placeholderDescriptionLabel.text = [NSString stringWithFormat:kUIViewControllerPlaceholderDescriptionStandard,
                                             _title];
    _placeholderDescriptionLabel.backgroundColor = UIColor.clearColor;
    _placeholderDescriptionLabel.textColor = UIColor.skyBlueColor;
    self.contentView = _placeholderDescriptionLabel;
    self.shimmering = YES;
}

- (void)setTitle:(NSString *)title
{
    if (title.length) {
        self.placeholderDescriptionLabel.text = [NSString stringWithFormat:kUIViewControllerPlaceholderDescriptionStandard,
                                                 title];
    }
}

@end
