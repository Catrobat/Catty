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
#import "BrickCategoriesTableViewController.h"
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
#import "BricksCollectionViewController.h"

@interface ScriptCollectionViewController () <UICollectionViewDelegate, LXReorderableCollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource, UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) NSDictionary *classNameBrickNameMap;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) BrickScaleTransition *brickScaleTransition;
@property (nonatomic, strong) FXBlurView *dimView;
@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) NSIndexPath *addedIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AHKActionSheet *brickSelectionMenu;


@end

@implementation ScriptCollectionViewController

#pragma mark - events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolBar];
    
    // register brick cells for current brick category
    NSDictionary *allCategoriesAndBrickTypes = self.classNameBrickNameMap;
    for (NSString *brickTypeName in allCategoriesAndBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([brickTypeName stringByAppendingString:@"Cell"]) forCellWithReuseIdentifier:brickTypeName];
    }
}

#pragma mark - Getters and Setters
- (NSDictionary*)classNameBrickNameMap
{
    static NSDictionary *classNameBrickNameMap = nil;
    if (classNameBrickNameMap == nil) {
        classNameBrickNameMap = kClassNameBrickNameMap;
    }
    return classNameBrickNameMap;
}

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

        __weak ScriptCollectionViewController *weakSelf = self;
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Control", nil)
                                          image:[UIImage imageNamed:@"orange_indicator"]
                                   type:AHKActionSheetButtonTypeDefault
                                  handler:^(AHKActionSheet *actionSheet) {
                                      [weakSelf showBrickCategoryCVC:kControlBrick];
                                  }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Motion", nil)
                                          image:[UIImage imageNamed:@"lightblue_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickCategoryCVC:kMotionBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Sound", nil)
                                          image:[UIImage imageNamed:@"pink_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickCategoryCVC:kSoundBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Looks", nil)
                                          image:[UIImage imageNamed:@"green_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickCategoryCVC:kLookBrick];
                                        }];
        
        [_brickSelectionMenu addButtonWithTitle:NSLocalizedString(@"Variables", nil)
                                          image:[UIImage imageNamed:@"red_indicator"]
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf showBrickCategoryCVC:kVariableBrick];
                                        }];
    }
    return _brickSelectionMenu;
}

#pragma mark - Brick Selection Menu Action

- (void)showBrickCategoryCVC:(kBrickCategoryType)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    BricksCollectionViewController *brickCategoryCVC;
    brickCategoryCVC = (BricksCollectionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"BricksDetailViewCollectionViewController"];
    brickCategoryCVC.brickCategoryType = type;
    brickCategoryCVC.object = self.object;
    [self presentViewController:brickCategoryCVC animated:YES
                                              completion:NULL];
}


- (FXBlurView *)dimView
{
    if (! _dimView) {
        _dimView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
        _dimView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _dimView.userInteractionEnabled = NO;
        _dimView.tintColor = UIColor.clearColor;
        _dimView.underlyingView = self.collectionView;
        _dimView.blurEnabled = YES;
        _dimView.blurRadius = 20.f;
        _dimView.dynamic = YES;
        _dimView.updateInterval = 1.0f;
        _dimView.alpha = 0.f;
        _dimView.hidden = YES;
        [self.view addSubview:self.dimView];
    }
    return _dimView;
}

#pragma mark - initialization
- (void)setupCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.darkBlueColor;
    self.view.backgroundColor = UIColor.darkBlueColor;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    self.placeHolderView = [[PlaceHolderView alloc]initWithTitle:kUIViewControllerPlaceholderTitleScripts];
    self.placeHolderView.frame = self.collectionView.bounds;
    [self.view addSubview:self.placeHolderView];
    self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
    
    self.brickScaleTransition = [BrickScaleTransition new];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [BrickCell clearImageCache];
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    self.brickScaleTransition.transitionMode = TransitionModePresent;
    return self.brickScaleTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.brickScaleTransition.transitionMode = TransitionModeDismiss;
    return self.brickScaleTransition;
}

#pragma mark - actions
- (void)addBrickAction:(id)sender
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//    BrickCategoriesTableViewController *brickCategoryTVC;
//    brickCategoryTVC = [storyboard instantiateViewControllerWithIdentifier:@"BrickCategoriesTableViewController"];
//    brickCategoryTVC.object = self.object;
//    UINavigationController *navigationController = [[UINavigationController alloc]
//                                                    initWithRootViewController:brickCategoryTVC];
//    [self presentViewController:navigationController animated:YES completion:NULL];
    [self.brickSelectionMenu show];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)scriptDeleteButtonAction:(id)sender
{
    if ([sender isKindOfClass:ScriptDeleteButton.class]) {
        ScriptDeleteButton *button = (ScriptDeleteButton *)sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:button.center fromView:button.superview]];
        if (indexPath) {
            [self removeScriptSectionWithIndexPath:indexPath];
        }

    }
}

