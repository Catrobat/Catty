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

    // IMPORTANT: needed to dynamically hide/show indicator via cellForRowAtIndexPath method
    //            in TableViewController class (do not remove this any more!!)
    UIImage *accessoryImage = nil;
    switch (self.accessoryType) {
        case UITableViewCellAccessoryDisclosureIndicator:
        case UITableViewCellAccessoryDetailDisclosureButton:
            accessoryImage = [UIImage imageNamed:@"accessory"];
            accessoryImage = [accessoryImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
            self.accessoryView.tintColor = UIColor.skyBlueColor;
        default:
            break;
    }
//    [self addCellSeperator];
}

- (UIView*)createSelectedBackground
{
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.09f]];
    return bgColorView;
}

 //-(void)addCellSeperator {
 //    UIImageView *seperator = [self createCellSeperator];
 //    [self.contentView addSubview:seperator];
 //    self.seperatorView = seperator;
 //}

 //-(UIImageView*)createCellSeperator {
 //    UIImageView *seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellseperator"]];
 //    seperator.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 4.0f);
 //    return seperator;
 //    
 //}

@end
