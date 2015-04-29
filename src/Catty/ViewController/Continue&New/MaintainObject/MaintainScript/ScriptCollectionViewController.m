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
#import "BrickTransition.h"
#import "WhenScriptCell.h"
#import "LanguageTranslationDefines.h"
#import "PlaceHolderView.h"
#import "BroadcastScriptCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickManager.h"
#import "Util.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "LoopEndBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "UIUtil.h"
#import "BrickCellFormulaFragment.h"
#import "NoteBrick.h"
#import "BrickSelectionViewController.h"
#import "BrickCellFragmentProtocol.h"
#import "BrickLookProtocol.h"
#import "BrickSoundProtocol.h"
#import "BrickObjectProtocol.h"
#import "BrickTextProtocol.h"
#import "BrickMessageProtocol.h"
#import "BrickCellMessageFragment.h"
#import "LooksTableViewController.h"
#import "SoundsTableViewController.h"
#import "ProgramTableViewController.h"
#import "ViewControllerDefines.h"
#import "Look.h"
#import "Sound.h"
#import "ActionSheetAlertViewTags.h"
#import "CatrobatActionSheet.h"
#import "DataTransferMessage.h"
#import "CBMutableCopyContext.h"
#import "RepeatBrick.h"

@interface ScriptCollectionViewController() <UICollectionViewDelegate,
                                             UICollectionViewDataSource,
                                             LXReorderableCollectionViewDelegateFlowLayout,
                                             LXReorderableCollectionViewDataSource,
                                             UIViewControllerTransitioningDelegate,
                                             BrickCellDelegate,
                                             iOSComboboxDelegate,
                                             BrickCellFragmentDelegate,
                                             CatrobatActionSheetDelegate>

@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) BrickTransition *brickScaleTransition;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPaths;  // refactor
@property (nonatomic, assign) BOOL selectedAllCells;  // refactor
@property (nonatomic, strong) NSIndexPath *higherRankBrick; // refactor
@property (nonatomic, strong) NSIndexPath *lowerRankBrick;  // refactor
@property (nonatomic) PageIndexCategoryType lastSelectedBrickCategory;

@end

@implementation ScriptCollectionViewController

#pragma mark - getters and setters
- (PlaceHolderView*)placeHolderView
{
    if (! _placeHolderView) {
        _placeHolderView = [[PlaceHolderView alloc] initWithFrame:self.collectionView.bounds];
        [self.view insertSubview:_placeHolderView aboveSubview:self.collectionView];
        _placeHolderView.hidden = YES;
    }
    return _placeHolderView;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolBar];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.placeHolderView.title = kLocalizedScripts;
    self.placeHolderView.hidden = (self.object.scriptList.count != 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.collectionView reloadData];
}