#pragma mark - Notification
- (void)brickAdded:(NSNotification*)notification
{
    if (notification.userInfo) {
        __weak UICollectionView *weakCollectionView = self.collectionView;
        __weak ScriptCollectionViewController *weakself = self;
        if (self.object.scriptList) {
            [self addBrickCellAction:notification.userInfo[kUserInfoKeyBrickCell] copyBrick:NO completionBlock:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself scrollToLastbrickinCollectionView:weakCollectionView completion:NULL];
                });
            }];
        }
    }
}

- (void)brickDetailViewDismissed:(NSNotification *)notification
{
    self.collectionView.userInteractionEnabled = YES;
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self.collectionView reloadData];
    
    if  ([notification.userInfo[@"brickDeleted"] boolValue]) {
        [notification.userInfo[@"isScript"] boolValue] ? [self removeScriptSectionWithIndexPath:self.selectedIndexPath] :
                                                         [self removeBrickFromScriptCollectionViewFromIndex:self.selectedIndexPath];
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
    return [self.object.scriptList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Script *script = [self.object.scriptList objectAtIndex:section];
    if (! script) {
        NSError(@"This should never happen");
        abort();
    }
    return ([script.brickList count] + 1); // because script itself is a brick in IDE too
}

#pragma mark - collection view delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    if (! script) {
        NSError(@"This should never happen");
        abort();
    }

    BrickCell *brickCell = nil;
    if (indexPath.row == 0) {
        // case it's a script brick
        NSString *scriptSubClassName = NSStringFromClass([script class]);
        brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:scriptSubClassName forIndexPath:indexPath];
        [brickCell.deleteButton addTarget:self action:@selector(scriptDeleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [brickCell setBrickEditing:self.isEditing];
        
        // overwriten values, needs refactoring later
        brickCell.alpha = 1.0f;
        brickCell.userInteractionEnabled = YES;
    } else {
        // case it's a normal brick
        Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
        NSString *brickSubClassName = NSStringFromClass([brick class]);
        brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:brickSubClassName forIndexPath:indexPath];
        [brickCell setBrickEditing:self.isEditing];
        brickCell.hideDeleteButton = YES;
    }
    brickCell.backgroundBrickCell = self.object.isBackground;
    brickCell.enabled = YES;
    [brickCell renderSubViews];
    
    return brickCell;
}

#pragma mark - CollectionView layout
- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = self.view.frame.size.width;
    kBrickCategoryType categoryType = kControlBrick;
    NSInteger brickType = kProgramStartedBrick;
    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    if (! script) {
        NSError(@"This should never happen");
        abort();
    }

    NSDictionary *allCategoriesAndBrickTypes = self.classNameBrickNameMap;
    if (indexPath.row == 0) {
        // case it's a script brick
        categoryType = kControlBrick;
        NSString *scriptSubClassName = NSStringFromClass([script class]);
        for (NSString *brickTypeName in allCategoriesAndBrickTypes) {
            if ([brickTypeName isEqualToString:scriptSubClassName]) {
                brickType = [allCategoriesAndBrickTypes[brickTypeName][@"brickType"] integerValue];
                break;
            }
        }
    } else {
        // case it's a normal brick
        Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
        NSString *brickSubClassName = NSStringFromClass([brick class]);
        for (NSString *brickTypeName in allCategoriesAndBrickTypes) {
            if ([brickTypeName isEqualToString:brickSubClassName]) {
                categoryType = (kBrickCategoryType)[allCategoriesAndBrickTypes[brickTypeName][@"categoryType"] integerValue];
                brickType = [allCategoriesAndBrickTypes[brickTypeName][@"brickType"] integerValue];
                break;
            }
        }
    }
    CGFloat height = [BrickCell brickCellHeightForCategoryType:categoryType AndBrickType:brickType];

    // TODO: outsource all consts
    height -= 4.0f; // reduce height for overlapping

    // if last brick in last section => no overlapping and no height deduction!
    if (indexPath.section == ([self.object.scriptList count] - 1)) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (! script) {
            NSError(@"This should never happen");
            abort();
        }
        if (indexPath.row == [script.brickList count]) { // NOTE: there are ([brickList count]+1) cells!!
            height += 4.0f;
        }
    }
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    // !!! PLEASE DO NOT COMMENT THESE LINES OUT !!!
    // margin between CVC-sections as you can see in Catroid's PocketCode version
    // TODO: outsource all consts
    return UIEdgeInsetsMake(10, 0, 5, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BrickCell *cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.selectedIndexPath =  indexPath;
//    NSLog(@"selected cell = %@", cell);
    
    // TDOD handle bricks which can be edited
    if (!self.isEditing) {
        BrickDetailViewController *brickDetailViewcontroller = [[BrickDetailViewController alloc]initWithNibName:@"BrickDetailViewController" bundle:nil];
                
        brickDetailViewcontroller.brickCell = cell;
        self.brickScaleTransition.cell = cell;
        self.brickScaleTransition.navigationBar = self.navigationController.navigationBar;
        self.brickScaleTransition.collectionView = self.collectionView;
        self.brickScaleTransition.touchRect = cell.frame;
        self.brickScaleTransition.dimView = self.dimView;
        brickDetailViewcontroller.transitioningDelegate = self;
        brickDetailViewcontroller.modalPresentationStyle = UIModalPresentationCustom;
        self.collectionView.userInteractionEnabled = NO;
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self presentViewController:brickDetailViewcontroller animated:YES completion:^{
            self.navigationController.navigationBar.userInteractionEnabled = NO;
        }];
    } 
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    BrickCell *cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = .7f;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    BrickCell *cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = 1.f;
}

