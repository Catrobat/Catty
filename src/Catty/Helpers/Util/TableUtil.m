/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

#import "TableUtil.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

#define kFeaturedProjectsBannerHeight  400.0f
#define kFeaturedProjectsBannerWidth   1024.0f
#define kContinueCellRelativeHeight 0.25f
#define kStandardImageCellRelativeHeight 0.15f

@implementation TableUtil

+ (CGFloat)heightForContinueCell:(CGFloat)navBarHeight withStatusBarHeight:(CGFloat)statusBarHeight
{
    CGFloat screenHeight = [Util screenHeight];
    
    screenHeight -= statusBarHeight;
    screenHeight -= navBarHeight;
    return screenHeight * kContinueCellRelativeHeight;
}

+ (CGFloat)heightForImageCell
{
    CGFloat screenHeight = [Util screenHeight];
    return screenHeight / 7.0f;
}

+ (CGFloat)heightForCatrobatTableViewImageCell:(CGFloat)navBarHeight
                           withStatusBarHeight:(CGFloat)statusBarHeight
{
    CGFloat screenHeight = [Util screenHeight];
       
    screenHeight -= statusBarHeight;
    screenHeight -= navBarHeight;
    
    return screenHeight * kStandardImageCellRelativeHeight;
}
+ (CGFloat)heightForFeaturedCell
{
    return kFeaturedProjectsBannerHeight/(kFeaturedProjectsBannerWidth/[Util screenWidth]);
}

+ (UIBarButtonItem*)editButtonItemWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedEdit
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:target
                                                                  action:action];
    return editButton;
}

@end
