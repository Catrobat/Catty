/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatBaseCell.h"
#import "LanguageTranslationDefines.h"

#define kFeaturedProgramsBannerHeight  400.0f
#define kFeaturedProgramsBannerWidth   1024.0f

@implementation TableUtil

+ (CGFloat)heightForContinueCell:(CGFloat)navBarHeight
{
    CGFloat screenHeight = [Util screenHeight];
    screenHeight -= navBarHeight;
    return screenHeight * 0.25f;
}

+ (CGFloat)heightForImageCell
{
    CGFloat screenHeight = [Util screenHeight];
    return screenHeight / 7.0f;
}

+ (CGFloat)heightForCatrobatTableViewImageCell:(CGFloat)navBarHeight
{
    CGFloat screenHeight = [Util screenHeight];
    screenHeight -= navBarHeight;
    return screenHeight * 0.14f;
}
+ (CGFloat)heightForFeaturedCell
{
    return kFeaturedProgramsBannerHeight/(kFeaturedProgramsBannerWidth/[Util screenWidth]);
}

+ (UIBarButtonItem*)editButtonItemWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedEdit
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:target
                                                                  action:action];
    return editButton;
}

//+ (void)addSeperatorForCell:(CatrobatBaseCell*)cell{
//    if(cell.seperatorView == nil) {
//        UIImageView *seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellseperator"]];
//        seperator.frame = CGRectMake(0.0f, 0.0f, cell.bounds.size.width, 4.0f);
//        [cell.contentView addSubview:seperator];
//        cell.seperatorView = seperator;
//    }
//}

#pragma mark Helper
+ (UIBarButtonItem*)createBackButtonWithTarget:(id)target{
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"backbutton"];
    backbutton.frame = CGRectMake(20, 100, img.size.width+10, img.size.height);
    [backbutton setImage:img forState:UIControlStateNormal];
    [backbutton setImage:img forState:UIControlStateHighlighted];
    [backbutton setImage:img forState:UIControlStateSelected];
    [backbutton addTarget:target action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backbutton];
}

@end