#pragma mark - actions
- (void)playSceneAction:(id)sender
{
    if ([self respondsToSelector:@selector(stopAllSounds)]) {
        [self performSelector:@selector(stopAllSounds)];
    }
    [self.navigationController setToolbarHidden:YES animated:YES];
    ScenePresenterViewController *vc = [ScenePresenterViewController new];
    vc.program = [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBrickPickerAction:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        BrickCategoryViewController *bcvc = [[BrickCategoryViewController alloc] initWithBrickCategory:self.lastSelectedBrickCategory];
        bcvc.delegate = self;
        BrickSelectionViewController *bsvc = [[BrickSelectionViewController alloc]
                                              initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                              options:@{
                                                        UIPageViewControllerOptionInterPageSpacingKey : @20.f
                                                        }];
        [bsvc setViewControllers:@[bcvc]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:bsvc];
        __weak typeof(&*self) weakSelf = self;
        [self presentViewController:navController animated:YES completion:^{
            if (weakSelf.object.scriptList.count) {
                NSIndexPath *scrollToTopIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [weakSelf.collectionView scrollToItemAtIndexPath:scrollToTopIndexPath
                                                atScrollPosition:UICollectionViewScrollPositionTop
                                                        animated:NO];
            }
        }];
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController*)presented
                                                                  presentingController:(UIViewController*)presenting
                                                                      sourceController:(UIViewController*)source
{
    if ([presented isKindOfClass:[FormulaEditorViewController class]]) {
        self.brickScaleTransition.transitionMode = TransitionModePresent;
        return self.brickScaleTransition;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController*)dismissed
{
    if ([dismissed isKindOfClass:[FormulaEditorViewController class]]) {
        self.brickScaleTransition.transitionMode = TransitionModeDismiss;
        return self.brickScaleTransition;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGSize size = CGSizeZero;
    if (indexPath.section < self.object.scriptList.count) {
        Script *script = self.object.scriptList[indexPath.section];
        size = ((indexPath.item == 0)
             ? [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(script.class)]
             : [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass([script.brickList[indexPath.item - 1] class])]);
    }
    return size;
}

#pragma mark- UICollectionViewDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kScriptCollectionViewTopInsets, 0.0f, kScriptCollectionViewBottomInsets, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kBrickOverlapHeight;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.isEditing) {
        if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]) {
            return;
        }
        Brick *brick = (Brick*)brickCell.scriptOrBrick;
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            [self selectLoopBeginWithBrick:brick Script:brick.script IndexPath:indexPath andSelectButton:nil];
        } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
            [self selectLoopEndWithBrick:brick Script:brick.script IndexPath:indexPath andSelectButton:nil];
        } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            [self selectLogicBeginWithBrick:brick Script:brick.script IndexPath:indexPath andSelectButton:nil];
        } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
            [self selectLogicEndWithBrick:brick Script:brick.script IndexPath:indexPath andSelectButton:nil];
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            [self selectLogicElseWithBrick:brick Script:brick.script IndexPath:indexPath andSelectButton:nil];
        } else {
            [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        }
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }

    BOOL isBrick = [brickCell.scriptOrBrick isKindOfClass:[Brick class]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
// TODO: add move brick button!!
    if (isBrick) {
        [buttonTitles addObject:kLocalizedCopyBrick];
    }
    if ([brickCell.scriptOrBrick isAnimateable]) {
        [buttonTitles addObject:kLocalizedAnimateBrick];
    }
    if (isBrick && [(Brick*)brickCell.scriptOrBrick isFormulaBrick]) {
        [buttonTitles addObject:kLocalizedEditFormula];
    }

    // determine destructive title dependend on type of selected Brick/Script
    NSString *destructiveTitle = kLocalizedDeleteScript;
    if ([brickCell.scriptOrBrick isKindOfClass:[Brick class]]) {
        Brick *brick = (Brick*)brickCell.scriptOrBrick;
        destructiveTitle = ([brick isIfLogicBrick]
                            ? kLocalizedDeleteCondition
                            : ([brick isLoopBrick]) ? kLocalizedDeleteLoop : kLocalizedDeleteBrick);
    }
    CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:nil
                                                         delegate:self
                                           destructiveButtonTitle:destructiveTitle
                                                otherButtonTitles:buttonTitles
                                                              tag:kEditBrickActionSheetTag
                                                             view:self.navigationController.view];
    actionSheet.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionEditBrickOrScript
                                                                    withPayload:@{ kDTPayloadCellIndexPath : indexPath }];
    [actionSheet setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
}

