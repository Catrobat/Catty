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
#import "BrickCellFormulaData.h"
#import "NoteBrick.h"
#import "BrickSelectionViewController.h"
#import "BrickCellDataProtocol.h"
#import "BrickLookProtocol.h"
#import "BrickSoundProtocol.h"
#import "BrickObjectProtocol.h"
#import "BrickTextProtocol.h"
#import "BrickMessageProtocol.h"
#import "BrickVariableProtocol.h"
#import "BrickCellLookData.h"
#import "BrickCellSoundData.h"
#import "BrickCellObjectData.h"
#import "BrickCellTextData.h"
#import "BrickCellMessageData.h"
#import "BrickCellVariableData.h"
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
#import "OrderedMapTable.h"
#import "BrickInsertManager.h"
#import "BrickMoveManager.h"

@interface ScriptCollectionViewController() <UICollectionViewDelegate,
                                             UICollectionViewDataSource,
                                             LXReorderableCollectionViewDelegateFlowLayout,
                                             LXReorderableCollectionViewDataSource,
                                             UIViewControllerTransitioningDelegate,
                                             BrickCellDelegate,
                                             iOSComboboxDelegate,
                                             BrickCellDataDelegate,
                                             CatrobatActionSheetDelegate>

@property (nonatomic, strong) PlaceHolderView *placeHolderView;
@property (nonatomic, strong) BrickTransition *brickScaleTransition;
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;  // refactor
@property (nonatomic, strong) NSMutableArray *selectedIndexPositions;  // refactor
@property (nonatomic, assign) BOOL selectedAllCells;  // refactor
@property (nonatomic, assign) BOOL scrollEnd;  // refactor
@property (nonatomic, strong) NSIndexPath *variableIndexPath;
@property (nonatomic, assign) BOOL isInsertingBrickMode;
@property (nonatomic, assign) BOOL isEditingBrickMode;
@property (nonatomic) PageIndexCategoryType lastSelectedBrickCategory;

@end

@implementation ScriptCollectionViewController

#define kBrickCellInactiveWhileEditingOpacity 0.7f
#define kBrickCellInactiveWhileInsertingOpacity 0.7f
#define kBrickCellActiveOpacity 1.0f

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

@dynamic collectionView;

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
    self.isInsertingBrickMode = NO;
    self.isEditingBrickMode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.cancelsTouchesInView = YES;
    [[BrickMoveManager sharedInstance] reset];
}

#pragma mark - actions
- (void)playSceneAction:(id)sender
{
    [self playSceneAction:sender animated:YES];
}

