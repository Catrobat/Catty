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
#import "Util.h"
#import "PlaceHolderView.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "LoopEndBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

@interface ScriptCollectionViewController () <UICollectionViewDelegate,
                                              LXReorderableCollectionViewDelegateFlowLayout,
                                              LXReorderableCollectionViewDataSource,
                                              UIViewControllerTransitioningDelegate,
                                              SingleBrickSelectionViewDelegate,
                                              BrickCellDelegate,
                                              BrickDetailViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) BrickScaleTransition *brickScaleTransition;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AHKActionSheet *brickSelectionMenu;
@property  (nonatomic, strong) BrickSelectionView *brickSelectionView;
@property (nonatomic, strong) NSArray *selectableBricks;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPaths;
@property (nonatomic, assign) BOOL selectedAllCells;
@property (nonatomic, strong) NSIndexPath *higherRankBrick;
@property (nonatomic, strong) NSIndexPath *lowerRankBrick;


@end

@implementation ScriptCollectionViewController

#pragma mark - events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolBar];
}

#pragma mark - Setup Collection View
- (void)setupCollectionView
{
    self.collectionView.backgroundColor = [UIColor darkBlueColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = [LXReorderableCollectionViewFlowLayout new];
    self.navigationController.title = self.title = kLocalizedScripts;

    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
#if kIsRelease // kIsRelease
    self.navigationItem.rightBarButtonItem.enabled = NO;
#endif // kIsRelease
    self.placeHolderView.title = kLocalizedScripts;
    [self showPlaceHolder:(! (BOOL)[self.object.scriptList count])];
    self.brickScaleTransition = [BrickScaleTransition new];
    self.selectedIndexPaths = [NSMutableDictionary dictionary];

    // register brick cells for current brick category
    NSDictionary *allBrickTypes = [[BrickManager sharedBrickManager] classNameBrickTypeMap];
    for (NSString *className in allBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
        [self.brickSelectionView.brickCollectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                                        forCellWithReuseIdentifier:className];
    }
}

#pragma mark - Getters and Setters
- (AHKActionSheet *)brickSelectionMenu
{
    if (!_brickSelectionMenu) {
        _brickSelectionMenu = [[AHKActionSheet alloc]initWithTitle:kLocalizedSelectBrickCategory];
        _brickSelectionMenu.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        _brickSelectionMenu.separatorColor = UIColor.skyBlueColor;
        _brickSelectionMenu.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f] ,
                                                    NSForegroundColorAttributeName : UIColor.skyBlueColor};
        _brickSelectionMenu.cancelButtonTextAttributes = @{NSForegroundColorAttributeName : UIColor.lightOrangeColor};
        _brickSelectionMenu.buttonTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        _brickSelectionMenu.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _brickSelectionMenu.automaticallyTintButtonImages = NO;

        __weak typeof(self) weakSelf = self;
        [_brickSelectionMenu addButtonWithTitle:kLocalizedControl
                                          image:[UIImage imageNamed:@"orange_indicator"]
                                   type:AHKActionSheetButtonTypeDefault
                                  handler:^(AHKActionSheet *actionSheet) {
                                      [weakSelf showBrickSelectionView:kControlBrick];
                                  }];
        [_brickSelectionMenu addButtonWithTitle:kLocalizedMotion
                                          image:[UIImage imageNamed:@"lightblue_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kMotionBrick];
                                        }];
        [_brickSelectionMenu addButtonWithTitle:kLocalizedSound
                                          image:[UIImage imageNamed:@"pink_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kSoundBrick];
                                        }];
        [_brickSelectionMenu addButtonWithTitle:kLocalizedLooks
                                          image:[UIImage imageNamed:@"green_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickSelectionView:kLookBrick];
                                        }];
        [_brickSelectionMenu addButtonWithTitle:kLocalizedVariables
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
        _blurView.tintColor = [UIColor darkBlueColor];
        _blurView.underlyingView = self.collectionView;
        _blurView.blurEnabled = YES;
        _blurView.blurRadius = 50.f;
        _blurView.dynamic = YES;
        _blurView.updateInterval = 0.1f;
        _blurView.alpha = 0.5f;
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
    
    [self.brickSelectionView showWithView:self.placeHolderView fromViewController:self completion:^{
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
    [self.navigationController setToolbarHidden:YES animated:YES];
    ScenePresenterViewController *vc = [[ScenePresenterViewController alloc] initWithProgram:[Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]]];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark BrickDetailViewController Delegate
- (void)brickDetailViewController:(BrickDetailViewController *)brickDetailViewController
                 viewDidDisappear:(BOOL)deleteBrick withBrickCell:(BrickCell *)brickCell copyBrick:(BOOL)copyBrick
{
    self.collectionView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self.collectionView reloadData];

    if (deleteBrick) {
        [self removeBrickWithIndexPath:self.selectedIndexPath];
    } else {
        if (copyBrick) {
            [self addBrickCellAction:brickCell copyBrick:copyBrick completionBlock:NULL];
        }
    }
}

#pragma mark - Collection View Datasource
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
        count = ((collectionView == self.brickSelectionView.brickCollectionView) ? 1 : 0);
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
            brickCell.selectButton.hidden = YES;
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
    if (self.selectedAllCells) {
        [brickCell selectedState:self.selectedAllCells setEditingState:self.editing];
    } else {
        NSString *key = [self keyWithSelectIndexPath:indexPath];
        BOOL selected = indexPath == self.selectedIndexPaths[key];
        [brickCell selectedState:selected setEditingState:self.editing];
    }
    [brickCell setupBrickCell];
    brickCell.delegate = self;
#if kIsRelease // kIsRelease
    brickCell.enabled = NO;
#endif // kIsRelease
    return brickCell;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGSize size = CGSizeZero;
    
    if (collectionView == self.collectionView) {
        if (indexPath.section < self.object.scriptList.count) {
            Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
            size = indexPath.item == 0 ? [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(script.class)]
            : [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass([[script.brickList objectAtIndex:indexPath.item - 1] class])];
        }

    } else {
        if (collectionView == self.brickSelectionView.brickCollectionView) {
            Brick *brick = [self.selectableBricks objectAtIndex:indexPath.section];
            size = [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(brick.class)];
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
    return kBrickOverlapHeight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BrickCell *cell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (! self.isEditing) {
        if (collectionView == self.collectionView) {
            self.selectedIndexPath =  indexPath;
            BrickDetailViewController *brickDetailViewcontroller = [BrickDetailViewController new];
            brickDetailViewcontroller.delegate = self;
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
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark - Reorderable Cells Delegate
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath
   willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section == toIndexPath.section) {
        Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
        [script.brickList removeObjectAtIndex:toIndexPath.item - 1];
        [script.brickList insertObject:toBrick atIndex:fromIndexPath.item - 1];
    } else {
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

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
                                willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.higherRankBrick = nil;
    self.lowerRankBrick = nil;
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
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                          canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    Script *fromScript = [self.object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    if (toIndexPath.item !=0) {
        if ([fromBrick isKindOfClass:[LoopBeginBrick class]]){
            return [self checkLoopBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        }
        else if ([fromBrick isKindOfClass:[LoopEndBrick class]]) {
            return [self checkLoopEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        }
        else if ([fromBrick isKindOfClass:[IfLogicBeginBrick class]]){
            return [self checkIfBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        }
        else if([fromBrick isKindOfClass:[IfLogicElseBrick class]]){
            return [self checkIfElseToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        }
        else if([fromBrick isKindOfClass:[IfLogicEndBrick class]]){
            return [self checkIfEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        }
        else{
            return (toIndexPath.item != 0);
        }
    }else{
        return NO;
    }

}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
#if kIsRelease // kIsRelease
    return NO;
#else // kIsRelease
    return ((self.isEditing || indexPath.item == 0) ? NO : YES);
#endif // kIsRelease
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
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:
                              [self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
    
    if (indexPath) {
        if (!selectButton.selected) {
            selectButton.selected = selectButton.touchInside;
            [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        } else {
            selectButton.selected = NO;
            [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
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
    
        if (![self.brickSelectionView active]) {
            self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

            UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(showBrickSelectionMenu)];
#if kIsRelease // kIsRelease
            add.enabled = NO;
#else // kIsRelease
            add.enabled = (! self.editing);
#endif // kIsRelease
            UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                                  target:self
                                                                                  action:@selector(playSceneAction:)];
            play.enabled = !self.editing;
            self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                                  flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
        } else {
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_close"]
                                                                     style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(showBrickSelectionView:)];
            UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_list"]
                                                                     style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(showBrickSelectionMenu)];
            
            self.toolbarItems = @[flexItem,invisibleButton, list, invisibleButton, flexItem,
                                  flexItem, flexItem, invisibleButton, done, invisibleButton, flexItem];
    
        }

//
//        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
//                                                                         style:0
//                                                                        target:self
//                                                                        action:@selector(deleteSelectedBricks)];
//        UIBarButtonItem *selectAllButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedSelectAllItems
//                                                                         style:0
//                                                                        target:self
//                                                                        action:@selector(selectAllBricks)];
//        self.toolbarItems = @[/*selectAllButton, */flexItem, deleteButton];

}

- (void)removeBrickWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item != 0) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (script.brickList.count) {
            [self.collectionView performBatchUpdates:^{
                Brick *brick =[script.brickList objectAtIndex:indexPath.item - 1];
                if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                    LoopBeginBrick *beginBrick = (LoopBeginBrick *)brick;
                    
                    NSInteger count = 0;
                    for (Brick *checkBrick in script.brickList) {
                        if ([checkBrick isEqual:beginBrick.loopEndBrick]) {
                            break;
                        }
                        count++;
                    }
                    [script.brickList removeObjectAtIndex:indexPath.item - 1];
                    [script.brickList removeObject:beginBrick.loopEndBrick];
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath,[NSIndexPath indexPathForItem:count inSection:indexPath.section]]];
                    
                }else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                    IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick *)brick;
                    
                    NSInteger countElse = 0;
                    NSInteger countEnd = 0;
                    for (Brick *checkBrick in script.brickList) {
                        if ([checkBrick isEqual:beginBrick.ifElseBrick]) {
                            
                        }else{
                           countElse++;
                        }
                        if ([checkBrick isEqual:beginBrick.ifEndBrick]) {
                            break;
                        }else{
                            countEnd++;
                        }
  
                    }
                    [script.brickList removeObjectAtIndex:indexPath.item - 1];
                    [script.brickList removeObject:beginBrick.ifElseBrick];
                    [script.brickList removeObject:beginBrick.ifEndBrick];
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath,[NSIndexPath indexPathForItem:countElse inSection:indexPath.section],[NSIndexPath indexPathForItem:countEnd inSection:indexPath.section]]];
                    
                }else{
                    [script.brickList removeObjectAtIndex:indexPath.item - 1];
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
            }];
        }
    } else {
        if (indexPath.section <= self.collectionView.numberOfSections) {
            [self.collectionView performBatchUpdates:^{
            [self.object.scriptList removeObjectAtIndex:indexPath.section];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
                [self showPlaceHolder:(! (BOOL)[self.object.scriptList count])];
            }];
            

        }
    }
}

- (void)removeBricksWithIndexPaths:(NSArray *)indexPaths
{
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    sortedIndexPaths = [[sortedIndexPaths reverseObjectEnumerator] allObjects];
    
    [self.collectionView performBatchUpdates:^{
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
            
            if (indexPath.item == 0) {
                [self.object.scriptList removeObject:script];
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } else {
                [script.brickList removeObjectAtIndex:indexPath.item - 1];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        }
    } completion:^(BOOL finished) {
        [self.selectedIndexPaths removeAllObjects];
        [self.collectionView reloadData];
        [self showPlaceHolder:(! (BOOL)[self.object.scriptList count])];
    }];
}

- (void)deleteSelectedBricks
{
    [self setEditing:NO animated:YES];
}

- (void)selectAllBricks
{
    self.selectedAllCells = YES;
    for (BrickCell *cell in self.collectionView.visibleCells) {
        cell.selectButton.selected = YES;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
    }
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
    [self showPlaceHolder:(! (BOOL)[self.object.scriptList count])];

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


- (NSString *)keyWithSelectIndexPath:(NSIndexPath *)indexPath
{
    return [NSString stringWithFormat:@"%@_%@", @(indexPath.section), @(indexPath.item)];
}

#pragma mark - Editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self setupToolBar];

    if (self.isEditing) {
        self.navigationItem.title = kLocalizedEditMenu;
        self.navigationItem.rightBarButtonItem.title = kLocalizedDelete;
        self.navigationItem.rightBarButtonItem.tintColor = UIColor.redColor;
        [UIView animateWithDuration:animated ? 0.5f : 0.0f  delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            for (BrickCell *brickCell in self.collectionView.visibleCells) {
                brickCell.center = CGPointMake(brickCell.center.x + kSelectButtonTranslationOffsetX, brickCell.center.y);
                brickCell.selectButton.alpha = 1.0f;
            }
        } completion:NULL];
    } else {
        self.navigationItem.title = kLocalizedScripts;
        self.navigationItem.rightBarButtonItem.tintColor = UIColor.lightOrangeColor;
        
        __weak ScriptCollectionViewController *weakself = self;
        [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0.0f usingSpringWithDamping:0.65f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             for (BrickCell *brickCell in self.collectionView.visibleCells) {
                                 brickCell.center = CGPointMake(self.view.center.x, brickCell.center.y);
                                 brickCell.selectButton.alpha = 0.0f;
                             }
                         } completion:^(BOOL finished) {
                             if (self.selectedIndexPaths.count && finished) {
                                 [weakself removeBricksWithIndexPaths:[self.selectedIndexPaths allValues]];
                                 weakself.selectedAllCells = NO;
                             }
                         }];
    }
}