#pragma mark - action sheet delegates
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    if (actionSheet.tag == kEditBrickActionSheetTag) {
        CBAssert(actionSheet.dataTransferMessage.actionType == kDTMActionEditBrickOrScript);
        CBAssert([actionSheet.dataTransferMessage.payload isKindOfClass:[NSDictionary class]]);
        NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
        NSIndexPath *indexPath = payload[kDTPayloadCellIndexPath]; // unwrap payload message
        BrickCell *brickCell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];

        // delete script or brick action
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]) {
                [(Script*)brickCell.scriptOrBrick removeFromObject];
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } else {
                CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
                Brick *brick = (Brick*)brickCell.scriptOrBrick;
                if ([brick isLoopBrick]) {
                    // loop brick
                    LoopBeginBrick *loopBeginBrick = nil;
                    LoopEndBrick *loopEndBrick = nil;
                    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                        loopBeginBrick = ((LoopBeginBrick*)brick);
                        loopEndBrick = loopBeginBrick.loopEndBrick;
                    } else {
                        CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
                        loopEndBrick = ((LoopEndBrick*)brick);
                        loopBeginBrick = loopEndBrick.loopBeginBrick;
                    }
                    CBAssert((loopBeginBrick != nil) || (loopEndBrick != nil));
                    NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
                    NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
                    [loopBeginBrick removeFromScript];
                    [loopEndBrick removeFromScript];
                    NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
                    NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
                    [self.collectionView deleteItemsAtIndexPaths:@[loopBeginIndexPath, loopEndIndexPath]];
                } else if ([brick isIfLogicBrick]) {
                    // if brick
                    IfLogicBeginBrick *ifLogicBeginBrick = nil;
                    IfLogicElseBrick *ifLogicElseBrick = nil;
                    IfLogicEndBrick *ifLogicEndBrick = nil;
                    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                        ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
                        ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
                        ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
                    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                        ifLogicElseBrick = ((IfLogicElseBrick*)brick);
                        ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
                        ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
                    } else {
                        CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
                        ifLogicEndBrick = ((IfLogicEndBrick*)brick);
                        ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
                        ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
                    }
                    CBAssert((ifLogicBeginBrick != nil) && (ifLogicElseBrick != nil) && (ifLogicEndBrick != nil));
                    NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
                    NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
                    NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
                    [ifLogicBeginBrick removeFromScript];
                    [ifLogicElseBrick removeFromScript];
                    [ifLogicEndBrick removeFromScript];
                    NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
                    NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
                    NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
                    [self.collectionView deleteItemsAtIndexPaths:@[ifLogicBeginIndexPath, ifLogicElseIndexPath, ifLogicEndIndexPath]];
                } else {
                    // normal brick
                    [brick removeFromScript];
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }
            }
            self.placeHolderView.hidden = (self.object.scriptList.count != 0);
            [self.object.program saveToDisk];
            return;
        }

        IBActionSheetButton *selectedButton = [actionSheet.buttons objectAtIndex:buttonIndex];
        NSString *buttonTitle = selectedButton.titleLabel.text;

        // copy brick action
        if ([buttonTitle isEqualToString:kLocalizedCopyBrick]) {
            CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            Brick *brick = (Brick*)brickCell.scriptOrBrick;
            if ([brick isLoopBrick]) {
                // loop brick
                LoopBeginBrick *loopBeginBrick = nil;
                LoopEndBrick *loopEndBrick = nil;
                if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                    loopBeginBrick = ((LoopBeginBrick*)brick);
                    loopEndBrick = loopBeginBrick.loopEndBrick;
                } else {
                    CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
                    loopEndBrick = ((LoopEndBrick*)brick);
                    loopBeginBrick = loopEndBrick.loopBeginBrick;
                }
                CBAssert((loopBeginBrick != nil) || (loopEndBrick != nil));
                NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
                NSUInteger loopEndIndex = (loopBeginIndex + 1);
                LoopBeginBrick *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
                copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
                [brick.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
                [brick.script addBrick:copiedLoopEndBrick atIndex:loopEndIndex];
                NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
                NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 2) inSection:indexPath.section];
                [self.collectionView insertItemsAtIndexPaths:@[loopBeginIndexPath, loopEndIndexPath]];
            } else if ([brick isIfLogicBrick]) {
                // if brick
                IfLogicBeginBrick *ifLogicBeginBrick = nil;
                IfLogicElseBrick *ifLogicElseBrick = nil;
                IfLogicEndBrick *ifLogicEndBrick = nil;
                if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                    ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
                    ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
                    ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
                } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                    ifLogicElseBrick = ((IfLogicElseBrick*)brick);
                    ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
                    ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
                } else {
                    CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
                    ifLogicEndBrick = ((IfLogicEndBrick*)brick);
                    ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
                    ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
                }
                CBAssert((ifLogicBeginBrick != nil) && (ifLogicElseBrick != nil) && (ifLogicEndBrick != nil));
                NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
                NSUInteger ifLogicElseIndex = (ifLogicBeginIndex + 1);
                NSUInteger ifLogicEndIndex = (ifLogicElseIndex + 1);
                IfLogicBeginBrick *copiedIfLogicBeginBrick = [ifLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                IfLogicElseBrick *copiedIfLogicElseBrick = [ifLogicElseBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                IfLogicEndBrick *copiedIfLogicEndBrick = [ifLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                copiedIfLogicBeginBrick.ifElseBrick = copiedIfLogicElseBrick;
                copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
                copiedIfLogicElseBrick.ifBeginBrick = copiedIfLogicBeginBrick;
                copiedIfLogicElseBrick.ifEndBrick = copiedIfLogicEndBrick;
                copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
                copiedIfLogicEndBrick.ifElseBrick = copiedIfLogicElseBrick;
                [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
                [brick.script addBrick:copiedIfLogicElseBrick atIndex:ifLogicElseIndex];
                [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
                NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
                NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
                NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 3) inSection:indexPath.section];
                [self.collectionView insertItemsAtIndexPaths:@[ifLogicBeginIndexPath, ifLogicElseIndexPath, ifLogicEndIndexPath]];
            } else {
                // normal brick
                NSUInteger copiedBrickIndex = ([brick.script.brickList indexOfObject:brick] + 1);
                Brick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new]];
                [brick.script addBrick:copiedBrick atIndex:copiedBrickIndex];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection:indexPath.section];
                [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            }
            self.placeHolderView.hidden = YES;
            [self.object.program saveToDisk];
            return;
        }

        // edit formula
        if ([buttonTitle isEqualToString:kLocalizedEditFormula]) {
            BrickCellFormulaFragment *formulaFragment = [[BrickCellFormulaFragment alloc] initWithFrame:CGRectMake(0, 0, 0, 0) andBrickCell:brickCell andLineNumber:0 andParameterNumber:0];
            [self openFormulaEditor:formulaFragment];
            return;
        }

        // animate brick
        if ([buttonTitle isEqualToString:kLocalizedAnimateBrick]) {
            CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            [self animate:indexPath brickCell:brickCell];
            return;
        }
    }
}

