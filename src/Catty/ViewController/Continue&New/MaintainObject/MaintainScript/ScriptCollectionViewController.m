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
#import "ScriptDataSource.h"
#import "BrickSelectionViewController.h"
#import "ScriptDataSource+Extensions.h"
#import "FBKVOController.h"
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
                                             LXReorderableCollectionViewDelegateFlowLayout,
                                             LXReorderableCollectionViewDataSource,
                                             UIViewControllerTransitioningDelegate,
                                             BrickCellDelegate,
                                             ScriptDataSourceDelegate,
                                             iOSComboboxDelegate,
                                             BrickCellFragmentDelegate,
                                             CatrobatActionSheetDelegate>

@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) BrickTransition *brickScaleTransition;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPaths;  // refactor
@property (nonatomic, assign) BOOL selectedAllCells;  // refactor
@property (nonatomic, strong) NSIndexPath *higherRankBrick; // refactor
@property (nonatomic, strong) NSIndexPath *lowerRankBrick;  // refactor
@property (nonatomic, strong) ScriptDataSource *scriptDataSource;
@property (nonatomic, strong) FBKVOController *scriptDataSourceKVOController;
@property (nonatomic) PageIndexCategoryType lastSelectedBrickCategory;

@end

@implementation ScriptCollectionViewController

