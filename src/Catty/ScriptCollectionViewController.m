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

#import "ScriptCollectionViewController.h"
#import "UIDefines.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ScenePresenterViewController.h"
#import "BrickCell.h"
#import "Script.h"
#import "StartScript.h"
#import "Brick.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "BrickManager.h"
#import "StartScriptCell.h"
#import "BrickScaleTransition.h"
#import "BrickDetailViewController.h"
#import "WhenScriptCell.h"
#import "FXBlurView.h"
#import "LanguageTranslationDefines.h"
#import "PlaceHolderView.h"
#import "BroadcastScriptCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "AHKActionSheet.h"
#import "BrickSelectionView.h"
#import "BrickManager.h"
#import "SingleBrickSelectionView.h"

@interface ScriptCollectionViewController () <UICollectionViewDelegate,
                                              LXReorderableCollectionViewDelegateFlowLayout,
                                              LXReorderableCollectionViewDataSource,
                                              UIViewControllerTransitioningDelegate,
                                              SingleBrickSelectionViewDelegate,
                                              BrickCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) BrickScaleTransition *brickScaleTransition;
@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AHKActionSheet *brickSelectionMenu;
@property  (nonatomic, strong) BrickSelectionView *brickSelectionView;
@property (nonatomic, strong) NSArray *selectableBricks;
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;

@end

@implementation ScriptCollectionViewController

#pragma mark - events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolBar];

    // register brick cells for current brick category
    NSDictionary *allBrickTypes = [[BrickManager sharedBrickManager] classNameBrickTypeMap];
    for (NSString *className in allBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
        
        [self.brickSelectionView.brickCollectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
    }
}

#pragma mark - initialization
- (void)setupCollectionView
{
    self.collectionView.backgroundColor = UIColor.backgroundColor;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = [LXReorderableCollectionViewFlowLayout new];

    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    self.placeHolderView = [[PlaceHolderView alloc]initWithTitle:kUIViewControllerPlaceholderTitleScripts];
    self.placeHolderView.frame = self.collectionView.bounds;
    [self.view addSubview:self.placeHolderView];
    self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
    self.brickScaleTransition = [BrickScaleTransition new];
    self.selectedIndexPaths = [NSMutableArray array];
}

#pragma mark - view events
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(brickAdded:) name:kBrickCellAddedNotification object:nil];
    [dnc addObserver:self selector:@selector(brickDetailViewDismissed:) name:kBrickDetailViewDismissed object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self name:kBrickCellAddedNotification object:nil];
    [dnc removeObserver:self name:kBrickDetailViewDismissed object:nil];
}

#pragma mark - Getters and Setters
- (AHKActionSheet *)brickSelectionMenu
{
    if (!_brickSelectionMenu) {
        _brickSelectionMenu = [[AHKActionSheet alloc]initWithTitle:NSLocalizedString(kSelectionMenuTitle, nil)];
        _brickSelectionMenu.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        _brickSelectionMenu.separatorColor = UIColor.skyBlueColor;
        _brickSelectionMenu.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f] ,
                                                    NSForegroundColorAttributeName : UIColor.skyBlueColor};
        _brickSelectionMenu.cancelButtonTextAttributes = @{NSForegroundColorAttributeName : UIColor.lightOrangeColor};
        _brickSelectionMenu.buttonTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        _brickSelectionMenu.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _brickSelectionMenu.automaticallyTintButtonImages = NO;

        __weak typeof(self) weakSelf = self;
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Control", nil)
                                          image:[UIImage imageNamed:@"orange_indicator"]
                                   type:AHKActionSheetButtonTypeDefault
                                  handler:^(AHKActionSheet *actionSheet) {
                                      [weakSelf showBrickSelectionView:kControlBrick];
                                  }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Motion", nil)
                                          image:[UIImage imageNamed:@"lightblue_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kMotionBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Sound", nil)
                                          image:[UIImage imageNamed:@"pink_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kSoundBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Looks", nil)
                                          image:[UIImage imageNamed:@"green_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kLookBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Variables", nil)
                                          image:[UIImage imageNamed:@"red_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kVariableBrick];
                                        }];
    }
    return _brickSelectionMenu;
}

- (BrickSelectionView *)brickSelectionView
{
    if (!_brickSelectionView) {
        _brickSelectionView = [[BrickSelectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(UIScreen.mainScreen.bounds) - kOffsetTopBrickSelectionView)];
        self.brickSelectionView.brickCollectionView.delegate = self;
        self.brickSelectionView.brickCollectionView.dataSource = self;
    }
    return _brickSelectionView;
}

