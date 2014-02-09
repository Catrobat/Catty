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

#import "BrickCategoriesTableViewController.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "ColoredCell.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "ProgramDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BricksCollectionViewController.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"CategoryCell"

@interface BrickCategoriesTableViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray *brickCategoryNames;
@property (nonatomic, strong) NSArray *brickCategoryColors;
@end

@implementation BrickCategoriesTableViewController

#pragma view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [super initPlaceHolder];
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.brickCategoryNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kCategoryCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell isKindOfClass:[ColoredCell class]]) {
        ColoredCell *coloredCell = (ColoredCell*)cell;
        coloredCell.textLabel.text = self.brickCategoryNames[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.brickTypeColors[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    return (([Util getScreenHeight] - navBarHeight - kAddScriptCategoryTableViewBottomMargin) / [self.brickCategoryNames count]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//#pragma mark - Navigation
//// In a story board-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    static NSString *toNewScriptCategorySegueID = kSegueToNewScriptCategory;
//
//    UIViewController* destController = segue.destinationViewController;
//    if ([sender isKindOfClass:[ColoredCell class]]) {
//        if ([segue.identifier isEqualToString:toNewScriptCategorySegueID] &&
//            [destController respondsToSelector:@selector(setObject:)] &&
//            [destController respondsToSelector:@selector(setBrickCategoryType:)]) {
//            [destController performSelector:@selector(setObject:) withObject:self.object];
//            NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
//            ((BricksCollectionViewController*)destController).brickCategoryType = (kBrickCategoryType)indexPath.row;
//        }
//    }
//}

#pragma mark helpers

- (void)initTableView
{
  [super initTableView];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
  headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  [self.tableView addSubview:headerViewTemplate];
}

- (void)setupNavigationBar {
  NSString *title = NSLocalizedString(@"Categories", nil);
  self.title = title;
  self.navigationItem.title = title;
  
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCatergoryScriptsVC:)];
  self.navigationItem.leftBarButtonItems = @[closeButton];
}

#pragma mark actions

- (void)dismissCatergoryScriptsVC:(id)sender {
  if ([sender isKindOfClass:[UIBarButtonItem class]]) {
    if (!self.presentingViewController.isBeingPresented) {
      [self dismissViewControllerAnimated:YES completion:^{
        
      }];
    }
  }
}

#pragma mark private

- (NSArray*)brickCategoryNames
{
  if (! _brickCategoryNames)
    _brickCategoryNames = kBrickCategoryNames;
  return _brickCategoryNames;
}

- (NSArray*)brickTypeColors
{
  if (! _brickCategoryColors)
    _brickCategoryColors = kBrickCategoryColors;
  return _brickCategoryColors;
}

@end