#pragma mark - getters and setters
- (PlaceHolderView*)placeHolderView
{
    if (!_placeHolderView) {
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
    [self setupDataSource];
    [self setupCollectionView];
    [self setupToolBar];
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
            if (weakSelf.scriptDataSource.scriptList.count) {
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
        Script *script = [self.scriptDataSource scriptAtSection:indexPath.section];
        size = indexPath.item == 0 ? [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass(script.class)]
        : [BrickManager.sharedBrickManager sizeForBrick:NSStringFromClass([[script.brickList objectAtIndex:indexPath.item - 1] class])];
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
//    [actionSheet setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
    [actionSheet setButtonBackgroundColor:[UIColor colorWithRed:0 green:37.0f/255.0f blue:52.0f/255.0f alpha:0.95f]];
    [actionSheet setButtonTextColor:[UIColor whiteColor]];
    [actionSheet setButtonTextColor:[UIColor redColor] forButtonAtIndex:0];
//    actionSheet.transparentView = nil;
    [actionSheet showInView:self.navigationController.view];
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
                [self.scriptDataSource removeScriptsAtSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                [(Script*)brickCell.scriptOrBrick removeFromObject];
            } else {
                CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
                Brick *brick = (Brick*)brickCell.scriptOrBrick;
                if ([brick isLoopBrick]) {
#warning implement!!
                    // loop brick
                } else if ([brick isIfLogicBrick]) {
#warning implement!!
                    // if brick
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
                NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
                NSUInteger loopEndIndex = (loopBeginIndex + 1);
                LoopBeginBrick *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
                copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
                copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
                [brick.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
                [brick.script addBrick:copiedLoopEndBrick atIndex:loopEndIndex];
                NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForRow:(indexPath.row+1) inSection:indexPath.section];
                [self.collectionView insertItemsAtIndexPaths:@[loopBeginIndexPath, loopEndIndexPath]];
            } else if ([brick isIfLogicBrick]) {
#warning implement!!
                // if brick
            } else {
                // normal brick
                NSUInteger copiedBrickIndex = ([brick.script.brickList indexOfObject:brick] + 1);
                Brick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new]];
                [brick.script addBrick:copiedBrick atIndex:copiedBrickIndex];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
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

#pragma mark - ScriptDataSourceDelegate
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource stateChanged:(ScriptDataSourceState)state error:(NSError *)error
{
    NSLog(@"Script data source state changed: %lu", state);
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didInsertSections:(NSIndexSet *)sections {
    if (!sections)
        return;
    
    [self.collectionView insertSections:sections];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
    [self resetScrollingtoBottomAnimated:NO];
}

#pragma mark - helpers
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection{
    [self.collectionView moveSection:section toSection:newSection];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didRemoveSections:(NSIndexSet *)sections
{
    [self.collectionView deleteSections:sections];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
}

-(void)scriptDataSource:(ScriptDataSource *)scriptDataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                                        toIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:newIndexPath];
    // TODO make save work with KVO
    [self.object.program saveToDisk];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource performBatchUpdate:(dispatch_block_t)update
                                                                        complete:(dispatch_block_t)complete
{
    __weak ScriptCollectionViewController *weakself = self;
    [self.collectionView performBatchUpdates:^{
        update();
    } completion:^(BOOL finished) {
        if (complete) { complete(); }
        [weakself.collectionView reloadData];
        // TODO do with KVO
        [self.object.program saveToDisk];
    }];
}

#pragma mark - BrickCategoryViewController delegates
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.lastSelectedBrickCategory = brickCategoryViewController.pageIndexCategoryType;
    brickCategoryViewController.delegate = nil;

    BrickManager *brickManager = [BrickManager sharedBrickManager];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    // empty script list, insert start script with added brick
    if (self.scriptDataSource.scriptList.count == 0 && (! [brickManager isScript:scriptOrBrick.brickType])) {
        StartScript *startScript = [StartScript new];
        startScript.object = self.object;
        [self.scriptDataSource addScript:startScript toSection:topIndexPath.section];
        NSArray *bricks = [self linkedBricksForBrick:scriptOrBrick.brickType];
        [self.scriptDataSource addBricks:bricks atIndexPath:topIndexPath];
    } else if ([brickManager isScript:scriptOrBrick.brickType]) {
        Script *scriptBrick = (Script*)scriptOrBrick;
        scriptBrick.object = self.object;
        [self.scriptDataSource addScript:scriptBrick toSection:self.object.scriptList.count];
    } else {
        [self resetScrollingtoTopWithIndexPath:topIndexPath animated:NO];
        // add new brick(s) to the top most section
        NSArray *bricks = [self linkedBricksForBrick:scriptOrBrick.brickType];
        [self.scriptDataSource addBricks:bricks atIndexPath:topIndexPath];
    }
    self.placeHolderView.hidden = (self.object.scriptList.count != 0);
}

- (NSArray*)linkedBricksForBrick:(kBrickType)brickType
{
    NSMutableArray *bricks = [NSMutableArray arrayWithCapacity:3];
    NSString *brickClassString = [[BrickManager sharedBrickManager]classNameForBrickType:brickType];
    Class brickClass = NSClassFromString(brickClassString);
    
    switch (brickType) {
        case kForeverBrick:
            [bricks addObject:[brickClass new]];
            [bricks addObject:[LoopEndBrick new]];
            [self linkLoopBeginBrick:[bricks objectAtIndex:0] withLoopEndBrick:[bricks objectAtIndex:1]];
            break;
        case kIfBrick:
            [bricks addObject:[[brickClass class] new]];
            [bricks addObject:[IfLogicElseBrick new]];
            [bricks addObject:[IfLogicEndBrick new]];
            [self linkIfLogicBeginBrick:[bricks objectAtIndex:0]
                   withIfLogicElseBrick:[bricks objectAtIndex:1]
                     andIfLogicEndBrick:[bricks objectAtIndex:2]];
            break;
        case kIfElseBrick:
            [bricks addObject:[IfLogicBeginBrick new]];
            [bricks addObject:[brickClass new]];
            [bricks addObject:[IfLogicEndBrick new]];
            [self linkIfLogicBeginBrick:[bricks objectAtIndex:0]
                   withIfLogicElseBrick:[bricks objectAtIndex:1]
                     andIfLogicEndBrick:[bricks objectAtIndex:2]];
            break;
        case kIfEndBrick:
            [bricks addObject:[IfLogicBeginBrick new]];
            [bricks addObject:[IfLogicElseBrick new]];
            [bricks addObject:[brickClass new]];
            [self linkIfLogicBeginBrick:[bricks objectAtIndex:0]
                   withIfLogicElseBrick:[bricks objectAtIndex:1]
                     andIfLogicEndBrick:[bricks objectAtIndex:2]];
            break;
        case kRepeatBrick:
            [bricks addObject:[brickClass new]];
            [bricks addObject:[LoopEndBrick new]];
            [self linkLoopBeginBrick:[bricks objectAtIndex:0] withLoopEndBrick:[bricks objectAtIndex:1]];
            break;
        case kLoopEndBrick:
            [bricks addObject:[brickClass new]];
            [bricks addObject:[RepeatBrick new]];
            [self linkLoopBeginBrick:[bricks objectAtIndex:0] withLoopEndBrick:[bricks objectAtIndex:1]];
            break;
        default:
            [bricks addObject:[brickClass new]];
            break;
    }
    return bricks;
}

- (void)linkLoopBeginBrick:(LoopBeginBrick *)loopBeginBrick withLoopEndBrick:(LoopEndBrick *)loopEndBrick
{
    CBAssert(loopEndBrick && loopEndBrick);
    loopBeginBrick.loopEndBrick = loopEndBrick;
    loopEndBrick.loopBeginBrick = loopBeginBrick;
}

- (void)linkIfLogicBeginBrick:(IfLogicBeginBrick*)ifLogicBeginBrick
         withIfLogicElseBrick:(IfLogicElseBrick*)ifLogicElseBrick
           andIfLogicEndBrick:(IfLogicEndBrick*)ifLogicEndBrick
{
    CBAssert(ifLogicBeginBrick && ifLogicElseBrick && ifLogicEndBrick);
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
}


- (void)resetScrollingtoTopWithIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)resetScrollingtoBottomAnimated:(BOOL)animated
{
    if (!self.scriptDataSource.numberOfSections) {
        return;
    }
    
    NSUInteger lastSection = self.scriptDataSource.numberOfSections;
    NSUInteger itemCount = [self.collectionView numberOfItemsInSection:lastSection - 1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemCount - 1 inSection:lastSection - 1];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

#pragma mark - Brick Cell Delegate
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:
                              [self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
    
    if (indexPath) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (script.brickList.count) {
                Brick *brick =[script.brickList objectAtIndex:indexPath.item - 1];
                if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                    [self selectLoopBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
                } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
                    [self selectLoopEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
                }else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                    [self selectLogicBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
                }else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
                    [self selectLogicEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
                }else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                    [self selectLogicElseWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
                }else{
                    if (!selectButton.selected) {
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

-(void)selectLoopEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
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

-(void)selectLogicBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
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
    NSIndexPath* elsePath =[NSIndexPath indexPathForItem:(countElse+1) inSection:indexPath.section];
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
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

-(void)selectLogicElseWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
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
    NSIndexPath *beginPath =[NSIndexPath indexPathForItem:(countBegin+1) inSection:indexPath.section];
    NSIndexPath *endPath =[NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
    if (!selectButton.selected) {
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

-(void)selectLogicEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
    NSInteger countElse = 0;
    NSInteger countbegin = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (!foundIf) {
            if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                foundIf = YES;
            }else{
                countbegin++;
            }
        }
        if ([checkBrick isEqual:endBrick.ifElseBrick]) {
            break;
        }else{
            countElse++;
        }
        
    }
    NSIndexPath* beginPath =[NSIndexPath indexPathForItem:countbegin+1 inSection:indexPath.section];
    NSIndexPath* elsePath =[NSIndexPath indexPathForItem:countElse+1 inSection:indexPath.section];
    if (!selectButton.selected) {
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
        if ([brick isKindOfClass:[LoopBeginBrick class]]||[brick isKindOfClass:[LoopEndBrick class]]) {
            [self loopBrickForAnimation:brick IndexPath:indexPath andScript:script];
        } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]||[brick isKindOfClass:[IfLogicElseBrick class]]||[brick isKindOfClass:[IfLogicEndBrick class]]) {
            [self ifBrickForAnimation:brick IndexPath:indexPath andScript:script];
        }
    }
}

-(void)loopBrickForAnimation:(Brick*)brick IndexPath:(NSIndexPath*)indexPath andScript:(Script*)script
{
    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *begin = (LoopBeginBrick *)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopEndBrick]) {
                break;
            }
            count++;
        }
        [self animateLoop:count andIndexPath:indexPath];
        
    } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *begin = (LoopEndBrick *)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopBeginBrick]) {
                break;
            }
            count++;
        }
        [self animateLoop:count andIndexPath:indexPath];
        
    }
}

