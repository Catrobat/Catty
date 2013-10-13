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
#define kTableHeaderIdentifier @"Header"

@interface BaseTableViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) UIView *placeholder;
@property (nonatomic, strong) UILabel *placeholderTitleLabel;
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;
@end

@implementation BaseTableViewController

#pragma marks init
- (void)initPlaceHolder
{
  self.placeholder = [[UIView alloc] initWithFrame:self.tableView.bounds];
  
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
  CGRect frame = self.tableView.bounds;
  CGRect bounds = self.placeholderTitleLabel.bounds;
  #define placeholderTitlePaddingBottom 15.0f
  frame.origin.y = (frame.size.height/2.0f)-bounds.size.height-placeholderTitlePaddingBottom;
  frame.size.height = bounds.size.height;
  self.placeholderTitleLabel.frame = frame;

  // description label
  self.placeholderDescriptionLabel.text = description;
  [self.placeholderDescriptionLabel sizeToFit];
  bounds = self.placeholderDescriptionLabel.bounds;
  frame = self.tableView.bounds;
  frame.origin.y = (frame.size.height/2.0f);
  frame.size.height = bounds.size.height;
  self.placeholderDescriptionLabel.frame = frame;
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