- (void)playSceneAction:(id)sender animated:(BOOL)animated
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
        BrickCategoryViewController *bcvc = [[BrickCategoryViewController alloc] initWithBrickCategory:self.lastSelectedBrickCategory andObject:self.object];
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
        [self presentViewController:navController animated:YES completion:NULL];
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !self.isEditingBrickMode;
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
            [self.selectedIndexPaths addObject:indexPath ];
        }
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    if (self.isInsertingBrickMode) {
        [self turnOffInsertingBrickMode];
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        Brick *brick = [script.brickList objectAtIndex:indexPath.item - 1];
        [self insertBrick:brick andIndexPath:indexPath];
        return;
    }

    BOOL isBrick = [brickCell.scriptOrBrick isKindOfClass:[Brick class]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    if (isBrick) {
        [buttonTitles addObject:kLocalizedCopyBrick];
        [buttonTitles addObject:kLocalizedMoveBrick];
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
    [self disableUserInteractionAndHighlight:brickCell withMarginBottom:actionSheet.frame.size.height];
}

#pragma mark - action sheet delegates
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
    NSIndexPath *indexPath = payload[kDTPayloadCellIndexPath]; // unwrap payload message
    BrickCell *brickCell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self reloadData];
    } else if (actionSheet.tag == kEditBrickActionSheetTag) {
        CBAssert(actionSheet.dataTransferMessage.actionType == kDTMActionEditBrickOrScript);
        CBAssert([actionSheet.dataTransferMessage.payload isKindOfClass:[NSDictionary class]]);
        IBActionSheetButton *selectedButton = [actionSheet.buttons objectAtIndex:buttonIndex];
        NSString *buttonTitle = selectedButton.titleLabel.text;
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // delete script or brick action
            [self removeBrickOrScript:brickCell.scriptOrBrick atIndexPath:indexPath];
        } else if ([buttonTitle isEqualToString:kLocalizedCopyBrick]) {
            // copy brick action
            CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            [self copyBrick:(Brick*)brickCell.scriptOrBrick atIndexPath:indexPath];
        } else if ([buttonTitle isEqualToString:kLocalizedEditFormula]) {
            // edit formula
            BrickCellFormulaData *formulaData = (BrickCellFormulaData*)[brickCell dataSubviewWithType:[BrickCellFormulaData class]];
            [self openFormulaEditor:formulaData withEvent:nil];
        } else if ([buttonTitle isEqualToString:kLocalizedAnimateBrick]) {
            // animate brick
            CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            [self animate:indexPath brickCell:brickCell];
        } else if ([buttonTitle isEqualToString:kLocalizedMoveBrick]) {
            // move Brick
            CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            Brick *brick = (Brick*)brickCell.scriptOrBrick;
            brick.animateInsertBrick = YES;
            [self turnOnInsertingBrickMode];
            [self reloadData];
        }
    } else if (actionSheet.tag == kVariabletypeActionSheetTag){
        CBAssert(actionSheet.dataTransferMessage.actionType == kDTMActionEditBrickOrScript);
        CBAssert([actionSheet.dataTransferMessage.payload isKindOfClass:[NSDictionary class]]);
        CBAssert([brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
        IBActionSheetButton *selectedButton = [actionSheet.buttons objectAtIndex:buttonIndex];
        BOOL isProgramVar = [selectedButton.titleLabel.text isEqualToString:kUIFEActionVarPro];
        [self addVariableForBrick:(Brick*)brickCell.scriptOrBrick atIndexPath:indexPath andIsProgramVariable:isProgramVar];
    }
    [self enableUserInteractionAndResetHighlight];
}

- (void)actionSheetCancelOnTouch:(CatrobatActionSheet *)actionSheet
{
    [self enableUserInteractionAndResetHighlight];
}

#pragma mark - Reorderable Cells Delegate
- (void)collectionView:(UICollectionView*)collectionView
       itemAtIndexPath:(NSIndexPath*)fromIndexPath
   willMoveToIndexPath:(NSIndexPath*)toIndexPath
{
// FIXME: UPDATING THE DATA MODEL WHILE THE USER IS DRAGGING IS NO GOOD PRACTICE AND IS ERROR PRONE!!!
//        USE collectionView:layout:didEndDraggingItemAtIndexPath: DELEGATE METHOD FOR THIS. Updates must happen after the user stopped dragging the brickcell!!
    
    if (fromIndexPath.section == toIndexPath.section) {
        Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
        [script.brickList removeObjectAtIndex:toIndexPath.item - 1];
        [script.brickList insertObject:toBrick atIndex:fromIndexPath.item - 1];
    } else {

        Script *toScript = [self.object.scriptList objectAtIndex:toIndexPath.section];
        Script *fromScript = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
        if ([toScript.brickList count] == 0) {
            [fromScript.brickList removeObjectAtIndex:fromIndexPath.item - 1];
            [toScript.brickList addObject:fromBrick];
            LXReorderableCollectionViewFlowLayout *layout =  (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
            [layout setUpGestureRecognizersOnCollectionView];
            return;
        }
        Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
        [toScript.brickList removeObjectAtIndex:toIndexPath.item - 1];
        [toScript.brickList insertObject:fromBrick atIndex:toIndexPath.item - 1];
        [toScript.brickList insertObject:toBrick atIndex:toIndexPath.item];
        if ([fromScript.brickList count] == 1) {
            [fromScript.brickList removeAllObjects];
        } else {
            [fromScript.brickList removeObjectAtIndex:fromIndexPath.item - 1];
        }
    }
}

- (void)collectionView:(UICollectionView*)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
didEndDraggingItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.isInsertingBrickMode) {
        NSLog(@"INSERT ALL BRICKS");
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        Brick *brick;
        if (script.brickList.count > 1) {
            brick = [script.brickList objectAtIndex:indexPath.item - 1];
        }else{
            brick = [script.brickList objectAtIndex:indexPath.item];
        }
        if (brick.isAnimatedInsertBrick) {
            [self insertBrick:brick andIndexPath:indexPath];
            [self turnOffInsertingBrickMode];
        }else{
            return;
        }
    }
    [self reloadInputViews];
    [self reloadData];
    [self.object.program saveToDisk];
}

- (void)collectionView:(UICollectionView*)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
willBeginDraggingItemAtIndexPath:(NSIndexPath*)indexPath
{
    [[BrickMoveManager sharedInstance] reset];
}

- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canMoveToIndexPath:(NSIndexPath*)toIndexPath
{
    if (self.isInsertingBrickMode) {
        return [[BrickInsertManager sharedInstance] collectionView:self.collectionView itemAtIndexPath:fromIndexPath canInsertToIndexPath:toIndexPath andObject:self.object];
    }
        
    return [[BrickMoveManager sharedInstance] collectionView:self.collectionView itemAtIndexPath:fromIndexPath canMoveToIndexPath:toIndexPath andObject:self.object];
}