-(void)ifBrickForAnimation:(Brick*)brick IndexPath:(NSIndexPath*)indexPath andScript:(Script*)script
{
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *begin = (IfLogicBeginBrick *)brick;
        NSInteger elsecount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (!found) {
                if ([checkBrick isEqual:begin.ifElseBrick]) {
                    found = YES;
                }else{
                    elsecount++;
                }
            }
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            }else{
                endcount++;
            }
            
        }
        [self animateIf:elsecount and:endcount andIndexPath:indexPath];
    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick *)brick;
        NSInteger begincount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (!found) {
                if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                    found = YES;
                }else{
                    begincount++;
                }
            }
            if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
                break;
            }else{
                endcount++;
            }
            
        }
        [self animateIf:begincount and:endcount andIndexPath:indexPath];
    } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick *)brick;
        NSInteger elsecount = 0;
        NSInteger begincount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (!found) {
                if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                    found = YES;
                }else{
                    begincount++;
                }
            }
            if ([checkBrick isEqual:endBrick.ifElseBrick]) {
                break;
            }else{
                elsecount++;
            }
            
        }
        [self animateIf:elsecount and:begincount andIndexPath:indexPath];
    }
}

-(void)animateLoop:(NSInteger)count andIndexPath:(NSIndexPath*)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell*cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section]];
        [cell animateBrick:YES];
    });
}

