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
#import "BrickProtocol.h"
#import "Script.h"

@interface BricksCollectionViewController ()
@property (nonatomic, strong) NSArray *selectableBricks;
@end

@implementation BricksCollectionViewController

#pragma mark - getters and setters
- (NSArray*)selectableBricks
{
    if (! _selectableBricks) {
        _selectableBricks = [[BrickManager sharedBrickManager] selectableBricksForCategoryType:self.brickCategoryType];
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
    NSArray *selectableBricks = self.selectableBricks;
    for (id<BrickProtocol> brick in selectableBricks) {
        NSString *brickTypeName = NSStringFromClass([brick class]);
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
    id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:indexPath.section];
    NSString *brickCellName = [NSStringFromClass([brick class]) stringByAppendingString:@"Cell"];
    return CGSizeMake(self.view.frame.size.width, [NSClassFromString(brickCellName) cellHeight]);
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:indexPath.section];
    NSString *brickTypeName = NSStringFromClass([brick class]);
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickTypeName
                                                                     forIndexPath:indexPath];
    brickCell.brick = [self.selectableBricks objectAtIndex:indexPath.section];
    brickCell.enabled = NO;
    [brickCell renderSubViews];
    return brickCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);

    id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:section];
    if ([brick isKindOfClass:[Script class]]) {
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