- (BOOL)collectionView:(UICollectionView*)collectionView canMoveItemAtIndexPath:(NSIndexPath*)indexPath
{
    return ((self.isEditing || indexPath.item == 0) ? NO : YES);
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
        script.animate = NO;
    } else {
        brick = [script.brickList objectAtIndex:indexPath.item - 1];
        cellIdentifier = NSStringFromClass([brick class]);
    }
    brickCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    brickCell.scriptOrBrick = ((indexPath.item == 0) ? script : brick);
    brickCell.enabled = YES;
    [brickCell setupBrickCell];
    brickCell.delegate = self;
    brickCell.dataDelegate = self;

    if (brickCell.scriptOrBrick.isAnimated) {
        [brickCell animate:YES];
    }
    if (brickCell.scriptOrBrick.isAnimatedInsertBrick) {
        [brickCell insertAnimate:brickCell.scriptOrBrick.isAnimatedInsertBrick];
    }
    if (self.isEditing) {
        brickCell.center = CGPointMake(brickCell.center.x + kSelectButtonTranslationOffsetX, brickCell.center.y);
        brickCell.selectButton.alpha = 1.0f;
        if(!brickCell.isScriptBrick)
        {
            Brick *selectBrick = (Brick*)brickCell.scriptOrBrick;
            if (selectBrick.isSelected) {
                brickCell.selectButton.selected = YES;
            }else{
                brickCell.selectButton.selected = NO;
            }
        }else{
            Script *selectScript = (Script *)brickCell.scriptOrBrick;
            if (selectScript.isSelected) {
                brickCell.selectButton.selected = YES;
            }else{
                brickCell.selectButton.selected = NO;
            }
        }
    }else{
      brickCell.selectButton.selected = NO;
    }
    brickCell.enabled = (! self.isEditing);
    if (self.isInsertingBrickMode) {
        if (brickCell.scriptOrBrick.isAnimatedInsertBrick) {
            brickCell.userInteractionEnabled = YES;
        } else {
            brickCell.userInteractionEnabled = NO;
            brickCell.alpha = kBrickCellInactiveWhileInsertingOpacity;
        }
    } else {
        brickCell.userInteractionEnabled = YES;
        brickCell.alpha = self.isEditingBrickMode ? kBrickCellInactiveWhileEditingOpacity : kBrickCellActiveOpacity;
    }
    return brickCell;
}


#pragma mark - BrickCategoryViewController delegates
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<ScriptProtocol>)scriptOrBrick
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    scriptOrBrick = [scriptOrBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    self.lastSelectedBrickCategory = brickCategoryViewController.pageIndexCategoryType;
    brickCategoryViewController.delegate = nil;
    self.placeHolderView.hidden = YES;

    if ([scriptOrBrick isKindOfClass:[Script class]]) {
        Script *script = (Script*)scriptOrBrick;
        script.object = self.object;
        [self.object.scriptList addObject:script];
        script.animate = YES;
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:(self.object.scriptList.count - 1)]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
        [self.object.program saveToDisk];
        return;
    }
    // empty script list, insert start script and continue to insert the chosen brick
    if (self.object.scriptList.count == 0) {
        StartScript *script = [StartScript new];
        script.object = self.object;
        [self.object.scriptList addObject:script];
        script.animate = YES;
        [self.collectionView reloadData];
        [self.object.program saveToDisk];
    }

    NSInteger targetScriptIndex = 0;
    BOOL smallScript = NO;
    CGRect visibleRect = (CGRect){.origin = self.collectionView.contentOffset, .size = self.collectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.collectionView indexPathForItemAtPoint:visiblePoint];
    if (visibleIndexPath) {
        targetScriptIndex = visibleIndexPath.section;
    } else{
        targetScriptIndex = 0;
        smallScript = YES;
    }

    Brick *brick = (Brick*)scriptOrBrick;
    Script *targetScript = self.object.scriptList[targetScriptIndex];
    brick.script = targetScript;
    NSInteger index = brick.script.brickList.count;
    NSInteger insertionIndex = visibleIndexPath.row;
    BOOL hasForeverLoop = NO;
    if (targetScript.brickList.count >=1) {
        while ([[targetScript.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick* loopEndBrickCheck = [targetScript.brickList objectAtIndex:index-1];
            if ([loopEndBrickCheck.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                insertionIndex = index-1;
                hasForeverLoop = YES;
            }
            index--;
        }
    }
    if ((smallScript || self.scrollEnd) && !hasForeverLoop ) {
        [targetScript.brickList addObject:brick];
    }else{
        [targetScript.brickList insertObject:brick atIndex:insertionIndex];
    }
    // empty script list, insert first brick and continue
    if (targetScript.brickList.count == 1) {
        
        [self insertBrick:brick andIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.object.scriptList.count-1]];
        return;
    }
    
    brick.animateInsertBrick = YES;
    
    [self.collectionView reloadData];
    [self turnOnInsertingBrickMode];
//    [self.object.program saveToDisk];
    
}


#pragma mark - Brick Cell Delegate
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
    if (! indexPath) {
        return;
    }

    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    if (! script.brickList.count) {
        if (!selectButton.selected) {
            selectButton.selected = YES;
            script.isSelected = YES;
            [self.selectedIndexPaths addObject:indexPath];
        }else{
            selectButton.selected = NO;
            script.isSelected = NO;
            [self.selectedIndexPaths removeObject:indexPath];
        }
        return;
    }
    if (brickCell.isScriptBrick) {
        if (!selectButton.selected) {
            selectButton.selected = YES;
            script.isSelected = YES;
            [self.selectedIndexPaths addObject:indexPath];
            for (Brick *brick in script.brickList) {
                brick.isSelected = YES;
            }
        }else{
            selectButton.selected = NO;
            script.isSelected = NO;
            [self.selectedIndexPaths removeObject:indexPath];
            for (Brick *brick in script.brickList) {
                brick.isSelected = NO;
            }

        }
    }else{
    Brick *brick =[script.brickList objectAtIndex:indexPath.item - 1];
        if (!brick.script.isSelected) {
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
            } else if (! selectButton.selected) {
                selectButton.selected = selectButton.touchInside;
                brick.isSelected = selectButton.touchInside;
                [self.selectedIndexPaths addObject:indexPath];
            } else {
                selectButton.selected = NO;
                brick.isSelected = NO;
                [self.selectedIndexPaths removeObject:indexPath];
            }
        }

    }
    [self reloadData];
}