- (FXBlurView *)blurView
{
    if (! _blurView) {
        _blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
        _blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _blurView.userInteractionEnabled = NO;
        _blurView.tintColor = UIColor.clearColor;
        _blurView.underlyingView = self.collectionView;
        _blurView.blurEnabled = YES;
        _blurView.blurRadius = 30.f;
        _blurView.dynamic = YES;
        _blurView.updateInterval = 0.1f;
        _blurView.alpha = 0.f;
        _blurView.hidden = YES;
        [self.view addSubview:self.blurView];
    }
    return _blurView;
}

#pragma mark - Brick Selection / Play Action

- (void)showBrickSelectionView:(kBrickCategoryType)type
{
    if (!self.brickSelectionView.active) {
        self.brickSelectionView.yOffset = kOffsetTopBrickSelectionView;
        self.brickSelectionView.textLabel.text = kBrickCategoryNames[type];
        self.brickSelectionView.tintColor = kBrickCategoryColors[type];
        self.selectableBricks = [BrickManager.sharedBrickManager selectableBricksForCategoryType:type];
    }
    
    [self.brickSelectionView showWithView:self.collectionView fromViewController:self completion:^{
        [self setupToolBar];
        [self.brickSelectionView.brickCollectionView reloadData];
    }];
}

- (void)showBrickSelectionMenu
{
    if (self.brickSelectionView.active) {
        [self.brickSelectionView dismissView:self withView:self.collectionView fastDismiss:NO completion:^{
            [self.brickSelectionView removeFromSuperview];
            [self setupToolBar];
        }];
    }

    [self.brickSelectionMenu show];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)selectButtonAction:(id)sender
{
    if ([sender isKindOfClass:SelectButton.class]) {
        SelectButton *selectButton = (SelectButton *)sender;
        selectButton.selected = YES;
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:
                                  [self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
        if (indexPath) {
            // TODO refactor later, maybe make NSSet
            if (![self.selectedIndexPaths containsObject:indexPath]) {
                [self.selectedIndexPaths addObject:indexPath];
            }
        }
        
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:[BrickDetailViewController class]]) {
         self.brickScaleTransition.transitionMode = TransitionModePresent;
        return self.brickScaleTransition;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:[BrickDetailViewController class]]) {
        self.brickScaleTransition.transitionMode = TransitionModeDismiss;
        return self.brickScaleTransition;
    }
    return nil;
}

#pragma mark - Notification

- (void)brickDetailViewDismissed:(NSNotification *)notification
{
    self.collectionView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self.collectionView reloadData];

    if  ([notification.userInfo[@"brickDeleted"] boolValue]) {
        [self removeBrickWithIndexPath:self.selectedIndexPath];
    } else {
        BOOL copy = [notification.userInfo[@"copy"] boolValue];
        if (copy && [notification.userInfo[@"copiedCell"] isKindOfClass:BrickCell.class]) {
            [self addBrickCellAction:notification.userInfo[@"copiedCell"] copyBrick:copy completionBlock:NULL];
        }
    }
}

#pragma mark - collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = 0;
    if (collectionView == self.collectionView) {
        count =  [self.object.scriptList count];
    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) count = self.selectableBricks.count;
    }
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (collectionView == self.collectionView) {
        Script *script = [self.object.scriptList objectAtIndex:section];
        if (! script) {
            NSError(@"This should never happen");
            abort();
        }
        count = ([script.brickList count] + 1); // because script itself is a brick in IDE too
    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) count = 1;
    }
    return count;
}

