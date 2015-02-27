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
#import "WhenScript.h"
#import "StartScript.h"
#import "Brick.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "BrickManager.h"
#import "StartScriptCell.h"
#import "BrickTransition.h"
#import "BrickDetailViewController.h"
#import "WhenScriptCell.h"
#import "LanguageTranslationDefines.h"
#import "PlaceHolderView.h"
#import "BroadcastScriptCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickManager.h"
#import "Util.h"
#import "PlaceHolderView.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "LoopEndBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "UIUtil.h"
#import "FormulaEditorButton.h"
#import "NoteBrickTextField.h"
#import "NoteBrick.h"
#import "ScriptDataSource.h"
#import "BrickSelectionViewController.h"
#import "ScriptDataSource_Private.h"
#import "ScriptDataSource+Extensions.h"
#import "FBKVOController.h"

@interface ScriptCollectionViewController() <UICollectionViewDelegate,
                                             LXReorderableCollectionViewDelegateFlowLayout,
                                             LXReorderableCollectionViewDataSource,
                                             UIViewControllerTransitioningDelegate,
                                             BrickCellDelegate,
                                             ScriptDataSourceDelegate,
                                             iOSComboboxDelegate,
                                             UITextFieldDelegate,
                                             BrickDetailViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) BrickTransition *brickScaleTransition;
@property (nonatomic, strong) NSIndexPath *trackedIndexPath;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPaths;  // refactor
@property (nonatomic, assign) BOOL selectedAllCells;  // Refactor
@property (nonatomic, strong) NSIndexPath *higherRankBrick; // refactor
@property (nonatomic, strong) NSIndexPath *lowerRankBrick;  // refactor
@property (nonatomic, strong) ScriptDataSource *scriptDataSource;
@property (nonatomic, strong) FBKVOController *scriptDataSourceKVOController;

@end

@implementation ScriptCollectionViewController {
    kBrickCategoryType _lastSelectedBrickCategory;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    [self setupDataSource];
    [self setupCollectionView];
    [self setupSubViews];
    [self setupToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view insertSubview:self.placeHolderView aboveSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.placeHolderView.frame = self.collectionView.bounds;
}

#pragma mark - Show brick selection screen
- (void)showBrickSelectionController:(kBrickCategoryType)type {
    BrickCategoryViewController *bcvc = [[BrickCategoryViewController alloc] initWithBrickCategory:type];
    bcvc.delegate = self;
    BrickSelectionViewController *bsvc = [[BrickSelectionViewController alloc]
                                          initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                          options:@{ UIPageViewControllerOptionInterPageSpacingKey : @20.f }];

    [bsvc setViewControllers:@[ bcvc ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:NULL];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:bsvc];
    __weak typeof(&*self) weakself = self;
    [self presentViewController:navController animated:YES completion:^{
        if ([weakself.scriptDataSource.scriptList count]) {
            NSIndexPath *scrollToTopIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [weakself.collectionView scrollToItemAtIndexPath:scrollToTopIndexPath
                                            atScrollPosition:UICollectionViewScrollPositionTop
                                                    animated:NO];
        }
    }];
}

#pragma mark - Brick Selection / Play Action
- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    ScenePresenterViewController *vc = [[ScenePresenterViewController alloc] initWithProgram:[Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBricks:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self showBrickSelectionController:_lastSelectedBrickCategory];
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:[BrickDetailViewController class]] ||
        [presented isKindOfClass:[FormulaEditorViewController class]]) {
        self.brickScaleTransition.transitionMode = TransitionModePresent;
        return self.brickScaleTransition;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController*)dismissed
{
    if ([dismissed isKindOfClass:[BrickDetailViewController class]] ||
        [dismissed isKindOfClass:[FormulaEditorViewController class]]) {
        self.brickScaleTransition.transitionMode = TransitionModeDismiss;
        return self.brickScaleTransition;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
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
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:indexPath];

    [self.brickScaleTransition updateAnimationViewWithView:brickCell];
    if (!self.isEditing) {
        self.trackedIndexPath =  indexPath;
        BrickDetailViewController *vc = [BrickDetailViewController brickDetailViewControllerWithScriptOrBrick:brickCell.scriptOrBrick];
        vc.delegate = self;
        vc.transitioningDelegate = self;
        [self presentViewController:vc animated:YES completion:NULL];
    }
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
    return ((self.isEditing || indexPath.item == 0) ? NO : YES);
}

#pragma mark - UITextfield Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)textFieldFinished:(id)sender
{
    NoteBrickTextField *noteBrickTextField = (NoteBrickTextField*)sender;
    NoteBrick *noteBrick = (NoteBrick*)noteBrickTextField.cell.scriptOrBrick;
    noteBrick.note = noteBrickTextField.text;
    [noteBrickTextField update];
    [noteBrickTextField resignFirstResponder];
}