#pragma mark - Open Formula Editor
- (void)openFormulaEditor:(BrickCellFormulaData*)formulaData withEvent:(UIEvent*)event
{
    if (self.isEditingBrickMode && event) {
        return;
    }
    if ([self.presentedViewController isKindOfClass:[FormulaEditorViewController class]]) {
        FormulaEditorViewController *formulaEditorViewController = (FormulaEditorViewController*)self.presentedViewController;
        BOOL forceChange = NO;
        if (event != nil && ((UITouch*)[[event allTouches] anyObject]).tapCount == 2)
            forceChange = YES;
        [formulaEditorViewController changeBrickCellFormulaData:formulaData andForce:forceChange];
        return;
    }

    // Check if already presenting a view controller.
    if (self.presentedViewController.isViewLoaded && self.presentedViewController.view.window) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:NULL];
    }

    FormulaEditorViewController *formulaEditorViewController = [[FormulaEditorViewController alloc] initWithBrickCellFormulaData:formulaData];
    formulaEditorViewController.object = self.object;
    formulaEditorViewController.transitioningDelegate = self;
    formulaEditorViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self.brickScaleTransition updateAnimationViewWithView:formulaData.brickCell];
    [self presentViewController:formulaEditorViewController animated:YES completion:^{
        [formulaEditorViewController setBrickCellFormulaData:formulaData];
    }];
}

#pragma mark - Helpers
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.editing) {
        [self setEditing:YES animated:NO];
        [self.collectionView reloadData];
    }
    self.scrollEnd = NO;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        self.scrollEnd = YES;
    } else {
        self.scrollEnd = NO;
    }
}
- (void)scrollViewWillEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        self.scrollEnd = YES;
    } else {
        self.scrollEnd = NO;
    }
}


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
        [self.object.program saveToDisk];
    }];
}

- (void)selectAllBricks
{
    if (! self.selectedAllCells) {
        self.selectedAllCells = YES;
        for (BrickCell *cell in self.collectionView.visibleCells) {
            cell.selectButton.selected = YES;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            [self.selectedIndexPaths addObject:indexPath];
        }
        return;
    }

    self.selectedAllCells = NO;
    for (BrickCell *cell in self.collectionView.visibleCells) {
        cell.selectButton.selected = NO;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self.selectedIndexPaths removeObject:indexPath];
    }
}

- (NSString*)keyWithSelectIndexPath:(NSIndexPath*)indexPath
{
    return [NSString stringWithFormat:@"%@_%@", @(indexPath.section), @(indexPath.item)];
}

-(void)deleteSelectedBricks
{
    [self removeBricksWithIndexPaths:self.selectedIndexPaths];
    [self setEditing:NO animated:NO];
}

-(void)turnOnInsertingBrickMode
{
    self.isInsertingBrickMode = YES;
    for (UIButton *button in self.navigationController.toolbar.items) {
        button.enabled = NO;
    }
    LXReorderableCollectionViewFlowLayout *layout = (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.longPressGestureRecognizer.minimumPressDuration = 0.1;
    self.navigationController.navigationBar.topItem.leftBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.topItem.backBarButtonItem.enabled = NO;
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

-(void)turnOffInsertingBrickMode
{
    self.isInsertingBrickMode = NO;
    for (UIButton *button in self.navigationController.toolbar.items) {
        button.enabled = YES;
    }
    LXReorderableCollectionViewFlowLayout *layout = (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.longPressGestureRecognizer.minimumPressDuration = 0.5;
    self.navigationController.navigationBar.topItem.leftBarButtonItem.enabled = YES;
    self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = YES;
    self.navigationController.navigationBar.topItem.backBarButtonItem.enabled = YES;
    [self.navigationItem setHidesBackButton:NO animated:NO];
}

#pragma mark - Editing
// TODO: Refactor
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (self.isEditing) {
        self.navigationItem.title = kLocalizedDeletionMenu;
        self.navigationItem.rightBarButtonItem.title = kLocalizedCancel;

        [UIView animateWithDuration:animated ? 0.5f : 0.0f  delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            for (BrickCell *brickCell in self.collectionView.visibleCells) {
                if (animated) {
                    brickCell.center = CGPointMake(brickCell.center.x + kSelectButtonTranslationOffsetX, brickCell.center.y);
                }
                brickCell.selectButton.alpha = 1.0f;
            }
        } completion:^(BOOL finished) {
            for (BrickCell *brickCell in self.collectionView.visibleCells) {
                brickCell.enabled = NO;
            }
        }];
    } else {
        self.navigationItem.title = kLocalizedScripts;
        self.navigationItem.rightBarButtonItem.title = kLocalizedDelete;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor navTintColor];
        
        [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0.0f usingSpringWithDamping:0.65f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             for (BrickCell *brickCell in self.collectionView.visibleCells) {
                                 brickCell.center = CGPointMake(self.view.center.x, brickCell.center.y);
                                 brickCell.selectButton.alpha = 0.0f;
                             }
                         } completion:^(BOOL finished) {
                             for (BrickCell *brickCell in self.collectionView.visibleCells) {
                                 brickCell.enabled = YES;
                               brickCell.selectButton.selected = NO;
                             }
                             for (Script *script in self.object.scriptList) {
                                 script.isSelected = NO;
                                 for (Brick *brick in script.brickList) {
                                     brick.isSelected = NO;
                                 }
                             }
                           self.selectedIndexPaths = [NSMutableArray new];
                         }];
        
    }
    [self setupToolBar];
}