#pragma mark - UICollectionView Delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BrickCell *brickCell = nil;
    
    if (self.collectionView == collectionView) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (! script) {
            NSError(@"This should never happen");
            abort();
        }
        
        if (indexPath.item == 0) {
            // case it's a script brick
            NSString *scriptSubClassName = NSStringFromClass([script class]);
            brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:scriptSubClassName forIndexPath:indexPath];
            brickCell.brick = script;
        } else {
            // case it's a normal brick
            Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
            NSString *brickSubClassName = NSStringFromClass([brick class]);
            brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickSubClassName forIndexPath:indexPath];
            brickCell.brick = brick;
        }
        brickCell.enabled = YES;
    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) {
            id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:indexPath.section];
            NSString *brickTypeName = NSStringFromClass([brick class]);
            brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickTypeName
                                                                             forIndexPath:indexPath];
            brickCell.brick = [self.selectableBricks objectAtIndex:indexPath.section];
        }
    }

    [brickCell editing:self.isEditing];
    [brickCell setupBrickCell];
    brickCell.delegate = self;
    
    return brickCell;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGSize size = CGSizeZero;
    
    if (collectionView == self.collectionView) {
        CGFloat width = CGRectGetWidth(self.collectionView.bounds);
        
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (! script) {
            NSError(@"This should never happen");
            abort();
        }
                
        Class brickCellClass = nil;
        if (indexPath.row == 0) {
            // case it's a script brick
            NSString *scriptSubClassName = [NSStringFromClass([script class]) stringByAppendingString:@"Cell"];
            brickCellClass = NSClassFromString(scriptSubClassName);
        } else {
            // case it's a normal brick
            Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
            NSString *brickSubClassName = [NSStringFromClass([brick class]) stringByAppendingString:@"Cell"];
            brickCellClass = NSClassFromString(brickSubClassName);
        }
        
        CGFloat height = [brickCellClass cellHeight];
//        height -= kBrickOverlapHeight; // reduce height for overlapping
        
        // last brick in last section has no overlapping at the bottom
        if (indexPath.section == ([self.object.scriptList count] - 1)) {
            if (indexPath.row == [script.brickList count]) { // there are ([brickList count]+1) cells
//                height += kBrickOverlapHeight;
            }
        }
        size = CGSizeMake(width, height);
        
    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) {
            id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:indexPath.section];
            NSString *brickCellName = [NSStringFromClass([brick class]) stringByAppendingString:@"Cell"];
            size = CGSizeMake(CGRectGetWidth(self.view.bounds), [NSClassFromString(brickCellName) cellHeight]);
        }
    }

    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (collectionView == self.collectionView) {
        insets = UIEdgeInsetsMake(kScriptCollectionViewTopInsets, 0.0f, kScriptCollectionViewBottomInsets, 0.0f);
    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) {
            insets = UIEdgeInsetsMake(0.0f, 0.0f, kScriptCollectionViewBottomInsets, 0.0f);
            
            id<BrickProtocol> brick = [self.selectableBricks objectAtIndex:section];
            if ([brick isKindOfClass:[Script class]]) {
                insets.top += 10.0f;
            }
            return insets;
        }
    }
    
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BrickCell *cell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!self.isEditing) {
        if (collectionView == self.collectionView) {
            self.selectedIndexPath =  indexPath;
            BrickDetailViewController *brickDetailViewcontroller = [BrickDetailViewController new];
            brickDetailViewcontroller.brickCell = cell;
            self.brickScaleTransition.cell = cell;
            self.brickScaleTransition.touchRect = cell.frame;
            brickDetailViewcontroller.transitioningDelegate = self;
            brickDetailViewcontroller.modalPresentationStyle = UIModalPresentationCustom;
            self.collectionView.userInteractionEnabled = NO;
            [self presentViewController:brickDetailViewcontroller animated:YES completion:^{
                self.navigationController.navigationBar.userInteractionEnabled = NO;
            }];
        } else {
            if ([collectionView isKindOfClass:self.brickSelectionView.brickCollectionView.class]) {
                
                [self.brickSelectionView dismissView:self withView:self.collectionView fastDismiss:YES completion:^{
                    [self.brickSelectionView removeFromSuperview];
                    [self setupToolBar];
                    
                    SingleBrickSelectionView *singleBrickSelectionView = [[SingleBrickSelectionView alloc] initWithFrame:self.view.bounds];
                    singleBrickSelectionView.delegate = self;
                    [singleBrickSelectionView showSingleBrickSelectionViewWithBrickCell:cell fromView:self.view
                                                                              belowView:self.collectionView completion:NULL];
                }];
            }
        }
    }
}

