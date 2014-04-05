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

// TODO: outsource...
#define kSelectAllItemsTitle NSLocalizedString(@"Select all", nil)
#define kUnselectAllItemsTitle NSLocalizedString(@"Unselect all", nil)
#define kSelectAllItemsTag 0
#define kUnselectAllItemsTag 1

#define kTableHeaderIdentifier @"Header"

@interface BaseTableViewController ()
@property (nonatomic, strong) UIBarButtonItem *selectAllRowsButtonItem;
@property (nonatomic, strong) NSArray *editableSections;
@property (nonatomic, strong) UIBarButtonItem *normalModeRightBarButtonItem;
@property (nonatomic, strong) UIView *placeholder;
@property (nonatomic, strong) UILabel *placeholderTitleLabel;
@property (nonatomic, strong) UILabel *placeholderDescriptionLabel;
@end

@implementation BaseTableViewController

#pragma mark - getters and setters
- (NSArray*)editableSections
{
    if (! _editableSections) {
        _editableSections = [NSArray array];
    }
    return _editableSections;
}

- (UIBarButtonItem*)selectAllRowsButtonItem
{
    if (! _selectAllRowsButtonItem) {
        _selectAllRowsButtonItem = [[UIBarButtonItem alloc] initWithTitle:kSelectAllItemsTitle
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(selectAllRows:)];
    }
    return _selectAllRowsButtonItem;
}

#pragma mark - init
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

#pragma mark - table view delegates
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 3; // XXX: strange, but no corresponding enum value available for that...
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (! self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    // check if all rows are selected and if so, change SelectAll button to UnselectAll button
    BOOL allItemsInAllSectionsSelected = YES;
    for (NSNumber *section in self.editableSections) {
        if (! [self areAllCellsSelectedInSection:[section integerValue]]) {
            allItemsInAllSectionsSelected = NO;
            break;
        }
    }
    if (allItemsInAllSectionsSelected) {
        self.selectAllRowsButtonItem.tag = kUnselectAllItemsTag;
        self.selectAllRowsButtonItem.title = kUnselectAllItemsTitle;
    } else {
        self.selectAllRowsButtonItem.tag = kSelectAllItemsTag;
        self.selectAllRowsButtonItem.title = kSelectAllItemsTitle;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check if all rows are selected and if so, change SelectAll button to UnselectAll button
    BOOL allItemsInAllSectionsSelected = YES;
    for (NSNumber *section in self.editableSections) {
        if (! [self areAllCellsSelectedInSection:[section integerValue]]) {
            allItemsInAllSectionsSelected = NO;
            break;
        }
    }
    if (allItemsInAllSectionsSelected) {
        self.selectAllRowsButtonItem.tag = kUnselectAllItemsTag;
        self.selectAllRowsButtonItem.title = kUnselectAllItemsTitle;
    } else {
        self.selectAllRowsButtonItem.tag = kSelectAllItemsTag;
        self.selectAllRowsButtonItem.title = kSelectAllItemsTitle;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}

#pragma mark - segue handlers
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.isEditing) {
        return NO;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

#pragma mark - helpers
- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)setupEditingToolBar
{
    [self setupToolBar];
    self.selectAllRowsButtonItem.tintColor = [UIColor orangeColor];
    self.selectAllRowsButtonItem.title = kSelectAllItemsTitle;
    self.selectAllRowsButtonItem.tag = kSelectAllItemsTag;
}

- (BOOL)areAllCellsSelectedInSection:(NSInteger)section
{
    NSInteger totalNumberOfRows = [self.tableView numberOfRowsInSection:section];
    if (! totalNumberOfRows) {
        return NO;
    }

    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSInteger counter = 0;
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.section == section) {
            ++counter;
        }
    }
    return (totalNumberOfRows == counter);
}

- (void)changeToEditingMode:(id)sender editableSections:(NSArray*)editableSections
{
    self.editableSections = editableSections;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(exitEditingMode:)];
    self.navigationItem.hidesBackButton = YES;
    self.normalModeRightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = cancelButton;
    [self.tableView setEditing:YES animated:YES];
    self.editing = YES;
}

- (void)exitEditingMode:(id)sender
{
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = self.normalModeRightBarButtonItem;
    [self.tableView setEditing:NO animated:YES];
    [self setupToolBar];
    self.editing = NO;
}

- (void)selectAllRows:(id)sender
{
    BOOL selectAll = NO;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == kSelectAllItemsTag) {
            button.tag = kUnselectAllItemsTag;
            selectAll = YES;
            button.title = kUnselectAllItemsTitle;
        } else {
            button.tag = kSelectAllItemsTag;
            selectAll = NO;
            button.title = kSelectAllItemsTitle;
        }
    }
    for (NSNumber *section in self.editableSections) {
        for (NSInteger index = 0; index < [self.tableView numberOfRowsInSection:[section integerValue]]; ++index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[section integerValue]];
            if (selectAll) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
}

@end
