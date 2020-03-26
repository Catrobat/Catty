/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "BrickCategoryViewController.h"
#import "BrickManager.h"
#import "Pocket_Code-Swift.h"

@interface BrickCategoryViewController ()
@property (nonatomic, strong) NSArray<id<BrickProtocol>> *bricks;

@end

@implementation BrickCategoryViewController

#pragma mark - Init
- (instancetype)initWithBrickCategory:(BrickCategory*)category andObject:(SpriteObject*)spriteObject
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        self.category = category;
        
        self.spriteObject = spriteObject;
        self.bricks = [[BrickManager sharedBrickManager] selectableBricksForCategoryType:category.type inBackground: spriteObject.isBackground];
    }
    return self;
}

#pragma mark - UIViewController Delegates
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.collectionViewLayout = [UICollectionViewFlowLayout new];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    if (@available(iOS 11, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setupSubviews];
}

#pragma mark - Setup
- (void)setupSubviews
{
    NSArray *allBricks = [[CatrobatSetup class] registeredBricks];
    for (id brick in allBricks) {
        NSString *className = NSStringFromClass([brick class]);
        [self.collectionView registerClass:[brick brickCell] forCellWithReuseIdentifier:className];
    }
    
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.view.backgroundColor = UIColor.whiteColor;
}

-(void)reloadData {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.collectionView reloadData];
        [self.collectionView setNeedsDisplay];
    });
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self reloadData];
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.bricks.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    id<BrickProtocol> brick = [self.bricks objectAtIndex:indexPath.item];
    
    NSString *brickCellIdentifier = NSStringFromClass(brick.class);
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickCellIdentifier
                                                                     forIndexPath:indexPath];
    brickCell.isInserting = YES;
    brickCell.scriptOrBrick = self.bricks[indexPath.item];
    [brickCell.scriptOrBrick setDefaultValuesForObject:self.spriteObject];
    [brickCell setupBrickCellinSelectionView:true inBackground: self.spriteObject.isBackground];
    [brickCell setNeedsDisplay];
    
    for (id subview in brickCell.subviews) {
        if ([subview isKindOfClass:[UIView class]]) {
            [(UIView*)subview setUserInteractionEnabled:NO];
        }
    }
    return brickCell;
}

-  (void)collectionView:(UICollectionView*)collectionView
didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    BrickCell *cell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSAssert(cell.scriptOrBrick, @"Error, no brick.");
    
    [Util incrementStatisticCountForBrick:cell.scriptOrBrick];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.brickSelected object:cell.scriptOrBrick];
    
    if ([self.delegate respondsToSelector:@selector(brickCategoryViewController:didSelectScriptOrBrick:)]) {
        [self.delegate brickCategoryViewController:self didSelectScriptOrBrick:cell.scriptOrBrick];
    }
}

#pragma mark - Collection View Layout
- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    id<BrickProtocol> brick = self.bricks[indexPath.item];
    return [BrickManager.sharedBrickManager sizeForBrick:brick];
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CGRectGetHeight(self.navigationController.navigationBar.bounds) +
                            CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) +
                            kScriptCollectionViewInset, 0.0f, kScriptCollectionViewInset, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.f;
}

@end