#pragma mark - selectLogic/Loop bricks
-(void)selectLoopBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    LoopBeginBrick *beginBrick = (LoopBeginBrick*)brick;
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:beginBrick.loopEndBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:endPath];
        endBrick.isSelected = YES;
        beginBrick.isSelected =YES;
    } else {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:endPath];
    }
}

-(void)selectLoopEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    LoopEndBrick *endBrick = (LoopEndBrick*)brick;
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:endBrick.loopBeginBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* beginPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        beginBrick.isSelected = YES;
        endBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
    } else {
        selectButton.selected = NO;
        beginBrick.isSelected = NO;
        endBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:beginPath];
    }
}

- (void)selectLogicBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick*)brick;
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
    Brick *elseBrick =[script.brickList objectAtIndex:elsePath.item - 1];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (selectButton.selected) {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        elseBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:elsePath];
        [self.selectedIndexPaths removeObject:endPath];
    } else {
        selectButton.selected = selectButton.touchInside;
        endBrick.isSelected = YES;
        elseBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:elsePath];
        [self.selectedIndexPaths addObject:endPath];
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
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        endBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        elseBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:endPath];
    } else {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        elseBrick.isSelected = NO;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:endPath];
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
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    Brick *elseBrick =[script.brickList objectAtIndex:elsePath.item - 1];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        elseBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        endBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:elsePath];
    } else {
        selectButton.selected = NO;
        elseBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        endBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:beginPath];
        [self.selectedIndexPaths removeObject:elsePath];
    }
}

#pragma mark - Insert Brick Logic
-(void)insertBrick:(Brick*)brick andIndexPath:(NSIndexPath*)path
{
    Script *targetScript = self.object.scriptList[path.section];
    brick.script = targetScript;
    NSInteger insertionIndex = path.row;
    NSInteger check = [self checkForeverLoopEndBrickWithStartingIndex:insertionIndex andScript:targetScript];
    if (check != -1) {
        insertionIndex = check - 1;
    }
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
        ifElseBrick.script = targetScript;
        ifEndBrick.script = targetScript;
        ifElseBrick.animate = YES;
        ifEndBrick.animate = YES;
        [targetScript.brickList insertObject:ifEndBrick atIndex:insertionIndex];
        [targetScript.brickList insertObject:ifElseBrick atIndex:insertionIndex];
    } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)brick;
        LoopEndBrick *loopEndBrick = [LoopEndBrick new];
        loopBeginBrick.loopEndBrick = loopEndBrick;
        loopEndBrick.loopBeginBrick = loopBeginBrick;
        loopEndBrick.script = targetScript;
        loopEndBrick.animate = YES;
        if ([loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            NSInteger index = loopBeginBrick.script.brickList.count;
            insertionIndex = index;
            if (targetScript.brickList.count >=1) {
                while ([[targetScript.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
                    LoopEndBrick* loopEndBrickCheck = [targetScript.brickList objectAtIndex:index-1];
                    NSInteger loopbeginIndex = 0;
                    for (Brick *brick in targetScript.brickList) {
                        if (brick  == loopEndBrickCheck.loopBeginBrick) {
                            break;
                        }
                        loopbeginIndex++;
                    }
                    if (loopbeginIndex < path.row) {
                        insertionIndex = index-1;
                    } else if(loopbeginIndex > path.row){
                        insertionIndex = index;
                    }else{
                            //should not be possible
                        insertionIndex = index;
                    }
                    index--;
                }
                if ([self checkForeverBrickInsideLogicBricks:targetScript andIndexPath:path]) {
                    insertionIndex = path.row;
                }
                if ([self checkForeverBrickInsideRepeatBricks:targetScript andIndexPath:path]) {
                    insertionIndex = path.row;
                }
            }
        }
        [targetScript.brickList insertObject:loopEndBrick atIndex:insertionIndex];
        
    }
    brick.animateInsertBrick = NO;
    [self.collectionView reloadData];
    [self.collectionView setNeedsDisplay];
    [self.object.program saveToDisk];
}

-(BOOL)checkForeverBrickInsideLogicBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    NSInteger logicBrickCounter = 0;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[IfLogicBeginBrick class]]||[brick isKindOfClass:[IfLogicElseBrick class]])) {
            logicBrickCounter++;
        }
        if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
            logicBrickCounter -= 2;
        }
    }
    if (logicBrickCounter != 0) {
        switch (logicBrickCounter) {
            case 1:
            case 2:
                return YES;
                break;
            default:
                break;
        }
    }
    return NO;
}