#pragma mark - Reorderable Cells Delegate
- (void)collectionView:(UICollectionView*)collectionView
       itemAtIndexPath:(NSIndexPath*)fromIndexPath
   willMoveToIndexPath:(NSIndexPath*)toIndexPath
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

- (void)collectionView:(UICollectionView*)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
willBeginDraggingItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.higherRankBrick = nil;
    self.lowerRankBrick = nil;
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return self.object.scriptList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    Script *script = [self.object.scriptList objectAtIndex:(NSUInteger)section];
    CBAssert(script != nil, @"Error, no script found");
    return script.brickList.count + 1; // +1, because script itself is a brick in ScriptEditor too
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellIdentifier = nil;
    BrickCell *brickCell = nil;
    Script *script = [self.object.scriptList objectAtIndex:(NSUInteger)indexPath.section];
    Brick *brick = nil;

    if (indexPath.item == 0) {
        cellIdentifier = NSStringFromClass([script class]);
    } else {
        brick = [script.brickList objectAtIndex:indexPath.item - 1];
        cellIdentifier = NSStringFromClass([brick class]);
    }
    brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    brickCell.scriptOrBrick = ((indexPath.item == 0) ? script : brick);
    brickCell.enabled = YES;
    [brickCell setupBrickCell];
    brickCell.delegate = self;
    brickCell.fragmentDelegate = self;

    if (brick.isAnimated) {
        [brickCell animateBrick:YES];
    }
    return brickCell;
}

- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
                                                          canMoveToIndexPath:(NSIndexPath*)toIndexPath
{
    Script *fromScript = [self.object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    if (toIndexPath.item != 0) {
        if ([fromBrick isKindOfClass:[LoopBeginBrick class]]){
            return [self checkLoopBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        } else if ([fromBrick isKindOfClass:[LoopEndBrick class]]) {
            return [self checkLoopEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        } else if ([fromBrick isKindOfClass:[IfLogicBeginBrick class]]){
            return [self checkIfBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        } else if ([fromBrick isKindOfClass:[IfLogicElseBrick class]]){
            return [self checkIfElseToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        } else if ([fromBrick isKindOfClass:[IfLogicEndBrick class]]){
            return [self checkIfEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick];
        } else {
            return (toIndexPath.item != 0);
        }
    } else {
        return NO;
    }
}

- (BOOL)collectionView:(UICollectionView*)collectionView canMoveItemAtIndexPath:(NSIndexPath*)indexPath
{
    return ((self.isEditing || indexPath.item == 0) ? NO : YES);
}

#pragma mark - BrickCategoryViewController delegates
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.lastSelectedBrickCategory = brickCategoryViewController.pageIndexCategoryType;
    brickCategoryViewController.delegate = nil;
    BrickManager *brickManager = [BrickManager sharedBrickManager];

    if ([brickManager isScript:scriptOrBrick.brickType]) {
        Script *scriptBrick = (Script*)scriptOrBrick;
        scriptBrick.object = self.object;
        [self.object.scriptList addObject:scriptBrick];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:(self.object.scriptList.count - 1)]];
        [self.collectionView reloadData];
        self.placeHolderView.hidden = (self.object.scriptList.count != 0);
        return;
    }

    // empty script list, insert start script + brick
    if (self.object.scriptList.count == 0) {
        StartScript *startScript = [StartScript new];
        startScript.object = self.object;
        [self.object.scriptList addObject:startScript];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:(self.object.scriptList.count - 1)]];
    }

    Brick *brick = (Brick*)scriptOrBrick;
    Script *firstScript = [self.object.scriptList firstObject];
    brick.script = firstScript;
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *ifBeginBrick = (IfLogicBeginBrick*)brick;
        IfLogicElseBrick *ifElseBrick = [IfLogicElseBrick new];
        IfLogicEndBrick *ifEndBrick = [IfLogicEndBrick new];
        ifBeginBrick.ifElseBrick = ifElseBrick;
        ifBeginBrick.ifEndBrick = ifEndBrick;
        ifElseBrick.ifBeginBrick = ifBeginBrick;
        ifElseBrick.ifEndBrick = ifEndBrick;
        ifEndBrick.ifBeginBrick = ifBeginBrick;
        ifEndBrick.ifElseBrick = ifElseBrick;
        ifElseBrick.script = firstScript;
        ifEndBrick.script = firstScript;
        [firstScript.brickList insertObject:ifEndBrick atIndex:0];
        [firstScript.brickList insertObject:ifElseBrick atIndex:0];
        [firstScript.brickList insertObject:ifBeginBrick atIndex:0];
    } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)brick;
        LoopEndBrick *loopEndBrick = [LoopEndBrick new];
        loopBeginBrick.loopEndBrick = loopEndBrick;
        loopEndBrick.loopBeginBrick = loopBeginBrick;
        loopEndBrick.script = firstScript;
        [firstScript.brickList insertObject:loopEndBrick atIndex:0];
        [firstScript.brickList insertObject:loopBeginBrick atIndex:0];
    } else {
        [firstScript.brickList insertObject:brick atIndex:0];
    }
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
    self.placeHolderView.hidden = (self.object.scriptList.count != 0);
}

