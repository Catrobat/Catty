/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "BrickSelectionViewController.h"
#import "BrickManager.h"
#import "BrickCell.h"
#import "BrickProtocol.h"
#import "Brick.h"

@interface BrickSelectionViewController ()
@property (nonatomic, strong) NSArray *bricks;
@property(nonatomic, strong) UIVisualEffectView *blurView;

@end

@implementation BrickSelectionViewController

- (instancetype)initWithBrickCategory:(kBrickCategoryType)type {
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _bricks = [BrickManager.sharedBrickManager selectableBricksForCategoryType:type];
        self.title = kBrickCategoryNames[type];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.collectionViewLayout = [UICollectionViewFlowLayout new];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self setupSubViews];
    [self setupNavBar];
}

- (void)setupSubViews {
    NSDictionary *allBrickTypes = [[BrickManager sharedBrickManager] classNameBrickTypeMap];
    for (NSString *className in allBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
    }
    
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.view.backgroundColor = UIColor.clearColor;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
}

- (void)setupNavBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Brick List", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showBrickList:)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view insertSubview:self.blurView belowSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.blurView.frame = self.view.bounds;
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _bricks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<BrickProtocol> brick = [self.bricks objectAtIndex:indexPath.item];
    NSString *brickCellIdentifier = NSStringFromClass(brick.class);
    BrickCell *brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickCellIdentifier
                                                                    forIndexPath:indexPath];
    brickCell.brick = [self.bricks objectAtIndex:indexPath.item];
    [brickCell setupBrickCell];
    return brickCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Collection View Layout

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
    Brick *brick = [self.bricks objectAtIndex:indexPath.item];
    CGSize size = [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(brick.class)];
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kScriptCollectionViewTopInsets, 0.0f, kScriptCollectionViewBottomInsets, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.f;
}

#pragma mark Barutton Actions

- (void)dismiss:(id)sender {
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)showBrickList:(id)sender {
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        __weak BrickSelectionViewController *weakself = self;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if ([weakself.delegate respondsToSelector:@selector(BrickCell:didSelectBrickCellButton:)]) {
                [weakself.delegate brickSelectionViewControllerdidSelectBrickListButton:weakself];
            }
        }];
    }
}

@end
