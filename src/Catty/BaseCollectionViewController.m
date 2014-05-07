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

#import "BaseCollectionViewController.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "FBShimmering/FBShimmeringView.h"

@interface BaseCollectionViewController ()
@property (nonatomic, strong) FBShimmeringView *placeholderView;
@property (nonatomic, strong) UILabel *placeholderTitleLabel;
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;
@end

@implementation BaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlaceHolder];
}


#pragma mark init
- (void)initPlaceHolder
{
    self.placeholderView = [[FBShimmeringView alloc] initWithFrame:self.collectionView.bounds];
    self.placeholderView.tag = kPlaceHolderTag;

    // setup title label
    self.placeholderTitleLabel = [[UILabel alloc] init];
    self.placeholderTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderTitleLabel.backgroundColor = [UIColor clearColor];
    self.placeholderTitleLabel.textColor = [UIColor skyBlueColor];
    self.placeholderTitleLabel.font = [self.placeholderTitleLabel.font fontWithSize:45];

    self.placeholderView.contentView = self.placeholderTitleLabel;
    
    // setup description label
    self.placeholderDescriptionLabel = [[UILabel alloc] init];
    self.placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.placeholderDescriptionLabel.textColor = [UIColor skyBlueColor];
    [self.placeholderView addSubview:self.placeholderTitleLabel];
    [self.placeholderView addSubview:self.placeholderDescriptionLabel];
    [self.collectionView addSubview:self.placeholderView];
    self.placeholderView.hidden = YES;
}


#pragma mark - getters and setters
- (void)setPlaceHolderTitle:(NSString*)title Description:(NSString*)description
{
    //  self.placeholderView.alpha = 0.0f;
    // title label
    self.placeholderTitleLabel.text = title;
    [self.placeholderTitleLabel sizeToFit];

    // description label
    self.placeholderDescriptionLabel.text = description;
    [self.placeholderDescriptionLabel sizeToFit];

    // set alignemnt: middle center
    CGRect frameTitle = self.placeholderTitleLabel.frame;
    CGRect frameDescription = self.placeholderDescriptionLabel.frame;
    CGFloat totalHeight = frameTitle.size.height + frameDescription.size.height;
    NSUInteger offsetY;

    // this sets vertical alignment of the placeholder to the center of table view
    //    offsetY = (self.navigationController.toolbar.frame.origin.y - self.navigationController.navigationBar.frame.size.height - totalHeight)/2.0f;
    // this sets vertical alignment of the placeholder to the center of whole screen
    offsetY = (self.navigationController.toolbar.frame.origin.y - totalHeight)/2.0f - self.navigationController.navigationBar.frame.size.height;
    frameTitle.origin.y = offsetY;
    frameTitle.origin.x = frameDescription.origin.x = 0.0f;
    frameTitle.size.width = frameDescription.size.width = self.view.frame.size.width;
    self.placeholderTitleLabel.frame = frameTitle;

    frameDescription.origin.y = offsetY + frameTitle.size.height;
    self.placeholderDescriptionLabel.frame = frameDescription;
    
    self.placeholderView.shimmering = YES;
    
    // [UIView animateWithDuration:0.25f animations:^{ self.placeholderView.alpha = 1.0f; }];
}

- (void)showPlaceHolder:(BOOL)show
{
    self.collectionView.alwaysBounceVertical = self.placeholderView.hidden = (! show);
}

#pragma mark - helpers
- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

@end