-(BOOL)checkForeverBrickInsideRepeatBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    NSInteger repeatBrickCounter = 0;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[LoopBeginBrick class]]&&(![brick isKindOfClass:[ForeverBrick class]]))) {
            repeatBrickCounter++;
        }
        if ([brick isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick* endBrick = (LoopEndBrick*)brick;
            if (![endBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                repeatBrickCounter -= 1;
            }
        }
    }
    if (repeatBrickCounter != 0) {
        switch (repeatBrickCounter) {
            case 1:
                return YES;
                break;
            default:
                break;
        }
    }
    return NO;
}

-(NSInteger)checkForeverLoopEndBrickWithStartingIndex:(NSInteger)counter andScript:(Script*)script
{
        //Check if there is a Forever Loop End-brick
    while (counter >= 1) {
        if ([[script.brickList objectAtIndex:counter-1] isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick *brick =[script.brickList objectAtIndex:counter-1];
            if ([brick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                return counter;
            }
        }
        counter--;
    }
    return -1;
}

#pragma mark - Animate Logic Bricks
-(void)animate:(NSIndexPath*)indexPath brickCell:(BrickCell*)brickCell
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [brickCell animate:YES];
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
        [cell animate:YES];
    });
}

-(void)animateIf:(NSInteger)count1 and:(NSInteger)count2 andIndexPath:(NSIndexPath*)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell *elsecell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count1+1 inSection:indexPath.section]];
        BrickCell *begincell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count2+1 inSection:indexPath.section]];
        [elsecell animate:YES];
        [begincell animate:YES];
    });
}

#pragma mark - Copy Brick
- (void)copyBrick:(Brick*)brick atIndexPath:(NSIndexPath*)indexPath
{
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
}

#pragma mark - Remove Brick
- (void)removeBrickOrScript:(id<ScriptProtocol>)scriptOrBrick
                atIndexPath:(NSIndexPath*)indexPath
{
    if ([scriptOrBrick isKindOfClass:[Script class]]) {
        [(Script*)scriptOrBrick removeFromObject];
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    } else {
        CBAssert([scriptOrBrick isKindOfClass:[Brick class]]);
        Brick *brick = (Brick*)scriptOrBrick;
        if ([brick isLoopBrick]) {
            // loop brick
            LoopBeginBrick *loopBeginBrick = nil;
            LoopEndBrick *loopEndBrick = nil;
            if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                loopBeginBrick = ((LoopBeginBrick*)brick);
                NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
                [loopBeginBrick removeFromScript];
                NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[loopBeginIndexPath]];
                loopEndBrick = loopBeginBrick.loopEndBrick;
                NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
                [loopEndBrick removeFromScript];
                NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[loopEndIndexPath]];
            } else {
                CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
                loopEndBrick = ((LoopEndBrick*)brick);
                NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
                [loopEndBrick removeFromScript];
                NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[loopEndIndexPath]];
                loopBeginBrick = loopEndBrick.loopBeginBrick;
                NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
                [loopBeginBrick removeFromScript];
                NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[loopBeginIndexPath]];
            }
          
        } else if ([brick isIfLogicBrick]) {
            // if brick
            IfLogicBeginBrick *ifLogicBeginBrick = nil;
            IfLogicElseBrick *ifLogicElseBrick = nil;
            IfLogicEndBrick *ifLogicEndBrick = nil;
            if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
                NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
                [ifLogicBeginBrick removeFromScript];
                NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicBeginIndexPath]];
                
                ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
                NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
                [ifLogicElseBrick removeFromScript];
                NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicElseIndexPath]];
                    
                ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
                NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
                [ifLogicEndBrick removeFromScript];
                NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicEndIndexPath]];

            } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                ifLogicElseBrick = ((IfLogicElseBrick*)brick);
                NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
                [ifLogicElseBrick removeFromScript];
                NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicElseIndexPath]];
                
                ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
                NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
                [ifLogicBeginBrick removeFromScript];
                NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicBeginIndexPath]];

                ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
                NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
                [ifLogicEndBrick removeFromScript];
                NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicEndIndexPath]];
                
            } else {
                CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
                ifLogicEndBrick = ((IfLogicEndBrick*)brick);
                NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
                [ifLogicEndBrick removeFromScript];
                NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicEndIndexPath]];

                ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
                NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
                [ifLogicBeginBrick removeFromScript];
                NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicBeginIndexPath]];
                
                ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
                NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
                [ifLogicElseBrick removeFromScript];
                NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
                [self.collectionView deleteItemsAtIndexPaths:@[ifLogicElseIndexPath]];
                
            }
            
        } else {
            [brick removeFromScript];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
    }
    self.placeHolderView.hidden = (self.object.scriptList.count != 0);
    [self.object.program saveToDisk];
    [self setEditing:NO animated:NO];
}