#pragma mark - Brick Cell Delegate
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
    if (indexPath) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (script.brickList.count) {
            Brick *brick =[script.brickList objectAtIndex:indexPath.item - 1];
            if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                [self selectLoopBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
                [self selectLoopEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                [self selectLogicBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
                [self selectLogicEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                [self selectLogicElseWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else {
                if (! selectButton.selected) {
                    selectButton.selected = selectButton.touchInside;
                    [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
                } else {
                    selectButton.selected = NO;
                    [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
                }
            }
        }
    }
}

#pragma mark - Open Formula Editor
- (void)openFormulaEditor:(BrickCellFormulaFragment*)formulaFragment
{
    if ([self.presentedViewController isKindOfClass:[FormulaEditorViewController class]]) {
        FormulaEditorViewController *formulaEditorViewController = (FormulaEditorViewController*)self.presentedViewController;
        if ([formulaEditorViewController changeFormula]) {
            [formulaEditorViewController setBrickCellFormulaFragment:formulaFragment];
            [formulaFragment drawBorder:YES];
        }
    } else {
        // Check if already presenting a view controller.
        if (self.presentedViewController.isViewLoaded && self.presentedViewController.view.window) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:NULL];
        }

        FormulaEditorViewController *formulaEditorViewController = [[FormulaEditorViewController alloc] initWithBrickCellFormulaFragment:formulaFragment];
        formulaEditorViewController.object = self.object;
        formulaEditorViewController.transitioningDelegate = self;
        formulaEditorViewController.modalPresentationStyle = UIModalPresentationCustom;
        formulaEditorViewController.delegate = formulaFragment;
        [formulaFragment drawBorder:YES];

        [self.brickScaleTransition updateAnimationViewWithView:formulaFragment.brickCell];
        [self presentViewController:formulaEditorViewController animated:YES completion:^{
            [formulaEditorViewController setBrickCellFormulaFragment:formulaFragment];
        }];
    }
}

#pragma mark - Helpers
// TODO: Remove
- (void)removeBricksWithIndexPaths:(NSArray*)indexPaths
{
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    sortedIndexPaths = [[sortedIndexPaths reverseObjectEnumerator] allObjects];
    [self.collectionView performBatchUpdates:^{
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
            if (indexPath.item == 0) {
                [self.object.scriptList removeObjectAtIndex:indexPath.section];
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } else {
                [script.brickList removeObjectAtIndex:indexPath.item - 1];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        }
    } completion:^(BOOL finished) {
        [self.selectedIndexPaths removeAllObjects];
        [self.collectionView reloadData];
        self.placeHolderView.hidden = (self.object.scriptList.count != 0);
    }];
}

- (void)selectAllBricks
{
    if (!self.selectedAllCells) {
        self.selectedAllCells = YES;
        for (BrickCell *cell in self.collectionView.visibleCells) {
            cell.selectButton.selected = YES;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        }
    } else {
        self.selectedAllCells = NO;
        for (BrickCell *cell in self.collectionView.visibleCells) {
            cell.selectButton.selected = NO;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        }
    }
}

- (NSString*)keyWithSelectIndexPath:(NSIndexPath*)indexPath
{
    return [NSString stringWithFormat:@"%@_%@", @(indexPath.section), @(indexPath.item)];
}

#pragma mark - Editing
// TODO: Refactor
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self setupToolBar];

    if (self.isEditing) {
        self.navigationItem.title = kLocalizedEditMenu;
        self.navigationItem.rightBarButtonItem.title = kLocalizedCancel;

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
- (BOOL)checkLoopBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
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
                } else {
                    self.lowerRankBrick = toIndexPath;
                    return NO;
                }
            } else {
                return YES;
            }
        } else {
            return NO;
        }
        
    }else{
        return NO;
    }
}

