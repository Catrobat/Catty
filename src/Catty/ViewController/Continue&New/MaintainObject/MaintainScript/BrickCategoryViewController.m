/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "BrickCell.h"
#import "Brick.h"

@interface BrickCategoryViewController ()
@property (nonatomic, strong, readwrite) NSArray *scriptsAndBricks;
@property (nonatomic, assign) NSUInteger brickCategory;

@end

@implementation BrickCategoryViewController

#pragma mark - Init
- (instancetype)initWithBrickCategory:(kBrickCategoryType)type
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        self.scriptsAndBricks = [BrickManager.sharedBrickManager selectableBricksForCategoryType:type];
        self.brickCategory = type;
    }
    return self;
}

+ (BrickCategoryViewController*)brickCategoryViewControllerForPageIndex:(NSInteger)pageIndex
{
    if (pageIndex >= 0 && pageIndex < kCategoryCount) {
        return [[self alloc] initWithBrickCategory:pageIndex];
    }
    return nil;
}

#pragma mark - Getters
- (NSUInteger)pageIndex
{
    return self.brickCategory;
}

#pragma mark - UIViewController Delegates
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.collectionViewLayout = [UICollectionViewFlowLayout new];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setupSubviews];
}

#pragma mark - Setup
- (void)setupSubviews
{
    NSDictionary *allBrickTypes = [[BrickManager sharedBrickManager] classNameBrickTypeMap];
    for (NSString *className in allBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
    }
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.scriptsAndBricks count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    id<ScriptProtocol> scriptOrBrick = [self.scriptsAndBricks objectAtIndex:indexPath.item];
    NSString *brickCellIdentifier = NSStringFromClass(scriptOrBrick.class);
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickCellIdentifier
                                                                     forIndexPath:indexPath];
    brickCell.scriptOrBrick = scriptOrBrick;
    [brickCell setupBrickCell];
    return brickCell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    BrickCell *cell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSAssert(cell.scriptOrBrick, @"Error, no brick.");
    if ([self.delegate respondsToSelector:@selector(brickCategoryViewController:didSelectScriptOrBrick:)]) {
        [self.delegate brickCategoryViewController:self didSelectScriptOrBrick:cell.scriptOrBrick];
    }
}

#pragma mark - Collection View Layout
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    Brick *brick = [self.scriptsAndBricks objectAtIndex:indexPath.item];
    CGSize size = [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(brick.class)];
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CGRectGetHeight(self.navigationController.navigationBar.bounds) +
                            CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) +
                            kScriptCollectionViewTopInsets, 0.0f, kScriptCollectionViewBottomInsets, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.f;
}

@end
