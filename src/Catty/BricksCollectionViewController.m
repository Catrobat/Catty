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
#import "BrickManager.h"

@interface BricksCollectionViewController ()
@property (nonatomic, strong) NSArray *selectableBricksSortedIndexes;
@property (nonatomic, strong) NSDictionary *selectableBricks;
@end

@implementation BricksCollectionViewController

#pragma mark - getters and setters
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
        // hide unselectable bricks
        NSArray *allUnselectableBricks = kUnselectableBricksObject;
        if ([self.object isBackground]) {
            allUnselectableBricks = kUnselectableBricksBackgroundObject;
        }

        NSArray *unselectableBricks = [allUnselectableBricks objectAtIndex:self.brickCategoryType];
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        NSDictionary *allBrickTypes = [brickManager classNameBrickTypeMap];
        NSInteger capacity = ([brickManager numberOfAvailableBricksForCategoryType:self.brickCategoryType] - [unselectableBricks count]);
        NSMutableDictionary *selectableBricks = [NSMutableDictionary dictionaryWithCapacity:capacity];
        for (NSString *className in allBrickTypes) {
            NSNumber *brickType = allBrickTypes[className];
            kBrickCategoryType categoryType = [brickManager brickCategoryTypeForBrickType:[brickType unsignedIntegerValue]];
            if ((categoryType != self.brickCategoryType) || [unselectableBricks containsObject:brickType]) {
                continue;
            }
            [selectableBricks setObject:className forKey:brickType];
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
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [self setupNavigationBar];
    self.collectionView.scrollEnabled = YES;
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // @INFO: we use 1 section per brick to easily circumvent the inset-problem...
    //        otherwise we probably have to use a custom CVC-layout...
    return [self.selectableBricks count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = self.view.frame.size.width;
    // TODO: outsource this line as helper method to BrickManager
    kBrickType brickType = (kBrickType)(self.brickCategoryType * 100 + indexPath.section);
    CGFloat height = [BrickCell brickCellHeightForBrickType:brickType];
    return CGSizeMake(width, height);
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSNumber *brickType = [self.selectableBricksSortedIndexes objectAtIndex:indexPath.section];
    NSString *brickTypeName = [self.selectableBricks objectForKey:brickType];
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickTypeName forIndexPath:indexPath];
    brickCell.backgroundBrickCell = self.object.isBackground;
    brickCell.enabled = NO;
    [brickCell renderSubViews];
    return brickCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    BrickManager *brickManager = [BrickManager sharedBrickManager];
    // TODO: outsource this line as helper method to BrickManager
    kBrickType brickType = (kBrickType)(self.brickCategoryType * 100 + section);
    if ([brickManager isScriptBrickForBrickType:brickType]) {
        insets.top += 10.0f;
    }
    return insets;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc postNotificationName:kBrickCellAddedNotification
                           object:nil
                         userInfo:@{ kUserInfoKeyBrickCell : brickCell,
                                     kUserInfoSpriteObject : self.object }];
    }];
}

#pragma mark - helpers
- (void)setupNavigationBar
{
    self.navigationItem.title = self.title = [kBrickCategoryNames objectAtIndex:self.brickCategoryType];
    UIBarButtonItem *closeButton;
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(dismissCategoryScriptsVC:)];
    self.navigationItem.rightBarButtonItems = @[closeButton];
}

@end
