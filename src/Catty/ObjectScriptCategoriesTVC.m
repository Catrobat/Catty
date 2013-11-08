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

#import "ObjectScriptCategoriesTVC.h"
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
#import "OrderedDictionary.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"CategoryCell"
#define kFromCameraActionSheetButton @"camera"
#define kChooseImageActionSheetButton @"chooseImage"
#define kDrawNewImageActionSheetButton @"drawNewImage"

@interface ObjectScriptCategoriesTVC () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) OrderedDictionary *cells;
@end

@implementation ObjectScriptCategoriesTVC

#pragma marks - getters and setters
- (OrderedDictionary*)cells
{
  if (! _cells) {
    _cells = [OrderedDictionary dictionaryWithObjects:@[kScriptCategoryControlColor,
                                                        kScriptCategoryMotionColor,
                                                        kScriptCategorySoundColor,
                                                        kScriptCategoryLooksColor,
                                                        kScriptCategoryVariablesColor]
                                              forKeys:@[kScriptCategoryControlTitle,
                                                        kScriptCategoryMotionTitle,
                                                        kScriptCategorySoundTitle,
                                                        kScriptCategoryLooksTitle,
                                                        kScriptCategoryVariablesTitle]];
  }
  return _cells;
}

#pragma marks init
- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

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

#pragma view events
- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  [self initTableView];
  [super initPlaceHolder];
  [super setPlaceHolderTitle:([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)
                 Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil),
                              ([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)]];
  [super showPlaceHolder:(! (BOOL)[self.object.lookList count])];
  //[TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"New Programs", nil)];

  NSString *title = NSLocalizedString(@"Categories", nil);
  self.title = title;
  self.navigationItem.title = title;
  self.tableView.alwaysBounceVertical = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = kCategoryCell;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  NSArray *keys = [self.cells allKeys];
  NSString *key = [keys objectAtIndex:indexPath.row];
  if ([cell isKindOfClass:[ColoredCell class]]) {
    ColoredCell *coloredCell = (ColoredCell*)cell;
    coloredCell.textLabel.text = key;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *keys = [self.cells allKeys];
  NSString *key = [keys objectAtIndex:indexPath.row];
  cell.backgroundColor = self.cells[key];
//  UIView *view = [UIView new];
//  [view setBackgroundColor:[UIColor whiteColor]];
//  cell.selectedBackgroundView = view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
  return (([Util getScreenHeight] - navBarHeight - kAddScriptCategoryTableViewBottomMargin) / [self.cells count]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

#pragma mark - Navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}

@end
