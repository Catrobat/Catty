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

// FIXME: remove license header!!!

//
//  EAIntroPage.m
//
//  Copyright (c) 2013-2014 Evgeny Aleksandrov. License: MIT.

#import "EAIntroPage.h"

#define DEFAULT_DESCRIPTION_LABEL_SIDE_PADDING 25
#define DEFAULT_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define DEFAULT_LABEL_COLOR [UIColor whiteColor]
#define DEFAULT_DESCRIPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]
//#define DEFAULT_TITLE_IMAGE_Y_POSITION 160.0f
//#define DEFAULT_TITLE_LABEL_Y_POSITION 160.0f
//#define DEFAULT_DESCRIPTION_LABEL_Y_POSITION 140.0f
#define DEFAULT_TITLE_IMAGE_Y_POSITION 90.0f
#define DEFAULT_TITLE_LABEL_Y_POSITION 250.0f
#define DEFAULT_DESCRIPTION_LABEL_Y_POSITION 220.0f

@interface EAIntroPage ()
@property(nonatomic, strong, readwrite) UIView *pageView;
@end

@implementation EAIntroPage

#pragma mark - Page lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _titleIconPositionY = DEFAULT_TITLE_IMAGE_Y_POSITION;
        _titlePositionY  = DEFAULT_TITLE_LABEL_Y_POSITION;
        _descPositionY   = DEFAULT_DESCRIPTION_LABEL_Y_POSITION;
        _title = @"";
        _titleFont = DEFAULT_TITLE_FONT;
        _titleColor = DEFAULT_LABEL_COLOR;
        _desc = @"";
        _descFont = DEFAULT_DESCRIPTION_FONT;
        _descColor = DEFAULT_LABEL_COLOR;
        _showTitleView = YES;
    }
    return self;
}

+ (instancetype)page {
    return [[self alloc] init];
}

+ (instancetype)pageWithCustomView:(UIView *)customV {
    EAIntroPage *newPage = [[self alloc] init];
    newPage.customView = customV;
    return newPage;
}

+ (instancetype)pageWithCustomViewFromNibNamed:(NSString *)nibName {
    return [self pageWithCustomViewFromNibNamed:nibName bundle:[NSBundle mainBundle]];
}

+ (instancetype)pageWithCustomViewFromNibNamed:(NSString *)nibName bundle:(NSBundle*)aBundle {
    EAIntroPage *newPage = [[self alloc] init];
    newPage.customView = [[aBundle loadNibNamed:nibName owner:newPage options:nil] firstObject];
    return newPage;
}

@end