#pragma mark - Add new Variable
- (void)addVariableForBrick:(Brick*)brick atIndexPath:(NSIndexPath*)indexPath andIsProgramVariable:(BOOL)isProgramVar
{
//    Brick<BrickVariableProtocol> *variableBrick;
//    if ([brick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
//        variableBrick = (Brick<BrickVariableProtocol>*)brick;
//    }
    
    NSMutableArray *allVariableNames = [NSMutableArray new];
    if (isProgramVar) {
        for(UserVariable *var in [self.object.program.variables allVariables]) {
            [allVariableNames addObject:var.name];
        }
    } else {
        for(UserVariable *var in [self.object.program.variables allVariablesForObject:self.object]) {
            [allVariableNames addObject:var.name];
        }
    }
    
    self.variableIndexPath = indexPath;
    
    [Util askUserForUniqueNameAndPerformAction:@selector(addVariableWithName:andCompletion:)
                                        target:self
                                  cancelAction:@selector(reloadData)
                                    withObject:(id) ^(NSString* variableName) {
                                        UserVariable *variable = [UserVariable new];
                                        variable.name = variableName;
                                        variable.value = [NSNumber numberWithInt:0];
                                        if (isProgramVar) {
                                            [self.object.program.variables.programVariableList addObject:variable];
                                        } else { // object variable
                                            NSMutableArray *array = [self.object.program.variables.objectVariableList objectForKey:self.object];
                                            if (!array)
                                                array = [NSMutableArray new];
                                            [array addObject:variable];
                                            [self.object.program.variables.objectVariableList setObject:array forKey:self.object];
                                        }
                                        UserVariable *var = [self.object.program.variables getUserVariableNamed:(NSString*)variableName forSpriteObject:self.object];
                                        BrickCell *brickCell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:self.variableIndexPath];
                                        Brick * brick = (Brick*)brickCell.scriptOrBrick;
                                        Brick<BrickVariableProtocol> *variableBrick;
                                        if ([brick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
                                            variableBrick = (Brick<BrickVariableProtocol>*)brick;
                                        }
                                        
                                        if(var)
                                            [variableBrick setVariable:var forLineNumber:self.variableIndexPath.row andParameterNumber:self.variableIndexPath.section];
                                    }
                                   promptTitle:kUIFENewVar
                                 promptMessage:kUIFEVarName
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourVariableNameHere
                                minInputLength:kMinNumOfVariableNameCharacters
                                maxInputLength:kMaxNumOfVariableNameCharacters
                           blockedCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                                                invertedSet]
                      invalidInputAlertMessage:kUIFENewVarExists
                                 existingNames:allVariableNames];
}

#pragma mark - Setup
- (void)setupCollectionView
{
    self.collectionView.backgroundColor = [UIColor backgroundColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.collectionViewLayout = [LXReorderableCollectionViewFlowLayout new];
    self.navigationController.title = self.title = kLocalizedScripts;
    [self.editButtonItem setTitle:kLocalizedDelete];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.brickScaleTransition = [[BrickTransition alloc] initWithViewToAnimate:nil];
    self.selectedIndexPaths = [NSMutableArray new];
    self.scrollEnd = NO;
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

#pragma mark - BrickCellData Delegate
- (void)addMessageWithName:(NSString*)messageName andCompletion:(id)completion
{
    if (completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(messageName);
    }
    [self.object.program saveToDisk];
    [self.collectionView reloadData];
}

- (void)addVariableWithName:(NSString*)variableName andCompletion:(id)completion
{
    if (completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(variableName);
    }
    [self.object.program saveToDisk];
    [self.collectionView reloadData];
}

- (void)updateBrickCellData:(id<BrickCellDataProtocol>)brickCellData withValue:(id)value
{
    NSInteger line = brickCellData.lineNumber;
    NSInteger parameter = brickCellData.parameterNumber;
    id brick = brickCellData.brickCell.scriptOrBrick;
    if ([brickCellData isKindOfClass:[BrickCellLookData class]] && [brick conformsToProtocol:@protocol(BrickLookProtocol)]) {
        Brick<BrickLookProtocol> *lookBrick = (Brick<BrickLookProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            LooksTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kLooksTableViewControllerIdentifier];
            [ltvc setObject:self.object];
            ltvc.showAddLookActionSheetAtStartForScriptEditor = YES;
            ltvc.showAddLookActionSheetAtStartForObject = NO;
            ltvc.afterSafeBlock = ^(Look* look) {
                [lookBrick setLook:look forLineNumber:line andParameterNumber:parameter];
                [self.collectionView reloadData];
                [self.collectionView setNeedsDisplay];
                [self.navigationController popViewControllerAnimated:YES];
                [self enableUserInteractionAndResetHighlight];
            };
            [self.navigationController pushViewController:ltvc animated:YES];
            return;
        } else {
            [lookBrick setLook:[Util lookWithName:(NSString*)value forObject:self.object] forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellSoundData class]] && [brick conformsToProtocol:@protocol(BrickSoundProtocol)]) {
        Brick<BrickSoundProtocol> *soundBrick = (Brick<BrickSoundProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            SoundsTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kSoundsTableViewControllerIdentifier];
            [ltvc setObject:self.object];
            ltvc.showAddSoundActionSheetAtStart = YES;
            ltvc.afterSafeBlock =  ^(Sound* sound) {
                [soundBrick setSound:sound forLineNumber:line andParameterNumber:parameter];
                [self.collectionView reloadData];
                [self.collectionView setNeedsDisplay];
                [self.navigationController popViewControllerAnimated:YES];
                [self enableUserInteractionAndResetHighlight];
            };
            [self.navigationController pushViewController:ltvc animated:YES];
            return;
        } else {
            [soundBrick setSound:[Util soundWithName:(NSString*)value forObject:self.object] forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellObjectData class]] && [brick conformsToProtocol:@protocol(BrickObjectProtocol)]) {
        Brick<BrickObjectProtocol> *objectBrick = (Brick<BrickObjectProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            ProgramTableViewController *ptvc = [self.storyboard instantiateViewControllerWithIdentifier:kProgramTableViewControllerIdentifier];
            [ptvc setProgram:self.object.program];
            ptvc.showAddObjectActionSheetAtStart = YES;
            ptvc.afterSafeBlock =  ^(SpriteObject* object) {
                [objectBrick setObject:object forLineNumber:line andParameterNumber:parameter];
                [self.collectionView reloadData];
                [self.collectionView setNeedsDisplay];
                [self.navigationController popToViewController:self animated:YES];
                [self enableUserInteractionAndResetHighlight];
            };
            [self.navigationController pushViewController:ptvc animated:YES];
            return;
        } else {
            [objectBrick setObject:[Util objectWithName:(NSString*)value forProgram:self.object.program] forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellFormulaData class]] && [brick conformsToProtocol:@protocol(BrickFormulaProtocol)]) {
        [(Brick<BrickFormulaProtocol>*)brick setFormula:(Formula*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellTextData class]] && [brick conformsToProtocol:@protocol(BrickTextProtocol)]) {
        [(Brick<BrickTextProtocol>*)brick setText:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellMessageData class]] && [brick conformsToProtocol:@protocol(BrickMessageProtocol)]) {
        Brick<BrickMessageProtocol> *messageBrick = (Brick<BrickMessageProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            [Util askUserForUniqueNameAndPerformAction:@selector(addMessageWithName:andCompletion:)
                                                target:self
                                          cancelAction:@selector(reloadData)
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
            [self enableUserInteractionAndResetHighlight];
            return;
        } else {
            [messageBrick setMessage:(NSString*)value forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellVariableData class]] && [brick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
        Brick<BrickVariableProtocol> *variableBrick = (Brick<BrickVariableProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            NSIndexPath *path = [self.collectionView indexPathForCell:(UICollectionViewCell*)brickCellData.brickCell];
            CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kUIFEActionVar
                                                                 delegate:self
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@[kUIFEActionVarPro,kUIFEActionVarObj]
                                                                      tag:kVariabletypeActionSheetTag
                                                                     view:self.navigationController.view];
            actionSheet.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionEditBrickOrScript
                                                                            withPayload:@{ kDTPayloadCellIndexPath : path}];
            
            [self enableUserInteractionAndResetHighlight];
            return;
        } else {
            UserVariable *variable = [self.object.program.variables getUserVariableNamed:(NSString*)value forSpriteObject:self.object];
            if(variable)
                [variableBrick setVariable:variable forLineNumber:line andParameterNumber:parameter];
        }
    }
    [self enableUserInteractionAndResetHighlight];
    [self.object.program saveToDisk];
}