-(void)animateIf:(NSInteger)count1 and:(NSInteger)count2 andIndexPath:(NSIndexPath*)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell* elsecell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count1+1 inSection:indexPath.section]];
        BrickCell* begincell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count2+1 inSection:indexPath.section]];
        [elsecell animateBrick:YES];
        [begincell animateBrick:YES];
    });
}

#pragma mark - Setup
- (void)setupDataSource
{
    __weak typeof(&*self)weakSelf = self;
    ScriptCollectionViewConfigureBlock configureCellBlock = ^(BrickCell *brickCell) {
        brickCell.enabled = YES;
        [brickCell setupBrickCell];
        brickCell.delegate = self;
        brickCell.fragmentDelegate = self;
    };
    self.scriptDataSource = [[ScriptDataSource alloc] initWithScriptList:self.object.scriptList
                                                          cellIdentifier:nil // We don't use the same identifier for all bricks atm.
                                                      configureCellBlock:configureCellBlock];
    self.scriptDataSource.delegate = self;
    self.collectionView.dataSource = self.scriptDataSource;
    self.collectionView.delegate = self;

    // create KVO controller with observer.
    FBKVOController *KVOController = [FBKVOController controllerWithObserver:self];
    self.scriptDataSourceKVOController = KVOController;
    [self.scriptDataSourceKVOController observe:self.scriptDataSource
                                        keyPath:@"scriptList"
                                        options:NSKeyValueObservingOptionNew
                                          block:^(ScriptCollectionViewController *observer, ScriptDataSource *object, NSDictionary *change) {
                                              NSDebug(@"Script data source items changed.");
                                              weakSelf.object.scriptList = [object.scriptList mutableCopy];
                                              [weakSelf.object.program saveToDisk];
    }];
}

- (void)setupCollectionView
{
    self.collectionView.backgroundColor = [UIColor darkBlueColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.collectionViewLayout = [LXReorderableCollectionViewFlowLayout new];
    self.navigationController.title = self.title = kLocalizedScripts;
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
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
    if([brick conformsToProtocol:@protocol(BrickLookProtocol)]) {
        Brick<BrickLookProtocol> *lookBrick = (Brick<BrickLookProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            LooksTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kLooksTableViewControllerIdentifier];
            [ltvc setObject:self.object];
            ltvc.showAddLookActionSheetAtStart = YES;
            ltvc.afterSafeBlock =  ^(Look* look) {
                [lookBrick setLook:look forLineNumber:line andParameterNumber:parameter];
                [self.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:ltvc animated:YES];
            return;
        } else {
            [lookBrick setLook:[Util lookWithName:(NSString*)data forObject:self.object] forLineNumber:line andParameterNumber:parameter];
        }
    }
    if([brick conformsToProtocol:@protocol(BrickSoundProtocol)]) {
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
    if([brick conformsToProtocol:@protocol(BrickObjectProtocol)]) {
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
    if([brick conformsToProtocol:@protocol(BrickFormulaProtocol)]) {
        [(Brick<BrickFormulaProtocol>*)brick setFormula:(Formula*)data forLineNumber:line andParameterNumber:parameter];
    }
    if([brick conformsToProtocol:@protocol(BrickTextProtocol)]) {
        [(Brick<BrickTextProtocol>*)brick setText:(NSString*)data forLineNumber:line andParameterNumber:parameter];
    }
    if([brick conformsToProtocol:@protocol(BrickMessageProtocol)]) {
        Brick<BrickMessageProtocol> *messageBrick = (Brick<BrickMessageProtocol>*)brick;
        if([(NSString*)data isEqualToString:kLocalizedNewElement]) {
            [Util askUserForUniqueNameAndPerformAction:@selector(addMessageWithName:andCompletion:)
                                                target:self
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
