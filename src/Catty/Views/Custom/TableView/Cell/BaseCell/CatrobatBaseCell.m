/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "CatrobatBaseCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"


@implementation CatrobatBaseCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.selectedBackgroundView = [self createSelectedBackground];

    UIImage *accessoryImage = nil;
    switch (self.accessoryType) {
        case UITableViewCellAccessoryDisclosureIndicator:
        case UITableViewCellAccessoryDetailDisclosureButton:
            accessoryImage = [UIImage imageNamed:@"accessory"];
            accessoryImage = [accessoryImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
            self.accessoryView.tintColor = [UIColor utilityTintColor];
        default:
            break;
    }
}

- (UIView*)createSelectedBackground
{
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor navTintColor]];
    return bgColorView;
}

@end
