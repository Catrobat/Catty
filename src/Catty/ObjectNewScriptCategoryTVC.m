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

#import "ObjectNewScriptCategoryTVC.h"
#import "SegueDefines.h"
#import "ColoredCell.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"BrickCell"

@interface ObjectNewScriptCategoryTVC ()
@property (nonatomic, strong) NSDictionary *cells;
@end

@implementation ObjectNewScriptCategoryTVC

#pragma marks - getters and setters
- (NSDictionary*)cells
{
  if (! _cells) {
    if (self.categoryType == kControlBrick) {
      _cells = kControlBrickTypeNames;
    } else if (self.categoryType == kMotionBrick) {
//      _cells = kMotionBrickTypeNames;
    } else if (self.categoryType == kSoundBrick) {
      _cells = kSoundBrickTypeNames;
    } else if (self.categoryType == kLookBrick) {
//      _cells = kLookBrickTypeNames;
    } else if (self.categoryType == kVariableBrick) {
      _cells = kVariableBrickTypeNames;
    } else {
      _cells = [OrderedDictionary dictionary];
    }
  }
  return _cells;
}

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

  [self initTableView];
  [super initPlaceHolder];

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
//  if ([cell isKindOfClass:[UI class]]) {
//    ColoredCell *coloredCell = (ColoredCell*)cell;
//    coloredCell.textLabel.text = self.cells[[@(indexPath.row) stringValue]];
//  }
  cell.textLabel.text = self.cells[[@(indexPath.row) stringValue]];
  return cell;
}

@end