- (BOOL)checkLoopEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
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

- (BOOL)checkIfBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
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


- (BOOL)checkIfElseToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
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

- (BOOL)checkIfEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick
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

#pragma mark - selectLogic/Loop bricks
-(void)selectLoopBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    LoopBeginBrick *beginBrick = (LoopBeginBrick *)brick;
    
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:beginBrick.loopEndBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:endPath forKey:[self keyWithSelectIndexPath:endPath]];
    } else {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:endPath]];
    }
    
}

-(void)selectLoopEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    LoopEndBrick *endBrick = (LoopEndBrick *)brick;
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:endBrick.loopBeginBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* beginPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:beginPath forKey:[self keyWithSelectIndexPath:beginPath]];
    } else {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:beginPath]];
    }
}

- (void)selectLogicBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick *)brick;
    NSInteger countElse = 0;
    NSInteger countEnd = 0;
    BOOL foundElse = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundElse) {
            if ([checkBrick isEqual:beginBrick.ifElseBrick]) {
                foundElse = YES;
            } else {
                ++countElse;
            }
        }
        if ([checkBrick isEqual:beginBrick.ifEndBrick]) {
            break;
        } else {
            ++countEnd;
        }
    }
    NSIndexPath *elsePath =[NSIndexPath indexPathForItem:(countElse+1) inSection:indexPath.section];
    NSIndexPath *endPath =[NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
    if (selectButton.selected) {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:elsePath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:endPath]];
    } else {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:elsePath forKey:[self keyWithSelectIndexPath:elsePath]];
        [self.selectedIndexPaths setObject:endPath forKey:[self keyWithSelectIndexPath:endPath]];
    }
    
}

- (void)selectLogicElseWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)brick;
    NSInteger countBegin = 0;
    NSInteger countEnd = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundIf) {
            if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                foundIf = YES;
            } else {
                ++countBegin;
            }
        }
        if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
            break;
        } else {
            ++countEnd;
        }
    }
    NSIndexPath *beginPath = [NSIndexPath indexPathForItem:(countBegin+1) inSection:indexPath.section];
    NSIndexPath *endPath = [NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:beginPath forKey:[self keyWithSelectIndexPath:beginPath]];
        [self.selectedIndexPaths setObject:endPath forKey:[self keyWithSelectIndexPath:endPath]];
    } else {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:beginPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:endPath]];
    }
    
}

- (void)selectLogicEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
    NSInteger countElse = 0;
    NSInteger countbegin = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundIf) {
            if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                foundIf = YES;
            } else {
                ++countbegin;
            }
        }
        if ([checkBrick isEqual:endBrick.ifElseBrick]) {
            break;
        } else {
            ++countElse;
        }
    }
    NSIndexPath *beginPath =[NSIndexPath indexPathForItem:countbegin+1 inSection:indexPath.section];
    NSIndexPath *elsePath =[NSIndexPath indexPathForItem:countElse+1 inSection:indexPath.section];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:beginPath forKey:[self keyWithSelectIndexPath:beginPath]];
        [self.selectedIndexPaths setObject:elsePath forKey:[self keyWithSelectIndexPath:elsePath]];
    } else {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:beginPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:elsePath]];
    }
}

