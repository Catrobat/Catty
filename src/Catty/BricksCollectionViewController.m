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
#import "BrickCell.h"
#import "ScriptCollectionViewController.h"
#import "SpriteObject.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "UIDefines.h"
#import "BrickSelectionSwipe.h"
#import "FXBlurView.h"
#import "BrickManager.h"
#import "BrickProtocol.h"
#import "Script.h"

@interface BricksCollectionViewController () <LXReorderableCollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource, UIScrollViewDelegate>

//############################################################################################################
//
// selectableBricksSortedIndexes has to be refactored due to UIDefines refactoring.
//
//############################################################################################################

//@property (nonatomic, strong) NSMutableArray *selectableBricksSortedIndexes;
@property (nonatomic, strong) NSArray *selectableBricks;
@property (nonatomic, strong) UIView *handleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FXBlurView *blurbackgroundView;

@end

#define kCollectionViewHeight 245.0f
#define kCollectionViewYOffset 35.0f

@implementation BricksCollectionViewController

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addInteractiveAnimator];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.scriptCollectionViewController = nil;
}

- (void)setupCollectionView
{
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.view.backgroundColor = UIColor.clearColor;
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.frame = CGRectMake(0.0f, kCollectionViewYOffset, self.view.bounds.size.width, kCollectionViewHeight);
    
    self.blurbackgroundView = [[FXBlurView alloc]initWithFrame:self.view.bounds];
    self.blurbackgroundView.tintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    self.blurbackgroundView.blurRadius = 40.f;
    self.blurbackgroundView.updateInterval = 0.3f;
    self.blurbackgroundView.underlyingView = self.scriptCollectionViewController.collectionView;
    [self.view addSubview:self.blurbackgroundView];
    [self.view sendSubviewToBack:self.blurbackgroundView];
    
    CALayer *overlayLayer = [CALayer layer];
    overlayLayer.frame = self.blurbackgroundView.bounds;
    overlayLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7f].CGColor;
    [self.blurbackgroundView.superview.layer insertSublayer:overlayLayer atIndex:1];
    
    self.handleView = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) / 2.0f) - (kHandleImageWidth / 2.0f), 10.0f, kHandleImageWidth, kHandleImageHeight)];
    UIImage *handleImage = [UIImage imageNamed:@"handle_image"];
    self.handleView.layer.contents = (__bridge id)handleImage.CGImage;
    [self.view insertSubview:self.handleView aboveSubview:self.collectionView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0f, 10.0f, 80.0f, 15.0f)];
    self.titleLabel.text = [kBrickCategoryNames objectAtIndex:self.brickCategoryType];
    self.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
//    self.titleLabel.textColor = [kBrickCategoryColors objectAtIndex:self.brickCategoryType];
    self.titleLabel.textColor = UIColor.skyBlueColor;
    [self.view insertSubview:self.titleLabel aboveSubview:self.collectionView];
}

- (void)addInteractiveAnimator
{
    id animator = [self.transitioningDelegate animationControllerForDismissedController:self];
    id interactor = [self.transitioningDelegate interactionControllerForDismissal:animator];
    
    if ([interactor respondsToSelector:@selector(attachToViewController:)]) {
        [interactor attachToViewController:self];
    }
}

#pragma mark - getters and setters
//- (NSArray*)selectableBricksSortedIndexes
//{
//    if (! _selectableBricksSortedIndexes) {
//        _selectableBricksSortedIndexes = [[self.selectableBricks sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
//    }
//    return _selectableBricksSortedIndexes;
//}

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

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:indexPath.section];
    NSString *brickCellName = [NSStringFromClass([brick class]) stringByAppendingString:@"Cell"];
    return CGSizeMake(CGRectGetWidth(self.view.bounds), [NSClassFromString(brickCellName) cellHeight]);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
//    BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
//        [NSNotificationCenter.defaultCenter postNotificationName:kBrickCellAddedNotification
//                                                          object:nil
//                                                        userInfo:@{ kUserInfoKeyBrickCell : brickCell,
//                                                                    kUserInfoSpriteObject : self.object }];
//    }];
}

#pragma mark - CollectionView FlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);

    id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:section];
    if ([brick isKindOfClass:[Script class]]) {
        insets.top += 10.0f;
    }
    return insets;
}

//#pragma mark - LXReorderableCollectionViewDatasource
//- (void)collectionView:(UICollectionView *)collectionView
//       itemAtIndexPath:(NSIndexPath *)fromIndexPath
//   willMoveToIndexPath:(NSIndexPath *)toIndexPath
//{
//    
//    // TODO Fix reordering, crashed
//    id object = [self.selectableBricksSortedIndexes objectAtIndex:fromIndexPath.section];
//    [self.selectableBricksSortedIndexes removeObjectAtIndex:fromIndexPath.section];
//    [self.selectableBricksSortedIndexes insertObject:object atIndex:toIndexPath.section];
//}

@end