#pragma mark - Reorderable Cells Delegate
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                      willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if ([@(fromIndexPath.section) isEqualToNumber:@(toIndexPath.section)]) {
        Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
        [script.brickList removeObjectAtIndex:toIndexPath.item - 1];
        [script.brickList insertObject:toBrick atIndex:fromIndexPath.item - 1];
    } else {
        if (![@(fromIndexPath.section) isEqualToNumber:@(toIndexPath.section)]) {
            Script *toScript = [self.object.scriptList objectAtIndex:toIndexPath.section];
            Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
            
            Script *fromScript = [self.object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
            
            [toScript.brickList removeObjectAtIndex:toIndexPath.item -1];
            [fromScript.brickList removeObjectAtIndex:fromIndexPath.item - 1];
            [toScript.brickList insertObject:fromBrick atIndex:toIndexPath.item - 1];
            [toScript.brickList insertObject:toBrick atIndex:toIndexPath.item];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
                                willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.25f animations:^{
        self.navigationController.navigationBar.alpha = 0.01f;
        self.navigationController.toolbar.alpha = 0.01f;
    } completion:^(BOOL finished) {
        collectionView.userInteractionEnabled = NO;
        BrickCell *cell = (BrickCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell animateBrick:NO];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
                                   didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.25f animations:^{
         self.navigationController.navigationBar.alpha = 1.0f;
         self.navigationController.toolbar.alpha = 1.0f;
    } completion:^(BOOL finished) {
        collectionView.userInteractionEnabled = YES;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                          canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return (toIndexPath.item != 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((self.isEditing || indexPath.item == 0) ? NO : YES);
}

#pragma mark - Add brick Delegate
- (void)singleBrickSelectionView:(SingleBrickSelectionView *)singleBrickSelectionView didShowWithBrick:(id<BrickProtocol>)brick
              replicantBrickView:(UIView *)brickView
{
    // TODO just handle/add normal bricks at the moment
    NSIndexPath *indexPath;
    if (self.collectionView.visibleCells.count) {
        indexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMidY(self.collectionView.bounds))];
        
        if (indexPath.item == 0) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.item + 1 inSection:indexPath.section];
        }
    }
    
    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    
    __weak typeof(self.collectionView) weakCollectionView = self.collectionView;
    [self insertBrick:brick atIndexPath:indexPath intoScriptList:script copy:NO completion:^{
        NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        
        BrickCell *newCell = (BrickCell *)[weakCollectionView cellForItemAtIndexPath:newCellIndexPath];
        CGFloat yOffset = weakCollectionView.contentOffset.y;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.5f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 brickView.center = CGPointMake(CGRectGetMidX(newCell.bounds), newCell.center.y - yOffset);
                                 singleBrickSelectionView.dimview.alpha = 0.0f;
                                 brickView.layer.shadowOpacity = 0.0f;
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     newCell.alpha = 1.0f;
                                     [singleBrickSelectionView removeFromSuperview];
                                     [newCell animateBrick:YES];
                                 }
                             }];
        });
    }];
}

#pragma mark - Brick Cell Delegate
- (void)BrickCell:(BrickCell *)brickCell didSelectBrickCellButton:(SelectButton *)selectButton
{
    selectButton.selected = YES;
}

#pragma mark - segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* toSceneSegueID = kSegueToScene;
    UIViewController* destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.identifier isEqualToString:toSceneSegueID]) {
            if ([destController isKindOfClass:[ScenePresenterViewController class]]) {
                ScenePresenterViewController* scvc = (ScenePresenterViewController*) destController;
                if ([scvc respondsToSelector:@selector(setProgram:)]) {
                    [scvc setController:(UITableViewController *)self];
                    [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
                }
            }
        }
    }
}

#pragma mark - helpers

- (void)setupToolBar
{
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = UIColor.orangeColor;
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
    if (!self.editing) {
        if (![self.brickSelectionView active]) {
            self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            
            UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(showBrickSelectionMenu)];
            UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                                  target:self
                                                                                  action:@selector(playSceneAction:)];

            self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                                  flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
        } else {
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_close"]
                                                                     style:UIBarButtonItemStyleBordered target:self
                                                                    action:@selector(showBrickSelectionView:)];
            UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_list"]
                                                                     style:UIBarButtonItemStyleBordered target:self
                                                                    action:@selector(showBrickSelectionMenu)];
            
            self.toolbarItems = @[flexItem,invisibleButton, list, invisibleButton, flexItem,
                                  flexItem, flexItem, invisibleButton, done, invisibleButton, flexItem];
        }
    } else {
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kUIBarButtonItemTitleDelete
                                                                         style:0
                                                                        target:self
                                                                        action:@selector(removeSelectedeBricks::)];
        UIBarButtonItem *selectAllButton = [[UIBarButtonItem alloc] initWithTitle:kUIBarButtonItemTitleSelectAllItems
                                                                         style:0
                                                                        target:self
                                                                        action:@selector(selectAllBricks:)];
        self.toolbarItems = @[selectAllButton, flexItem, deleteButton];
    }

}

