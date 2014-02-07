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

#import "BaseTableViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TableUtil.h"
#import "UIDefines.h"

#define kTableHeaderIdentifier @"Header"

@interface BaseTableViewController ()
@property (nonatomic, strong) UIView *placeholder;
@property (nonatomic, strong) UILabel *placeholderTitleLabel;
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;
@end

@implementation BaseTableViewController

#pragma mark init
- (void)initPlaceHolder
{
    self.placeholder = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.placeholder.tag = kPlaceHolderTag;
    
    // setup title label
    self.placeholderTitleLabel = [[UILabel alloc] init];
    self.placeholderTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderTitleLabel.backgroundColor = [UIColor clearColor];
    self.placeholderTitleLabel.textColor = [UIColor skyBlueColor];
    self.placeholderTitleLabel.font = [self.placeholderTitleLabel.font fontWithSize:45];
    
    // setup description label
    self.placeholderDescriptionLabel = [[UILabel alloc] init];
    self.placeholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.placeholderDescriptionLabel.textColor = [UIColor skyBlueColor];
    [self.placeholder addSubview:self.placeholderTitleLabel];
    [self.placeholder addSubview:self.placeholderDescriptionLabel];
    [self.tableView addSubview:self.placeholder];
    self.tableView.alwaysBounceVertical = self.placeholder.hidden = YES;
}

- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
    headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    [self.tableView addSubview:headerViewTemplate];
}

#pragma mark - getters and setters
- (void)setPlaceHolderTitle:(NSString*)title Description:(NSString*)description
{
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
}

- (void)showPlaceHolder:(BOOL)show
{
    self.tableView.alwaysBounceVertical = self.placeholder.hidden = (! show);
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}

@end
