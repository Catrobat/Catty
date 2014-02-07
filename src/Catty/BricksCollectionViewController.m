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

#import "BricksCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SegueDefines.h"
#import "BrickCell.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"BrickCell"

@interface BricksCollectionViewController ()
@property (nonatomic, strong) NSArray *brickCategoryColors;
@end

@implementation BricksCollectionViewController

#pragma mark getters and setters
- (NSArray*)brickCategoryColors
{
    if (! _brickCategoryColors) {
        _brickCategoryColors = kBrickCategoryColors;
    }
    return _brickCategoryColors;
}

- (void)setBrickCategoryType:(kBrickCategoryType)brickCategoryType
{
    _brickCategoryType = brickCategoryType;
    // update title when brick category changed
    NSString *title = kBrickCategoryNames[_brickCategoryType];
    self.title = title;
    self.navigationItem.title = title;
}

#pragma mark init
- (void)initCollectionView
{
  //[super initCollectionView];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

#pragma view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [super initPlaceHolder];

    NSString *title = kBrickCategoryNames[self.brickCategoryType];
    self.title = title;
    self.navigationItem.title = title;
    self.collectionView.alwaysBounceVertical = YES;
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [BrickCell numberOfAvailableBricksForCategoryType:self.brickCategoryType];
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = [BrickCell brickCellHeightForCategoryType:self.brickCategoryType AndBrickType:indexPath.row];
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kCategoryCell;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[BrickCell class]]) {
        BrickCell *brickCell = (BrickCell*)cell;
        [brickCell convertToBrickCellForCategoryType:self.brickCategoryType AndBrickType:indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BrickCell class]]) {
        // TODO: implement
        NSLog(@"Perform backward (pop 2 VCs from navigation bar controller stack) segue");
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.brickCategoryColors[self.brickCategoryType];
}

@end
