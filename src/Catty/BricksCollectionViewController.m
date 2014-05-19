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
#import "SpriteObject.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@interface BricksCollectionViewController () <LXReorderableCollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *selectableBricksSortedIndexes;
@property (nonatomic, strong) NSDictionary *selectableBricks;
@end

@implementation BricksCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delaysContentTouches = NO;
    
    // register brick cells for current brick category
    NSDictionary *selectableBricks = self.selectableBricks;
    for (NSNumber *brickType in selectableBricks) {
        NSString *brickTypeName = selectableBricks[brickType];
        [self.collectionView registerClass:NSClassFromString([brickTypeName stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:brickTypeName];
    }
}

#pragma mark - getters and setters
- (NSArray*)selectableBricksSortedIndexes
{
    if (! _selectableBricksSortedIndexes) {
        _selectableBricksSortedIndexes = [[[self.selectableBricks allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    }
    return _selectableBricksSortedIndexes;
}

- (NSDictionary*)selectableBricks
{
    if (! _selectableBricks) {
        // hide unselectable bricks
        NSArray *allUnselectableBricks = kUnselectableBricksObject;
        if ([self.object isBackground]) {
            allUnselectableBricks = kUnselectableBricksBackgroundObject;
        }

        NSArray *unselectableBricks = [allUnselectableBricks objectAtIndex:self.brickCategoryType];
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

#pragma mark - initialization
- (void)initCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.darkBlueColor;
}


#pragma mark - application events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [BrickCell clearImageCache];
}

#pragma mark - actions
- (void)dismissCategoryScriptsVC:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (!self.presentingViewController.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.selectableBricks count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSNumber *brickTypeID = [self.selectableBricksSortedIndexes objectAtIndex:indexPath.section];
    NSString *brickTypeName = [self.selectableBricks objectForKey:brickTypeID];
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickTypeName forIndexPath:indexPath];
    brickCell.backgroundBrickCell = self.object.isBackground;
    brickCell.enabled = NO;
    [brickCell renderSubViews];
//    NSLog(@"frame = %@", NSStringFromCGRect(brickCell.bounds));
    return brickCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [NSNotificationCenter.defaultCenter postNotificationName:kBrickCellAddedNotification
                                                          object:nil
                                                        userInfo:@{ kUserInfoKeyBrickCell : brickCell,
                                                                    kUserInfoSpriteObject : self.object }];
    }];
}

#pragma mark - CollectionView FlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    return insets = section == 0 ?  UIEdgeInsetsMake(30.f, 0.0f, 0.0f, 0.0f) : UIEdgeInsetsMake(0.f, 0.0f, 0.0f, 0.0f);
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = [BrickCell brickCellHeightForCategoryType:self.brickCategoryType AndBrickType:indexPath.section];
    return CGSizeMake(width, height);
}


#pragma mark - LXReorderableCollectionViewDatasource

- (void)collectionView:(UICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
   willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    
    // TODO Fix reordering, crashed
    id object = [self.selectableBricksSortedIndexes objectAtIndex:fromIndexPath.section];
    [self.selectableBricksSortedIndexes removeObjectAtIndex:fromIndexPath.section];
    [self.selectableBricksSortedIndexes insertObject:object atIndex:toIndexPath.section];
    
//    id toTyp = [self.selectableBricksSortedIndexes objectAtIndex:toIndexPath.section];
//    id fromTyp = [self.selectableBricksSortedIndexes objectAtIndex:fromIndexPath.section];
//    
//    [self.selectableBricksSortedIndexes removeObjectAtIndex:toIndexPath.section];
//    [self.selectableBricksSortedIndexes insertObject:fromTyp atIndex:toIndexPath.section];
    
//    [self.selectableBricksSortedIndexes removeObjectAtIndex:fromIndexPath.section];
//    [self.selectableBricksSortedIndexes insertObject:toTyp atIndex:fromIndexPath.section];
    
}

@end