-(void)enableUserInteractionAndResetHighlight
{
    LXReorderableCollectionViewFlowLayout *collectionViewLayout = (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.longPressGestureRecognizer.enabled = YES;
    self.collectionView.scrollEnabled = YES;
    self.isEditingBrickMode = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    // enable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    for (BrickCell *cell in self.collectionView.visibleCells) {
        cell.enabled = YES;
        cell.alpha = kBrickCellActiveOpacity;
    }
    
    CGFloat maxContentOffset = self.collectionView.contentSize.height + self.collectionView.contentInset.bottom - self.collectionView.bounds.size.height;
    if(maxContentOffset < -self.collectionView.contentInset.top)
        maxContentOffset = -self.collectionView.contentInset.top;
    
    if (self.collectionView.contentOffset.y > maxContentOffset) {
        [self.collectionView setContentOffset:CGPointMake(0, maxContentOffset) animated:YES];
    }
}

#define kHighlightedBrickCellMarginBottom 10
-(void)disableUserInteractionAndHighlight:(BrickCell*)brickCell withMarginBottom:(CGFloat)marginBottom
{
    LXReorderableCollectionViewFlowLayout *collectionViewLayout = (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.longPressGestureRecognizer.enabled = NO;
    self.collectionView.scrollEnabled = NO;
    self.isEditingBrickMode = YES;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
        // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    for (BrickCell *cell in self.collectionView.visibleCells) {
        cell.enabled = NO;
        if (cell != brickCell) {
            cell.alpha = kBrickCellInactiveWhileEditingOpacity;
        }
    }
    
    // only scroll if BrickCell is covered by option view
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:brickCell];
    UICollectionViewLayoutAttributes *brickCellAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGFloat collectionViewHeight = self.collectionView.frame.size.height;
    CGFloat brickCellOriginVert = [self.collectionView convertRect:brickCellAttributes.frame toView:[self.collectionView superview]].origin.y + brickCell.frame.size.height - kBrickHeight1h;

    if ((collectionViewHeight - brickCellOriginVert) < marginBottom) {
        CGFloat additionalOffset = marginBottom - (collectionViewHeight - brickCellOriginVert) + kHighlightedBrickCellMarginBottom;
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + additionalOffset) animated:YES];
    }
}

-(void)reloadData
{
    [self.collectionView reloadData];
}

@end
