/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
#import "Pocket_Code-Swift.h"

@interface PlaceHolderView ()
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;
@end


@implementation PlaceHolderView

- (id)initWithTitle:(NSString*)title
{
    if (self = [super init]) {
        self.title = title;
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.placeholderDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                        UIViewAutoresizingFlexibleRightMargin |
                                                        UIViewAutoresizingFlexibleTopMargin |
                                                        UIViewAutoresizingFlexibleBottomMargin;
    self.placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.placeholderDescriptionLabel setFont:[UIFont systemFontOfSize:25]];
    self.placeholderDescriptionLabel.text = self.title;
    self.placeholderDescriptionLabel.backgroundColor = UIColor.clearColor;
    self.placeholderDescriptionLabel.textColor = UIColor.globalTint;
    self.placeholderDescriptionLabel.numberOfLines = 0;
    self.placeholderDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.placeholderDescriptionLabel.preferredMaxLayoutWidth = self.bounds.size.width;
    self.contentView = self.placeholderDescriptionLabel;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setTitle:(NSString *)title
{
    if (title.length) {
        self.placeholderDescriptionLabel.text = title;
    }
}

- (void)setContentView:(UIView *)contentView
{
    if (contentView != _contentView) {
        _contentView = contentView;
        [self addSubview:contentView];
    }
}

@end
