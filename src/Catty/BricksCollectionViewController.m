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
#import "ScriptCollectionViewController.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"BrickCell"

@interface BricksCollectionViewController ()
@property (nonatomic, strong) NSArray *brickCategoryColors;
@end

@implementation BricksCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [super initPlaceHolder];
    [self setupNavigationBar];
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delaysContentTouches = NO;
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
//        BrickCell *brickCell = (BrickCell*)cell;
//        [brickCell convertToBrickCellForCategoryType:self.brickCategoryType AndBrickType:indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BrickCell *cell = (BrickCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (![self.presentedViewController isBeingPresented]) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
            [dnc postNotificationName:BrickCellAddedNotification object:nil userInfo:@{UserInfoKeyBrickCell: cell,
                                                                                       UserInfoSpriteObject: self.object}];
        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.brickCategoryColors[self.brickCategoryType];
}

- (void)setupNavigationBar {
    NSString *title = kBrickCategoryNames[self.brickCategoryType];
    self.title = title;
    self.navigationItem.title = title;

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissBricksCVC:)];
    self.navigationItem.leftBarButtonItems = @[closeButton];
}

#pragma mark actions

- (void)dismissBricksCVC:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (!self.presentingViewController.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

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

@end