- (void)removeBrickWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item != 0) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (script.brickList.count) {
            [self.collectionView performBatchUpdates:^{
                [script.brickList removeObjectAtIndex:indexPath.item - 1];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
            }];
        }
    } else {
        if (indexPath.section <= self.collectionView.numberOfSections) {
            Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
            [self.collectionView performBatchUpdates:^{
                [self.object.scriptList removeObject:script];
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
                self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
            }];
        }
    }
}


- (void)removeSelectedeBricks:(NSArray *)objects
{
    
}

- (void)selectAllBricks
{
    
}

- (void)addBrickCellAction:(BrickCell*)brickCell copyBrick:(BOOL)copy completionBlock:(void(^)())completionBlock
{
    if (! brickCell) {
        return;
    }

    // convert brickCell to brick
    NSString *brickCellClassName = NSStringFromClass([brickCell class]);
    NSString *brickOrScriptClassName = [brickCellClassName stringByReplacingOccurrencesOfString:@"Cell" withString:@""];
    id brickOrScript = [[NSClassFromString(brickOrScriptClassName) alloc] init];
    if (! [brickOrScript conformsToProtocol:@protocol(BrickProtocol)]) {
        NSError(@"Given object does not implement BrickProtocol...");
        abort();
    }

    if ([brickOrScript isKindOfClass:[Brick class]]) {
        Script *script = nil;
        // automatically create new script if the object does not contain any of them
        if (! [self.object.scriptList count]) {
            script = [[StartScript alloc] init];
            script.allowRunNextAction = YES;
            script.object = self.object;
            [self.object.scriptList addObject:script];
        }
        
        script = [self.object.scriptList objectAtIndex:self.selectedIndexPath.section];
        Brick *brick = (Brick*)brickOrScript;
        brick.object = self.object;
        
        [self insertBrick:brick atIndexPath:self.selectedIndexPath intoScriptList:script copy:copy completion:NULL];
        
    } else if ([brickOrScript isKindOfClass:[Script class]]) {
        Script *script = (Script*)brickOrScript;
        script.object = self.object;
        [self.object.scriptList addObject:script];
    } else {
        NSError(@"Unknown class type given...");
        abort();
    }
    self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;

    if (completionBlock) completionBlock();
}

- (void)insertBrick:(Brick *)brick atIndexPath:(NSIndexPath *)indexPath intoScriptList:(Script *)script copy:(BOOL)copy completion:(void(^)())completionBlock
{
    for (BrickCell *cell in self.collectionView.visibleCells) {
        [cell animateBrick:NO];
    }
    
    if (copy) {
        [self.collectionView performBatchUpdates:^{
            [script.brickList insertObject:brick atIndex:indexPath.item ];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            if (finished) {
                [self.collectionView reloadData];
            }
        }];
    } else {
        [self.collectionView performBatchUpdates:^{
            if (!script.brickList.count) {
                [script.brickList addObject:brick];
                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            } else {
                [script.brickList insertObject:brick atIndex:indexPath.item];
                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            }
            
        } completion:^(BOOL finished) {
            if (finished) {
                NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath, newCellIndexPath]];
                BrickCell *newCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:newCellIndexPath];
                newCell.alpha = 0.0f;
                if (completionBlock) completionBlock();
            }
        }];
    }
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self setupToolBar];
    
    if (self.isEditing) {
        self.navigationItem.title = kUINavigationItemTitleEditMenu;
        
        for (BrickCell *brickCell in self.collectionView.visibleCells) {
            [UIView animateWithDuration:0.7f  delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                brickCell.center = CGPointMake(brickCell.center.x + kDeleteButtonTranslationOffsetX, brickCell.center.y);
                brickCell.selectButton.alpha = 1.0f;
                } completion:NULL];
        }
        
    } else {
        self.navigationItem.title = kUITableViewControllerMenuTitleScripts;
        for (BrickCell *brickCell in self.collectionView.visibleCells) {
            [UIView animateWithDuration:0.5 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:2.5f options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                brickCell.center = CGPointMake(self.view.center.x, brickCell.center.y);
                brickCell.selectButton.alpha = 0.0f;
            } completion:NULL];
        }
    }
}

@end
