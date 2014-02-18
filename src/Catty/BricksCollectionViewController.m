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

@interface BricksCollectionViewController ()
@property (nonatomic, strong) NSArray *selectableBricksSortedIndexes;
@property (nonatomic, strong) NSDictionary *selectableBricks;
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

    // register brick cells for current brick category
    NSDictionary *selectableBricks = self.selectableBricks;
    for (NSNumber *brickType in selectableBricks) {
        NSString *brickTypeName = selectableBricks[brickType];
        [self.collectionView registerClass:NSClassFromString([brickTypeName stringByAppendingString:@"Cell"]) forCellWithReuseIdentifier:brickTypeName];
    }
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
    return [self.selectableBricks count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return [self.selectableBricks count];
    return 1;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = self.view.frame.size.width;
//    CGFloat height = [BrickCell brickCellHeightForCategoryType:self.brickCategoryType AndBrickType:indexPath.row];
    CGFloat height = [BrickCell brickCellHeightForCategoryType:self.brickCategoryType AndBrickType:indexPath.section];
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSNumber *brickType = [self.selectableBricksSortedIndexes objectAtIndex:indexPath.row];
    NSNumber *brickType = [self.selectableBricksSortedIndexes objectAtIndex:indexPath.section];
    NSString *brickTypeName = [self.selectableBricks objectForKey:brickType];
    return [collectionView dequeueReusableCellWithReuseIdentifier:brickTypeName forIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    if ([BrickCell isScriptBrickCellForCategoryType:self.brickCategoryType AndBrickType:section]) {
        insets.top += 10.0f;
    }
    return insets;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BrickCell *cell = (BrickCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if (! [self.presentedViewController isBeingPresented]) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
            [dnc postNotificationName:BrickCellAddedNotification object:nil userInfo:@{UserInfoKeyBrickCell: cell,
                                                                                       UserInfoSpriteObject: self.object}];
        }];
    }
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
- (NSArray*)selectableBricksSortedIndexes
{
    if (! _selectableBricksSortedIndexes) {
        _selectableBricksSortedIndexes = [[self.selectableBricks allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }
    return _selectableBricksSortedIndexes;
}

- (NSDictionary*)selectableBricks
{
    if (! _selectableBricks) {
        NSArray *unselectableBricks = [kUnselectableBricks objectAtIndex:self.brickCategoryType];
        NSDictionary *allCategoriesAndBrickTypes = kClassNameBrickNameMap;
        NSInteger capacity = ([BrickCell numberOfAvailableBricksForCategoryType:self.brickCategoryType] - [unselectableBricks count]);
        NSMutableDictionary *selectableBricks = [NSMutableDictionary dictionaryWithCapacity:capacity];
        for (NSString *brickTypeName in allCategoriesAndBrickTypes) {
            kBrickCategoryType categoryType = (kBrickCategoryType) [allCategoriesAndBrickTypes[brickTypeName][@"categoryType"] integerValue];
            NSNumber *brickType = allCategoriesAndBrickTypes[brickTypeName][@"brickType"];
            if ((categoryType != self.brickCategoryType) || [unselectableBricks containsObject:brickType]) {
                continue;
            }
            [selectableBricks setObject:brickTypeName forKey:brickType];
        }
        _selectableBricks = [selectableBricks copy];
        // selectableBricksSortedIndexes should refetch/update on next getter-call
        self.selectableBricksSortedIndexes = nil;
    }
    return _selectableBricks;
}

- (void)setBrickCategoryType:(kBrickCategoryType)brickCategoryType
{
    _brickCategoryType = brickCategoryType;

    // selecatable bricks should refetch/update on next getter-call
    self.selectableBricks = nil;

    // update title when brick category changed
    NSString *title = kBrickCategoryNames[_brickCategoryType];
    self.title = title;
    self.navigationItem.title = title;
}

#pragma mark init
- (void)initCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

@end