#pragma mark - Animate Logic Bricks
-(void)animate:(NSIndexPath*)indexPath brickCell:(BrickCell*)brickCell
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [brickCell animateBrick:YES];
    });
    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    if (script.brickList.count) {
        Brick *brick = [script.brickList objectAtIndex:indexPath.item -1];
        if ([brick isKindOfClass:[LoopBeginBrick class]] || [brick isKindOfClass:[LoopEndBrick class]]) {
            [self loopBrickForAnimation:brick IndexPath:indexPath andScript:script];
        } else if ([brick isKindOfClass:[IfLogicBeginBrick class]] || [brick isKindOfClass:[IfLogicElseBrick class]] || [brick isKindOfClass:[IfLogicEndBrick class]]) {
            [self ifBrickForAnimation:brick IndexPath:indexPath andScript:script];
        }
    }
}

- (void)loopBrickForAnimation:(Brick*)brick IndexPath:(NSIndexPath*)indexPath andScript:(Script*)script
{
    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *begin = (LoopBeginBrick*)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopEndBrick]) {
                break;
            }
            ++count;
        }
        begin.animate = YES;
        begin.loopEndBrick.animate = YES;
        [self animateLoop:count andIndexPath:indexPath];
    } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *endBrick = (LoopEndBrick *)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:endBrick.loopBeginBrick]) {
                break;
            }
            ++count;
        }
        endBrick.animate = YES;
        endBrick.loopBeginBrick.animate = YES;
        [self animateLoop:count andIndexPath:indexPath];
    }
}

- (void)ifBrickForAnimation:(Brick*)brick IndexPath:(NSIndexPath*)indexPath andScript:(Script*)script
{
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *begin = (IfLogicBeginBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:begin.ifElseBrick]) {
                    found = YES;
                } else {
                    ++elsecount;
                }
            }
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
            
        }
        begin.animate = YES;
        begin.ifElseBrick.animate = YES;
        begin.ifEndBrick.animate = YES;
        [self animateIf:elsecount and:endcount andIndexPath:indexPath];
    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)brick;
        NSInteger begincount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
        }
        elseBrick.animate = YES;
        elseBrick.ifBeginBrick.animate = YES;
        elseBrick.ifEndBrick.animate = YES;
        [self animateIf:begincount and:endcount andIndexPath:indexPath];
    } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger begincount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:endBrick.ifElseBrick]) {
                break;
            } else {
                ++elsecount;
            }
            
        }
        endBrick.animate = YES;
        endBrick.ifElseBrick.animate = YES;
        endBrick.ifBeginBrick.animate = YES;
        [self animateIf:elsecount and:begincount andIndexPath:indexPath];
    }
}

-(void)animateLoop:(NSInteger)count andIndexPath:(NSIndexPath*)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell *cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section]];
        [cell animateBrick:YES];
    });
}

-(void)animateIf:(NSInteger)count1 and:(NSInteger)count2 andIndexPath:(NSIndexPath*)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell *elsecell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count1+1 inSection:indexPath.section]];
        BrickCell *begincell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count2+1 inSection:indexPath.section]];
        [elsecell animateBrick:YES];
        [begincell animateBrick:YES];
    });
}

#pragma mark - Setup
- (void)setupCollectionView
{
    self.collectionView.backgroundColor = [UIColor darkBlueColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.collectionViewLayout = [LXReorderableCollectionViewFlowLayout new];
    self.navigationController.title = self.title = kLocalizedScripts;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.brickScaleTransition = [[BrickTransition alloc] initWithViewToAnimate:nil];
    self.selectedIndexPaths = [NSMutableDictionary dictionary];

    // register brick cells for current brick category
    NSDictionary *allBrickTypes = [[BrickManager sharedBrickManager] classNameBrickTypeMap];
    for (NSString *className in allBrickTypes) {
        [self.collectionView registerClass:NSClassFromString([className stringByAppendingString:@"Cell"])
                forCellWithReuseIdentifier:className];
    }
}

#pragma mark - Setup Toolbar
- (void)setupToolBar
{
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                            target:self
                                                                            action:@selector(deleteSelectedBricks)];
    delete.tintColor = [UIColor redColor];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(showBrickPickerAction:)];
    add.enabled = (! self.editing);
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    play.enabled = (! self.editing);
    if (self.editing) {
        self.toolbarItems = @[flexItem,invisibleButton, delete, invisibleButton, flexItem];
    } else {
        self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                              flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
    }
}