#pragma mark - LXReorderableCollectionViewDatasource
- (void)collectionView:(UICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
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

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath {
    [self.collectionView reloadData];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return toIndexPath.item == 0 ? NO : YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing || indexPath.item == 0) {
        return NO;
    }
    
    return YES;
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
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addBrickAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
}

- (void)removeBrickFromScriptCollectionViewFromIndex:(NSIndexPath *)indexPath {
    if (indexPath) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (script.brickList.count) {
            [self.collectionView performBatchUpdates:^{
                [script.brickList removeObjectAtIndex:indexPath.item - 1];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
            }];
        }
    }
}

- (void)removeScriptSectionWithIndexPath:(NSIndexPath *)indexPath {
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

- (void)addBrickCellAction:(BrickCell*)brickCell copyBrick:(BOOL)copy completionBlock:(void(^)())completionBlock
{
    if (!brickCell) {
        return;
    }
    
    // convert brickCell to brick
    NSString *brickCellClassName = NSStringFromClass([brickCell class]);
    NSString *brickOrScriptClassName = [brickCellClassName stringByReplacingOccurrencesOfString:@"Cell" withString:@""];
    id brickOrScript = [[NSClassFromString(brickOrScriptClassName) alloc] init];
    
    if ([brickOrScript isKindOfClass:[Brick class]]) {
        Script *script = nil;
        // automatically create new script if the object does not contain any of them
        if (! [self.object.scriptList count]) {
            script = [[StartScript alloc] init];
            script.allowRunNextAction = YES;
            script.object = self.object;
            [self.object.scriptList addObject:script];
        } else {
           script = [self firstVisibleScriptOnScreen:copy];
        }
        Brick *brick = (Brick*)brickOrScript;
        brick.object = self.object;
        
        [self insertBrick:brick intoScriptList:script copy:copy];
    } else if ([brickOrScript isKindOfClass:[Script class]]) {
        Script *script = (Script*)brickOrScript;
        script.object = self.object;
        [self.object.scriptList addObject:script];
    } else {
        NSError(@"Unknown class type given...");
        abort();
    }
    self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
    [self.collectionView reloadData];
    if (completionBlock) completionBlock();
}

- (Script *)firstVisibleScriptOnScreen:(BOOL)copy
{
    Script *script = nil;
    if (copy) {
        script = [self.object.scriptList objectAtIndex:self.selectedIndexPath.section];
    } else {
        // insert new brick in last visible script (section)
        NSMutableArray *scriptCells = [NSMutableArray array];
        if (self.collectionView.visibleCells.count) {
            for (BrickCell *cell in self.collectionView.visibleCells) {
                if ([self isScriptCell:cell]) {
                    [scriptCells addObject:cell];
                }
            }
        }
        if (scriptCells.count) {
            [scriptCells sortUsingComparator:^(BrickCell *cell1, BrickCell *cell2) {
                if (cell1.frame.origin.y > cell2.frame.origin.y) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (cell1.frame.origin.y < cell2.frame.origin.y) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
        }
        
        BOOL emtpyScript = NO;
        for (BrickCell *scriptCell in scriptCells) {
            script = [self.object.scriptList objectAtIndex:[self.collectionView indexPathForCell:scriptCell].section];
            if (! script.brickList.count) {
                emtpyScript = YES;
                break;
            }
        }
        
        BrickCell *cell = scriptCells.count ? scriptCells.lastObject : [self.collectionView.visibleCells firstObject];
        script = emtpyScript ? script : [self.object.scriptList objectAtIndex:[self.collectionView indexPathForCell:cell].section];
        self.addedIndexPath = [self.collectionView indexPathForCell:cell];
    }
    return script;
}

- (BOOL)isScriptCell:(BrickCell *)cell
{
    if ([cell isKindOfClass:StartScriptCell.class] ||
        [cell isKindOfClass:WhenScriptCell.class] ||
        [cell isKindOfClass:BroadcastScriptCell.class]) {
        return YES;
    }
    return NO;
}

- (void)insertBrick:(Brick *)brick intoScriptList:(Script *)script copy:(BOOL)copy
{
    if (copy) {
        [self.collectionView performBatchUpdates:^{
            [script.brickList insertObject:brick atIndex:self.selectedIndexPath.item];
            [self.collectionView insertItemsAtIndexPaths:@[self.selectedIndexPath]];
        } completion:^(BOOL finished) {
            if (finished) {
                [self.collectionView reloadData];
            }
        }];
    } else {
         __block NSIndexPath *indexPath = nil;
        [self.collectionView performBatchUpdates:^{
            if (! script.brickList.count) {
                [script.brickList addObject:brick];
                indexPath = [NSIndexPath indexPathForItem:script.brickList.count inSection:self.collectionView.numberOfSections - 1];
                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            } else {
                [script.brickList insertObject:brick atIndex:script.brickList.count];
                 indexPath = [NSIndexPath indexPathForItem:script.brickList.count inSection:self.addedIndexPath.section];
                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            }
            
        } completion:^(BOOL finished) {
            if (finished) {
                [self.collectionView reloadData];
            }
        }];
    }
}


- (void)scrollToLastbrickinCollectionView:(UICollectionView *)collectionView completion:(void(^)(NSIndexPath *indexPath)) completion {
    Script *script = [self.object.scriptList objectAtIndex:self.addedIndexPath.section];
    NSUInteger brickCountInSection = script.brickList.count;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:brickCountInSection inSection:self.addedIndexPath.section];
    [collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    if (completion) completion(lastIndexPath);
}

#pragma mark - Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    if (self.isEditing) {
        self.navigationItem.title = NSLocalizedString(@"Edit Mode", nil);
         __block NSInteger section = 0;;
        for (NSUInteger idx = 0; idx < self.collectionView.numberOfSections; idx++) {
            BrickCell *controlBrickCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            [self animateStataCellDeleteButton:controlBrickCell];
            
            Script *script = [self.object.scriptList objectAtIndex:idx];
            [script.brickList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                *stop = section > self.collectionView.numberOfSections ? YES : NO;
                BrickCell *cell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx + 1 inSection:section]];
                cell.userInteractionEnabled = NO;
                [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:1.0f/*0.45f*/ initialSpringVelocity:5.0f/*2.0f*/ options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    cell.alpha = 0.2f;
                    // cell.transform = CGAffineTransformMakeScale(0.8f, 0.8f);  // TODO dont work right at the moment with the bacghround image. fix later
                } completion:NULL];
            }];
            section++;
        }
        
    } else {
           self.navigationItem.title = NSLocalizedString(@"Scripts", nil);
         __block NSInteger section = 0;
        for (NSUInteger idx = 0; idx < self.collectionView.numberOfSections; idx++) {
            BrickCell *controlBrickCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            [self animateStataCellDeleteButton:controlBrickCell];
            
            Script *script = [self.object.scriptList objectAtIndex:idx];
            [script.brickList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                *stop = section > self.collectionView.numberOfSections ? YES : NO;
                BrickCell *cell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx + 1 inSection:section]];
                cell.userInteractionEnabled = YES;
                [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    cell.alpha = 1.0;
                    //   cell.transform = CGAffineTransformIdentity; // TODO dont work right at the moment with the bacghround image. fix later

                } completion:NULL];
            }];
            section++;
        }
    }
}

- (void)animateStataCellDeleteButton:(BrickCell *)controlBrickCell
{
    CGFloat endAlpha;
    CGAffineTransform transform;
    BOOL start = NO;
    
    controlBrickCell.hideDeleteButton = NO;
    if (self.isEditing) {
        start = YES;
        controlBrickCell.deleteButton.alpha = 0.0f;
        endAlpha = 1.0f;
        controlBrickCell.deleteButton.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } else {
        transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        endAlpha = 0.0f;
    }
    
    [UIView animateWithDuration:0.35f
                          delay:0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         controlBrickCell.deleteButton.transform = transform;
                         controlBrickCell.deleteButton.alpha = endAlpha;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             controlBrickCell.hideDeleteButton = !start;
                         }
                     }];
    
}



@end