#pragma mark - ScriptDataSourceDelegate
- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource stateChanged:(ScriptDataSourceState)state error:(NSError*)error
{
    NSLog(@"Script data source state changed: %lu", state);
}

- (void)scriptDataSource:(ScriptDataSource*)scriptDataSource didRemoveSections:(NSIndexSet *)sections
{
    [self.collectionView deleteSections:sections];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

- (void)scriptDataSource:(ScriptDataSource *)scriptDataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

-(void)scriptDataSource:(ScriptDataSource *)scriptDataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath
                                                                        toIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:newIndexPath];
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
    }];
}

#pragma mark - BrickDetailViewControllerDelegate

- (void)brickDetailViewController:(BrickDetailViewController *)brickDetailViewController
                   didChangeState:(BrickDetailViewControllerState)state
{
    switch (brickDetailViewController.state) {
        case BrickDetailViewControllerStateNone:
        case BrickDetailViewControllerStateBrickUpdated:
            break;
        case BrickDetailViewControllerStateDeleteScript:
            [self removeScript];
            break;
        case BrickDetailViewControllerStateDeleteBrick:
            [self removeBrick];
            break;
        case BrickDetailViewControllerStateCopyBrick:
            [self copyBrick];
            break;
        case BrickDetailViewControllerStateAnimateBrick:
            // TODO
            break;
        case BrickDetailViewControllerStateEditFormula: {
            // TODO:
            BrickCell *brickCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:self.trackedIndexPath];
            FormulaEditorButton *formulaEditorButton = (FormulaEditorButton *)[UIUtil newDefaultBrickFormulaEditorWithFrame:CGRectMake(0, 0, 0, 0)
                                                                                                               ForBrickCell:brickCell
                                                                                                              AndLineNumber:0
                                                                                                         AndParameterNumber:0];
            [self openFormulaEditor:formulaEditorButton];
        }
            break;
            
        default:
            break;
    }
}

- (void)removeBrick
{
    [self.scriptDataSource removeBrickAtIndexPath:self.trackedIndexPath];
}

- (void)removeScript
{
    [self.scriptDataSource removeScriptsAtSections:[NSIndexSet indexSetWithIndex:self.trackedIndexPath.section]];
}

- (void)copyBrick
{
    [self.scriptDataSource copyBrickAtIndexPath:self.trackedIndexPath];
}

- (void)animateBrick
{
}

- (void)editFormula
{
    BrickCell *brickCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:self.trackedIndexPath];
    FormulaEditorButton *formulaEditorButton = (FormulaEditorButton *)[UIUtil newDefaultBrickFormulaEditorWithFrame:CGRectMake(0, 0, 0, 0)
                                                                                                       ForBrickCell:brickCell
                                                                                                      AndLineNumber:0
                                                                                                 AndParameterNumber:0];
    [self openFormulaEditor:formulaEditorButton];
}

#pragma mark - BrickCategoryViewController delegates
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    _lastSelectedBrickCategory = scriptOrBrick.brickCategoryType;
    brickCategoryViewController.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"[ %@ ] selected", scriptOrBrick);

#warning README first!
    // NOTE: experimental code!!! should be moved to BrickManager
    //       I've absolutely no idea what's going on here with this odd ScriptDataSource class...
    //       I'd suggest implementing a datasource protocol in BrickManager instead
    //       But work should be splitted up and moved into ProgramManager, ScriptManager, BrickManager...
    if ([scriptOrBrick isKindOfClass:[Script class]]) {
        // add script to script list
        Script *script = (Script*)scriptOrBrick;
        [self.object.scriptList addObject:script];
    } else if ([scriptOrBrick isKindOfClass:[Brick class]]) {
        // check if there exists a script yet
        // if not, create StartScript first
        if (! [self.object.scriptList count]) {
            [self.object.scriptList addObject:[StartScript new]];
        }
        // now add brick to the first script in list
        Script *firstScript = [self.object.scriptList firstObject];
        Brick *brickToAdd = (Brick*)scriptOrBrick;
        [firstScript.brickList addObject:brickToAdd];
        if ([brickToAdd isKindOfClass:[IfLogicBeginBrick class]]) {
            IfLogicBeginBrick *ifBeginBrick = (IfLogicBeginBrick*)brickToAdd;

            IfLogicElseBrick *elseBrick = [IfLogicElseBrick new];
            IfLogicEndBrick *endBrick = [IfLogicEndBrick new];

            ifBeginBrick.ifElseBrick = elseBrick;
            ifBeginBrick.ifEndBrick = endBrick;

            elseBrick.ifBeginBrick = ifBeginBrick;
            elseBrick.ifEndBrick = endBrick;

            endBrick.ifBeginBrick = ifBeginBrick;
            endBrick.ifElseBrick = elseBrick;

            [firstScript.brickList addObject:elseBrick];
            [firstScript.brickList addObject:endBrick];
        } else if ([brickToAdd isKindOfClass:[LoopBeginBrick class]]) {
            LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)brickToAdd;
            LoopEndBrick *loopEndBrick = [LoopEndBrick new];
            loopBeginBrick.loopEndBrick = loopEndBrick;
            loopEndBrick.loopBeginBrick = loopBeginBrick;
            [firstScript.brickList addObject:loopEndBrick];
        }
    }
    [self.object.program saveToDisk];
    [self.collectionView reloadData];
}