#pragma mark - BrickCellFragment Delegate
- (void)addObjectWithName:(NSString*)objectName andCompletion:(id)completion
{
    NSString *uniqueName = [Util uniqueName:objectName existingNames:[self.object.program allObjectNames]];
    [self.object.program addObjectWithName:uniqueName];
    if(completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(objectName);
    }
    [self.collectionView reloadData];
}

- (void)addMessageWithName:(NSString*)messageName andCompletion:(id)completion
{
    if(completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(messageName);
    }
    [self.object.program saveToDisk];
    [self.collectionView reloadData];
}

- (void)updateData:(id)data forBrick:(Brick*)brick andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if ([brick conformsToProtocol:@protocol(BrickLookProtocol)]) {
        Brick<BrickLookProtocol> *lookBrick = (Brick<BrickLookProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            LooksTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kLooksTableViewControllerIdentifier];
            [ltvc setObject:self.object];
            ltvc.showAddLookActionSheetAtStartForScriptEditor = YES;
            ltvc.showAddLookActionSheetAtStartForObject = NO;
            ltvc.afterSafeBlock = ^(Look* look) {
                [lookBrick setLook:look forLineNumber:line andParameterNumber:parameter];
                [self.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:ltvc animated:YES];
            return;
        } else {
            [lookBrick setLook:[Util lookWithName:(NSString*)data forObject:self.object] forLineNumber:line andParameterNumber:parameter];
        }
    }
    if ([brick conformsToProtocol:@protocol(BrickSoundProtocol)]) {
        Brick<BrickSoundProtocol> *soundBrick = (Brick<BrickSoundProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            SoundsTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kSoundsTableViewControllerIdentifier];
            [ltvc setObject:self.object];
            ltvc.showAddSoundActionSheetAtStart = YES;
            ltvc.afterSafeBlock =  ^(Sound* sound) {
                [soundBrick setSound:sound forLineNumber:line andParameterNumber:parameter];
                [self.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:ltvc animated:YES];
            return;
        } else {
            [soundBrick setSound:[Util soundWithName:(NSString*)data forObject:self.object] forLineNumber:line andParameterNumber:parameter];
        }
    }
    if ([brick conformsToProtocol:@protocol(BrickObjectProtocol)]) {
        Brick<BrickObjectProtocol> *objectBrick = (Brick<BrickObjectProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            [Util addObjectAlertForProgram:self.object.program andPerformAction:@selector(addObjectWithName:andCompletion:) onTarget:self withCompletion:^(NSString *objectName){
                [objectBrick setObject:[Util objectWithName:objectName forProgram:self.object.program] forLineNumber:line andParameterNumber:parameter];
            }];
            return;
        } else {
            [objectBrick setObject:[Util objectWithName:(NSString*)data forProgram:self.object.program] forLineNumber:line andParameterNumber:parameter];
        }
    }
    if ([brick conformsToProtocol:@protocol(BrickFormulaProtocol)]) {
        [(Brick<BrickFormulaProtocol>*)brick setFormula:(Formula*)data forLineNumber:line andParameterNumber:parameter];
    }
    if ([brick conformsToProtocol:@protocol(BrickTextProtocol)]) {
        [(Brick<BrickTextProtocol>*)brick setText:(NSString*)data forLineNumber:line andParameterNumber:parameter];
    }
    if ([brick conformsToProtocol:@protocol(BrickMessageProtocol)]) {
        Brick<BrickMessageProtocol> *messageBrick = (Brick<BrickMessageProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            [Util askUserForUniqueNameAndPerformAction:@selector(addMessageWithName:andCompletion:)
                                                target:self
                                          cancelAction:nil 
                                            withObject:(id) ^(NSString* message){
                                                [messageBrick setMessage:message forLineNumber:line andParameterNumber:parameter];
                                            }
                                           promptTitle:kLocalizedNewMessage
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedMessage]
                                           promptValue:nil
                                     promptPlaceholder:kLocalizedEnterYourMessageHere
                                        minInputLength:kMinNumOfMessageNameCharacters
                                        maxInputLength:kMaxNumOfMessageNameCharacters
                                   blockedCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                                                        invertedSet]
                              invalidInputAlertMessage:kLocalizedMessageAlreadyExistsDescription
                                         existingNames:[Util allMessagesForProgram:self.object.program]];
            return;
        } else {
            [messageBrick setMessage:(NSString*)data forLineNumber:line andParameterNumber:parameter];
        }
    }
    
    [self.object.program saveToDisk];
}

@end