#pragma mark - check movelogic

-(BOOL)checkLoopBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil))  {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *toScript = [self.object.scriptList objectAtIndex:toIndexPath.section];
            Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
            LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)fromBrick;
            if ([loopBeginBrick.loopEndBrick isEqual:toBrick]) {
                self.lowerRankBrick = toIndexPath;
                return NO;
            }else if([toBrick isKindOfClass:[IfLogicBeginBrick class]]||[toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]){
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
            }else{
                return YES;
            }
            
        }else{
            return NO;
        }
        
    }else{
        return NO;
    }
}

-(BOOL)checkLoopEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
{
        //DONTMOVE ?!
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil)) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            LoopEndBrick *endbrick = (LoopEndBrick*) fromBrick;
            if ([endbrick.loopBeginBrick isEqual:toBrick]) {
                self.higherRankBrick = toIndexPath;
                return NO;
            }else if([toBrick isKindOfClass:[IfLogicBeginBrick class]]||[toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]){
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
            }else{
                return YES;
            }
        }else{
            return NO;
        }
        
    }else{
        return NO;
    }
}

-(BOOL)checkIfBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil))  {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *toScript = [self.object.scriptList objectAtIndex:toIndexPath.section];
            Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
            IfLogicBeginBrick *ifBeginBrick = (IfLogicBeginBrick*)fromBrick;
            if ([ifBeginBrick.ifElseBrick isEqual:toBrick]) {
                self.lowerRankBrick = toIndexPath;
                return NO;
            }else if([ifBeginBrick.ifEndBrick isEqual:toBrick]) {
                return NO;
                
            }else if([toBrick isKindOfClass:[LoopBeginBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            } else if([toBrick isKindOfClass:[LoopEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            } else{
                return YES;
            }
            
        }else{
            return NO;
        }
    }else {
        return NO;
    }
}


-(BOOL)checkIfElseToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil)) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            if ([toBrick isKindOfClass:[IfLogicBeginBrick class]]) {
                IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick*)toBrick;
                if ([beginBrick.ifElseBrick isEqual:fromBrick]) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    return YES;
                }
            }else if([toBrick isKindOfClass:[IfLogicEndBrick class]] ){
                IfLogicEndBrick *beginBrick = (IfLogicEndBrick*)toBrick;
                if ([beginBrick.ifElseBrick isEqual:fromBrick]) {
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }else{
                    return YES;
                }
            }else if([toBrick isKindOfClass:[LoopBeginBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            } else if([toBrick isKindOfClass:[LoopEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            }else{
                return YES;
            }
            
        }else{
            
            return NO;
        }
        
    }else{
        return NO;
    }

}


-(BOOL)checkIfEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
{
    if (toIndexPath.item > self.higherRankBrick.item || self.higherRankBrick==nil) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            if([toBrick isKindOfClass:[IfLogicElseBrick class]] ){
                IfLogicElseBrick *beginBrick = (IfLogicElseBrick*)toBrick;
                if ([beginBrick.ifEndBrick isEqual:fromBrick]) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    return YES;
                }
            }else if([toBrick isKindOfClass:[LoopBeginBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            } else if([toBrick isKindOfClass:[LoopEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                    return NO;
                }else{
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
                
            }else{
                return YES;
            }
            
        }else{
            
            return NO;
        }
        
    }else{
        return NO;
    }
}


@end