#pragma mark - Brick Cell Delegate
- (void)BrickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton
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
    
    [self.collectionView reloadData];
}

#pragma mark - Open Formula Editor
- (void)openFormulaEditor:(FormulaEditorButton*)button
{
    if([button isKindOfClass:[FormulaEditorButton class]]) {
        if([self.presentedViewController isKindOfClass:[FormulaEditorViewController class]]) {
            FormulaEditorViewController *formulaEditorViewController = (FormulaEditorViewController*)self.presentedViewController;
            if ([formulaEditorViewController changeFormula]) {
                [formulaEditorViewController setFormula:button.formula];
            }
            
        } else {
            // Check if allready presenting a view controller.
            if (self.presentedViewController.isViewLoaded && self.presentedViewController.view.window) {
                [self.presentedViewController dismissViewControllerAnimated:NO completion:NULL];
            }
            
            FormulaEditorViewController *formulaEditorViewController = [[FormulaEditorViewController alloc] initWithBrickCell: button.brickCell];
            formulaEditorViewController.object = self.object;
            formulaEditorViewController.transitioningDelegate = self;
            formulaEditorViewController.modalPresentationStyle = UIModalPresentationCustom;
            
            [self presentViewController:formulaEditorViewController animated:YES completion:^{
                [formulaEditorViewController setFormula:button.formula];
            }];
        }
    }
}

#pragma mark - Helpers
- (void)removeBricksWithIndexPaths:(NSArray *)indexPaths
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
        self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
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
        if (!foundElse) {
            if ([checkBrick isEqual:beginBrick.ifElseBrick]) {
                foundElse = YES;
            }else{
                countElse++;
            }
        }
        if ([checkBrick isEqual:beginBrick.ifEndBrick]) {
            break;
        }else{
            countEnd++;
        }
        
    }
    NSIndexPath* elsePath =[NSIndexPath indexPathForItem:countElse+1 inSection:indexPath.section];
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:countEnd+1 inSection:indexPath.section];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths setObject:indexPath forKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths setObject:elsePath forKey:[self keyWithSelectIndexPath:elsePath]];
        [self.selectedIndexPaths setObject:endPath forKey:[self keyWithSelectIndexPath:endPath]];
    } else {
        selectButton.selected = NO;
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:indexPath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:elsePath]];
        [self.selectedIndexPaths removeObjectForKey:[self keyWithSelectIndexPath:endPath]];
    }
    
}

-(void)selectLogicElseWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    IfLogicElseBrick *elseBrick = (IfLogicElseBrick *)brick;
    
    NSInteger countBegin = 0;
    NSInteger countEnd = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (!foundIf) {
            if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                foundIf = YES;
            }else{
                countBegin++;
            }
        }
        if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
            break;
        }else{
            countEnd++;
        }
        
    }
    NSIndexPath* beginPath =[NSIndexPath indexPathForItem:countBegin+1 inSection:indexPath.section];
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:countEnd+1 inSection:indexPath.section];
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
    IfLogicEndBrick *endBrick = (IfLogicEndBrick *)brick;
    
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
-(void)animate:(NSIndexPath *)indexPath brickCell:(BrickCell*)brickCell
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
        
    }else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
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
        
    }else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
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
    __weak typeof(&*self)weakself = self;
    ScriptCollectionViewConfigureBlock configureCellBlock = ^(id cell) {
        [weakself configureBrickCell:cell];
    };
    self.scriptDataSource = [[ScriptDataSource alloc] initWithScriptList:self.object.scriptList
                                                          cellIdentifier:nil // We dont use the same identifier for all bricks atm.
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
                                          block:^(id observer, id object, NSDictionary *change) {
                                              NSDebug(@"Script data source items changed.");
                                              Program *program = weakself.object.program;
                                              [program saveToDisk];
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

- (void)configureBrickCell:(BrickCell *)brickCell
{
    brickCell.enabled = YES;
    [brickCell setupBrickCell];
    brickCell.delegate = self;
    brickCell.textDelegate = self;
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
                                                                         action:@selector(showBricks:)];
    
    add.enabled =  !self.editing;
    
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    play.enabled = !self.editing;
    
    if (self.editing) {
        self.toolbarItems = @[flexItem,invisibleButton, delete, invisibleButton, flexItem];
    } else {
        self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                              flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
    }
}

#pragma mark - Init SubViews
- (void)setupSubViews
{
    self.placeHolderView = [[PlaceHolderView alloc] initWithTitle:kLocalizedScripts];
    self.placeHolderView.hidden = self.object.scriptList.count ? YES : NO;
}

@end
