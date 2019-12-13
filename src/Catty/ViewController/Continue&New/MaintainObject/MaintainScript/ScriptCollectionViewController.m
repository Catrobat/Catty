/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "BrickCell.h"
#import "Script.h"
#import "StartScript.h"
#import "CatrobatReorderableCollectionViewFlowLayout.h"
#import "BrickManager.h"
#import "BrickTransition.h"
#import "PlaceHolderView.h"
#import "BroadcastScriptCell.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "BrickCellFormulaData.h"
#import "NoteBrick.h"
#import "BrickSelectionViewController.h"
#import "BrickLookProtocol.h"
#import "BrickSoundProtocol.h"
#import "BrickObjectProtocol.h"
#import "BrickMessageProtocol.h"
#import "BrickStaticChoiceProtocol.h"
#import "BrickVariableProtocol.h"
#import "BrickListProtocol.h"
#import "BrickCellLookData.h"
#import "BrickCellSoundData.h"
#import "BrickCellObjectData.h"
#import "BrickCellTextData.h"
#import "BrickCellMessageData.h"
#import "BrickCellVariableData.h"
#import "BrickCellListData.h"
#import "LooksTableViewController.h"
#import "SoundsTableViewController.h"
#import "ProjectTableViewController.h"
#import "ViewControllerDefines.h"
#import "Look.h"
#import "Sound.h"
#import "CBMutableCopyContext.h"
#import "RepeatBrick.h"
#import "OrderedMapTable.h"
#import "BrickInsertManager.h"
#import "BrickMoveManager.h"
#import "BrickSelectionManager.h"
#import "BrickCellPhiroMotorData.h"
#import "BrickCellPhiroLightData.h"
#import "BrickCellPhiroToneData.h"
#import "BrickCellPhiroIfSensorData.h"
#import "BrickCellStaticChoiceData.h"
#import "BrickPhiroMotorProtocol.h"
#import "BrickPhiroLightProtocol.h"
#import "BrickPhiroToneProtocol.h"
#import "BrickPhiroIfSensorProtocol.h"
#import "Pocket_Code-Swift.h"

#define kSelectAllItemsTag 0
#define kUnselectAllItemsTag 1


@interface ScriptCollectionViewController() <UICollectionViewDelegate,
                                             UICollectionViewDataSource,
                                             UIViewControllerTransitioningDelegate,
                                             BrickCellDelegate,
                                             iOSComboboxDelegate,
                                             BrickCellDataDelegate,
                                             UIGestureRecognizerDelegate>

@property (nonatomic, strong) BrickTransition *brickScaleTransition;
//@property (nonatomic, strong) NSMutableArray *selectedIndexPositions;  // refactor
@property (nonatomic, strong) NSIndexPath *variableIndexPath;
@property (nonatomic, assign) BOOL isEditingBrickMode;
@property (nonatomic, assign) BOOL batchUpdateMutex;
@property (nonatomic, strong) BrickCategory *lastSelectedCategory;
@property (nonatomic, strong) FormulaManager *formulaManager;
@end

@implementation ScriptCollectionViewController

#define kBrickCellInactiveWhileEditingOpacity 0.7f
#define kBrickCellInactiveWhileInsertingOpacity 0.7f
#define kBrickCellActiveOpacity 1.0f

@dynamic collectionView;

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupToolBar];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.placeHolderView.title = kLocalizedTapPlusToAddScript;
    self.placeHolderView.hidden = (self.object.scriptList.count != 0);
    [[BrickInsertManager sharedInstance] reset];
    self.isEditingBrickMode = NO;
    self.batchUpdateMutex = NO;
    self.formulaManager = [[FormulaManager alloc] initWithSceneSize: CGSizeMake([self.object.project.header.screenWidth floatValue], [self.object.project.header.screenHeight floatValue])];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // do not call super to prevent automatic scrolling when opening a UIPickerView
    [super hideLoadingView];
    self.navigationController.interactivePopGestureRecognizer.cancelsTouchesInView = NO;
    
    if (self.isEditingBrickMode) {
        [self enableUserInteractionAndResetHighlight];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.cancelsTouchesInView = YES;
    [[BrickMoveManager sharedInstance] reset];
}

- (void)showBrickPickerAction:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        BrickSelectionViewController *bsvc = [[BrickSelectionViewController alloc]
                                              initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                              options:@{
                                                        UIPageViewControllerOptionInterPageSpacingKey : @20.f
                                                        }];
        BrickCategory *selectedCategory = self.lastSelectedCategory == nil ? [bsvc.categories firstObject] : self.lastSelectedCategory;
        BrickCategoryViewController *bcvc = [[BrickCategoryViewController alloc] initWithBrickCategory:selectedCategory andObject:self.object];
        bcvc.delegate = self;
        
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
    if (indexPath.section < self.object.scriptList.count) {
        Script *script = self.object.scriptList[indexPath.section];
        
        if (indexPath.item == 0) {
            return [BrickManager.sharedBrickManager sizeForBrick:(id<BrickProtocol>)script];
        } else {
            Brick *brick = script.brickList[indexPath.item - 1];
            return [BrickManager.sharedBrickManager sizeForBrick:(id<BrickProtocol>)brick];
        }
    }
    return CGSizeZero;
}

#pragma mark- UICollectionViewDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kScriptCollectionViewInset, 0.0f, kScriptCollectionViewInset, 0.0f);
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
    id scriptOrBrick = brickCell.scriptOrBrick;
    
    if (self.isEditing) {
        [brickCell.selectButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    if ([[BrickInsertManager sharedInstance] isBrickInsertionMode]) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (indexPath.item != 0) {
            Brick *brick;
            if (script.brickList.count >= 1) {
                brick = [script.brickList objectAtIndex:indexPath.item - 1];
            }else{
                brick = [script.brickList objectAtIndex:indexPath.item];
            }
            if (brick.isAnimatedInsertBrick && !brick.isAnimatedMoveBrick) {
                [[BrickInsertManager sharedInstance] insertBrick:brick IndexPath:indexPath andObject:self.object];
            }else if(!brick.isAnimatedInsertBrick && !brick.isAnimatedMoveBrick){
                return;
            }else {
                brick.animateInsertBrick = NO;
                brick.animateMoveBrick = NO;
            }
            
        }else{
            script.animateInsertBrick = NO;
        }
        [self turnOffInsertingBrickMode];
        [self reloadData];
        return;
    }

    id<AlertControllerBuilding> actionSheet;
    if ([scriptOrBrick isKindOfClass:[Brick class]]) {
        Brick *brick = (Brick*)scriptOrBrick;
        NSString *destructiveTitle = ([brick isIfLogicBrick] ? kLocalizedDeleteCondition
                                      : ([brick isLoopBrick]) ? kLocalizedDeleteLoop
                                      : kLocalizedDeleteBrick);
        
        actionSheet = [[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditBrick]
                       addCancelActionWithTitle:kLocalizedCancel handler:nil]
                       addDestructiveActionWithTitle:destructiveTitle handler:^{
                           [self removeBrickOrScript:scriptOrBrick atIndexPath:indexPath];
                       }]
                       addDefaultActionWithTitle:kLocalizedCopyBrick handler:^{
                           [self copyBrick:brick atIndexPath:indexPath];
                       }]
                       addDefaultActionWithTitle:kLocalizedMoveBrick handler:^{
                           brick.animateInsertBrick = YES;
                           brick.animateMoveBrick = YES;
                           [[BrickInsertManager sharedInstance] setBrickMoveMode:YES];
                           [self turnOnInsertingBrickMode];
                           [self reloadData];
                       }];
        
        if (brick.isAnimateable) {
            [actionSheet addDefaultActionWithTitle:kLocalizedAnimateBrick handler:^{
                [self animate:indexPath brickCell:brickCell];
            }];
        }
        if (brick.isFormulaBrick) {
            [actionSheet addDefaultActionWithTitle:kLocalizedEditFormula handler:^{
                [self openFormulaEditorWithFormulaAtIndexPath:indexPath withEvent:nil];
            }];
        }
    } else {
        actionSheet = [[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditScript]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDestructiveActionWithTitle:kLocalizedDeleteScript handler:^{
             NSInteger numberOfBricksInSection = [self.collectionView numberOfItemsInSection:indexPath.section];
             if (numberOfBricksInSection > 1) {
                 [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisScript
                                                    message:kLocalizedThisActionCannotBeUndone]
                  addCancelActionWithTitle:kLocalizedCancel handler:nil]
                  addDefaultActionWithTitle:kLocalizedYes handler:^{
                      [self removeBrickOrScript:scriptOrBrick atIndexPath:indexPath];
                  }] build]
                  showWithController:self];
             } else {
                 [self removeBrickOrScript:scriptOrBrick atIndexPath:indexPath];
             }
         }];
    }
    
    [[[[actionSheet build]
     viewDidAppear:^(UIView *view) {
         const float kActionSheetBrickCellMarginBottom = 15.0f;
         [self disableUserInteractionAndHighlight:brickCell withMarginBottom:view.frame.size.height + kActionSheetBrickCellMarginBottom];
     }]
     viewWillDisappear:^{
         if (self.isEditingBrickMode) {
             [self enableUserInteractionAndResetHighlight];
         }
     }]
     showWithController:self];
}

- (void)deleteAlertView
{
    NSString *title = [[NSString alloc] init];
    NSString *titleBuffer = [[NSString alloc] init];
    BOOL firstIteration = YES;
    
    for (NSIndexPath *selectedPaths in [[BrickSelectionManager sharedInstance] selectedIndexPaths])
    {
        BrickCell *brickCell = (BrickCell *)[self.collectionView cellForItemAtIndexPath:selectedPaths];
        BOOL isBrick = [brickCell.scriptOrBrick isKindOfClass:[Brick class]];
        if (isBrick)
        {
            Brick *brick = (Brick*)brickCell.scriptOrBrick;
            if ([[[BrickSelectionManager sharedInstance] selectedIndexPaths] count] < 4)
            {
                title = ([brick isIfLogicBrick] ? kLocalizedDeleteThisCondition
                           : ([brick isLoopBrick]) ? kLocalizedDeleteThisLoop : kLocalizedDeleteTheseBricks);
            }
            else
            {
                title = ([brick isIfLogicBrick] ? kLocalizedDeleteTheseConditions
                               : ([brick isLoopBrick]) ? kLocalizedDeleteTheseLoops : kLocalizedDeleteTheseBricks);
            }
        }
        else
        {
            title = kLocalizedDeleteTheseScripts;
        }
        
        if (firstIteration)
        {
            titleBuffer = title;
            title = isBrick ? kLocalizedDeleteThisBrick : kLocalizedDeleteThisScript;
            firstIteration = NO;
        }
        else if (title != titleBuffer)
        {
            title = kLocalizedDeleteTheseBricks;
            break;
        }
    }

    if ([[[BrickSelectionManager sharedInstance] selectedIndexPaths] count])
    {
        NSString *alertTitle = title;
        [[[[[AlertControllerBuilder alertWithTitle:alertTitle message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteSelectedBricks];
             self.allBricksSelected = NO;
         }] build]
         showWithController:self];
    }
}

#pragma mark - Reorderable Cells Delegate
- (void)collectionView:(UICollectionView*)collectionView
       itemAtIndexPath:(NSIndexPath*)fromIndexPath
   willMoveToIndexPath:(NSIndexPath*)toIndexPath
{
    if (fromIndexPath.item == 0) {
        Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        [self.object.scriptList removeObjectAtIndex:fromIndexPath.section];
        [self.object.scriptList insertObject:script atIndex:toIndexPath.section];
        return;
    }
    if (fromIndexPath.section == toIndexPath.section) {
        Script *script = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        if (fromIndexPath.item > 0) {
            Brick *fromBrick = [script.brickList objectAtIndex:fromIndexPath.item - 1];
            [script.brickList removeObjectAtIndex:fromIndexPath.item - 1];
            if (toIndexPath.item > 0) {
                 [script.brickList insertObject:fromBrick atIndex:toIndexPath.item - 1];
            } else {
                [script.brickList insertObject:fromBrick atIndex:toIndexPath.item+1];
            }
           
        }
        
    } else {
        Script *toScript = [self.object.scriptList objectAtIndex:toIndexPath.section];
        Script *fromScript = [self.object.scriptList objectAtIndex:fromIndexPath.section];
        Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
		fromBrick.script = toScript;
        if ([fromScript.brickList count] == 1) {
            [fromScript.brickList removeAllObjects];
        } else {
            [fromScript.brickList removeObjectAtIndex:fromIndexPath.item - 1];
        }
        if ([toScript.brickList count] == 0) {
            [toScript.brickList insertObject:fromBrick atIndex:toIndexPath.item];
        }else{
            [toScript.brickList insertObject:fromBrick atIndex:toIndexPath.item - 1];
        }
    }
}

- (void)collectionView:(UICollectionView*)collectionView
       itemAtIndexPath:(NSIndexPath*)fromIndexPath
   didMoveToIndexPath:(NSIndexPath*)toIndexPath
{
    [[BrickMoveManager sharedInstance] reset];
}

- (void)collectionView:(UICollectionView*)collectionView
                layout:(UICollectionViewLayout*)collectionViewLayout
didEndDraggingItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.isEditingBrickMode) {
        return;
    }
    
    if ([[BrickInsertManager sharedInstance] isBrickInsertionMode]) {
        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
        if (indexPath.item != 0) {
            Brick *brick;
            if (script.brickList.count >= 1) {
                brick = [script.brickList objectAtIndex:indexPath.item - 1];
            }else{
                brick = [script.brickList objectAtIndex:indexPath.item];
            }
            if (brick.isAnimatedInsertBrick && !brick.isAnimatedMoveBrick) {
                [[BrickInsertManager sharedInstance] insertBrick:brick IndexPath:indexPath andObject:self.object];
            }else if(!brick.isAnimatedInsertBrick && !brick.isAnimatedMoveBrick){
                return;
            }else {
                brick.animateInsertBrick = NO;
                brick.animateMoveBrick = NO;
            }
        }else{
            script.animateInsertBrick = NO;
        }
        [self turnOffInsertingBrickMode];
    } else {
        [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
        [self.object.project saveToDiskWithNotification:YES];
    }
    [self reloadData];
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
    if ([[BrickInsertManager sharedInstance] isBrickInsertionMode] && ![[BrickInsertManager sharedInstance] isBrickMoveMode]) {
        return [[BrickInsertManager sharedInstance] collectionView:self.collectionView itemAtIndexPath:fromIndexPath canInsertToIndexPath:toIndexPath andObject:self.object];
    }
    
    return [[BrickMoveManager sharedInstance] collectionView:self.collectionView itemAtIndexPath:fromIndexPath canMoveToIndexPath:toIndexPath andObject:self.object];
}


- (BOOL)collectionView:(UICollectionView*)collectionView canMoveItemAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL editable = ((self.isEditing || indexPath.item == 0) ? NO : YES);
    return ((editable || [[BrickInsertManager sharedInstance] isBrickInsertionMode]) ? YES : editable);
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
    brickCell.scriptOrBrick = ((indexPath.item == 0) ? (id<BrickProtocol>)script : (id<BrickProtocol>)brick);
    brickCell.enabled = YES;
    [brickCell setupBrickCellinSelectionView:false inBackground:self.object.isBackground];
    brickCell.delegate = self;
    brickCell.dataDelegate = self;
    [brickCell setNeedsDisplay];

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
            if (selectBrick.isSelected || self.allBricksSelected) {
                brickCell.selectButton.selected = YES;
            }else{
                brickCell.selectButton.selected = NO;
            }
        }else{
            Script *selectScript = (Script *)brickCell.scriptOrBrick;
            if (selectScript.isSelected || self.allBricksSelected) {
                brickCell.selectButton.selected = YES;
            }else{
                brickCell.selectButton.selected = NO;
            }
        }
    }else{
      brickCell.selectButton.selected = NO;
    }
    brickCell.enabled = (! self.isEditing);
    if ([[BrickInsertManager sharedInstance] isBrickInsertionMode]) {
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

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isEditing && [cell isKindOfClass:[BrickCell class]]) {
        BrickCell* brickCell = (BrickCell*)cell;
        brickCell.center = CGPointMake(self.view.center.x, brickCell.center.y);
        brickCell.selectButton.alpha = 0.0f;
        brickCell.selectButton.selected = NO;
        brickCell.enabled = YES;
    }
    return;
}

#pragma mark - BrickCategoryViewController delegates
- (void)brickCategoryViewController:(BrickCategoryViewController*)brickCategoryViewController
             didSelectScriptOrBrick:(id<BrickProtocol>)scriptOrBrick
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    scriptOrBrick = [scriptOrBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    [scriptOrBrick setDefaultValuesForObject:self.object];
    self.lastSelectedCategory = brickCategoryViewController.category;
    brickCategoryViewController.delegate = nil;
    self.placeHolderView.hidden = YES;
    BrickInsertManager* manager = [BrickInsertManager sharedInstance];
    if ([scriptOrBrick isKindOfClass:[Script class]]) {
        Script *script = (Script*)scriptOrBrick;
        script.object = self.object;
        [self.object.scriptList addObject:script];
        [self reloadDataSynchronous];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:(self.object.scriptList.count - 1)]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
       
        manager.isInsertingScript = YES;
        if (self.object.scriptList.count == 1) {
            [self.object.project saveToDiskWithNotification:YES];
            return;
        }
        script.animateInsertBrick = YES;
        [self turnOnInsertingBrickMode];
        return;
    }
    // empty script list, insert start script and continue to insert the chosen brick
    if (self.object.scriptList.count == 0) {
        StartScript *script = [StartScript new];
        script.object = self.object;
        [self.object.scriptList addObject:script];
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
    NSInteger insertionIndex = visibleIndexPath.row;
    NSInteger index = brick.script.brickList.count;
    BOOL hasForeverLoop = NO;
    if (targetScript.brickList.count >=1) {
        while ([[targetScript.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick *loopEndBrickCheck = (LoopEndBrick*)[targetScript.brickList objectAtIndex:index-1];
            if ([loopEndBrickCheck.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                hasForeverLoop = YES;
            }
            index--;
        }
    }
    float bottomEdge = self.collectionView.contentOffset.y + self.collectionView.frame.size.height;
    if ((smallScript || bottomEdge >= self.collectionView.contentSize.height) ) {
        if (hasForeverLoop) {
            [targetScript.brickList insertObject:brick atIndex:index];
        } else {
          [targetScript.brickList addObject:brick];
        }
    }else{
        [targetScript.brickList insertObject:brick atIndex:insertionIndex];
    }
    // Only one empty Script in script list, insert first brick without highlighting the brick after insertion and continue
    if (targetScript.brickList.count == 1 && self.object.scriptList.count == 1) {
        
        [[BrickInsertManager sharedInstance] insertBrick:brick IndexPath:[NSIndexPath indexPathForRow:0 inSection:targetScriptIndex] andObject:self.object];
        [self reloadData];
        return;
    }
    
    Brick* lastBrick = self.object.scriptList.lastObject.brickList.lastObject;
    brick.animateInsertBrick = YES;
    manager.isInsertingScript = NO;
    if (brick == lastBrick)
    {
        [self reloadDataSynchronous];
        NSIndexPath *lastIndexPath = [self findLastIndexPath];
        [self.collectionView scrollToItemAtIndexPath:lastIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
    }
    else
    {
        [self reloadData];
    }
    [self turnOnInsertingBrickMode];
//    [self.object.project saveToDisk];
}


#pragma mark - Brick Cell Delegate
- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:selectButton.center fromView:selectButton.superview]];
    if (! indexPath) {
        return;
    }

    [[BrickSelectionManager sharedInstance] brickCell:brickCell didSelectBrickCellButton:selectButton IndexPath:indexPath andObject:self.object];
    [self reloadData];
}


- (void)openFormulaEditorWithFormulaAtIndexPath:(NSIndexPath*)indexPath withEvent:(UIEvent*)event
{
    BrickCell *brickCell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    BrickCellFormulaData *formulaData = (BrickCellFormulaData*)[brickCell dataSubviewWithType:[BrickCellFormulaData class]];
    [self openFormulaEditor:formulaData withEvent:event];
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

    FormulaEditorViewController *formulaEditorViewController = [[FormulaEditorViewController alloc] initWithBrickCellFormulaData:formulaData andFormulaManager:self.formulaManager];
    formulaEditorViewController.object = self.object;
    formulaEditorViewController.transitioningDelegate = self;
    formulaEditorViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self.brickScaleTransition updateAnimationViewWithView:formulaData.brickCell];
    [self presentViewController:formulaEditorViewController animated:YES completion:^{
        [formulaEditorViewController setBrickCellFormulaData:formulaData];
    }];
}

#pragma mark - Helpers
-(NSIndexPath*)findLastIndexPath{
    NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
    NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return lastIndexPath;
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.editing) {
        [self setEditing:YES animated:NO];
        [self reloadData];
    }
}

- (void)removeBricksWithIndexPaths:(NSArray*)indexPaths
{
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    sortedIndexPaths = [[sortedIndexPaths reverseObjectEnumerator] allObjects];
    [self.collectionView performBatchUpdates:^{
        self.batchUpdateMutex = YES;
        for (NSIndexPath *indexPath in sortedIndexPaths) {
            Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
            if (indexPath.item == 0) {
                [self.object.scriptList removeObjectAtIndex:indexPath.section];
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            } else {
                if (script.brickList.count) {
                    [script.brickList removeObjectAtIndex:indexPath.item - 1];
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }
            }
        }
    } completion:^(BOOL finished) {
        self.batchUpdateMutex = NO;
        [[BrickSelectionManager sharedInstance] reset];
        [self reloadData];
        self.placeHolderView.hidden = (self.object.scriptList.count != 0);
        [self.object.project saveToDiskWithNotification:YES];
    }];
}


- (NSString*)keyWithSelectIndexPath:(NSIndexPath*)indexPath
{
    return [NSString stringWithFormat:@"%@_%@", @(indexPath.section), @(indexPath.item)];
}

-(void)deleteSelectedBricks
{
    [self removeBricksWithIndexPaths:[[BrickSelectionManager sharedInstance] selectedIndexPaths]];
    [self setEditing:NO animated:NO];
}

-(void)turnOnInsertingBrickMode
{
    [[BrickInsertManager sharedInstance] setBrickInsertionMode:YES];
    for (UIButton *button in self.navigationController.toolbar.items) {
        button.enabled = NO;
    }
    CatrobatReorderableCollectionViewFlowLayout *layout = (CatrobatReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.longPressGestureRecognizer.minimumPressDuration = 0.1;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
       self.navigationItem.rightBarButtonItem.enabled = NO;
    });
    
}

-(void)turnOffInsertingBrickMode
{
    [[BrickInsertManager sharedInstance] reset];
    for (UIButton *button in self.navigationController.toolbar.items) {
        button.enabled = YES;
    }
    CatrobatReorderableCollectionViewFlowLayout *layout = (CatrobatReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.longPressGestureRecognizer.minimumPressDuration = 0.5;
    [self.navigationItem setHidesBackButton:NO animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    });
}

- (void)changeDeleteBarButtonState
{
    UIBarButtonItem *navBarButton;
    if (!self.editing) {
        navBarButton= [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete style:UIBarButtonItemStylePlain target:self action:@selector(enterDeleteMode)];
    } else {
        navBarButton= [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel style:UIBarButtonItemStylePlain target:self action:@selector(exitDeleteMode)];
    }
    self.navigationItem.rightBarButtonItem = navBarButton;
    if (self.object.scriptList.count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Editing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [self setupToolBar];
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
        NSArray* animationArray = [[BrickManager sharedBrickManager] animateWithIndexPath:indexPath Script:script andBrick:brick];
        if (animationArray) {
            for (NSNumber* number in animationArray) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    BrickCell *cell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:number.integerValue inSection:indexPath.section]];
                    [cell animate:YES];
                });
            }
        }
    }
}

#pragma mark - Copy Brick
- (void)copyBrick:(Brick*)brick atIndexPath:(NSIndexPath*)indexPath
{
    NSArray* indexArray = [[BrickManager sharedBrickManager] scriptCollectionCopyBrickWithIndexPath:indexPath andBrick:brick];
    [self.collectionView insertItemsAtIndexPaths:indexArray];
    self.placeHolderView.hidden = YES;
    [self.object.project saveToDiskWithNotification:YES];
    
    NSIndexPath *lastIndexPath = [self findLastIndexPath];
    if(lastIndexPath == indexArray[0])
    {
        [self.collectionView scrollToItemAtIndexPath:lastIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
    }
}

#pragma mark - Remove Brick
- (void)removeBrickOrScript:(id<BrickProtocol>)scriptOrBrick
                atIndexPath:(NSIndexPath*)indexPath
{
    [self.collectionView performBatchUpdates:^{
        self.batchUpdateMutex = YES;
        if ([scriptOrBrick isKindOfClass:[Script class]]) {
            [(Script*)scriptOrBrick removeFromObject];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        } else {
            CBAssert([scriptOrBrick isKindOfClass:[Brick class]]);
            Brick *brick = (Brick*)scriptOrBrick;
            NSArray* removingBrickIndexPaths = [[BrickManager sharedBrickManager] getIndexPathsForRemovingBricks:indexPath andBrick:brick];
            if (removingBrickIndexPaths) {
                [self.collectionView deleteItemsAtIndexPaths:removingBrickIndexPaths];
            }
        }
    } completion:^(BOOL finished) {
        self.batchUpdateMutex = NO;
        self.placeHolderView.hidden = (self.object.scriptList.count != 0);
        [self reloadData];
        [self.object.project saveToDiskWithNotification:YES];
        [self setEditing:NO animated:NO];
    }];

}

#pragma mark - Add new Variable
- (void)addVariableForBrick:(Brick*)brick atIndexPath:(NSIndexPath*)indexPath andIsProjectVariable:(BOOL)isProjectVar
{
//    Brick<BrickVariableProtocol> *variableBrick;
//    if ([brick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
//        variableBrick = (Brick<BrickVariableProtocol>*)brick;
//    }

    NSMutableArray *allVariableNames = [NSMutableArray new];
    if (isProjectVar) {
        for(UserVariable *var in [self.object.project.variables allVariables]) {
            [allVariableNames addObject:var.name];
        }
    } else {
        for(UserVariable *var in [self.object.project.variables allVariablesForObject:self.object]) {
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
                                        variable.isList = NO;
                                        if (isProjectVar) {
                                            [self.object.project.variables.programVariableList addObject:variable];
                                        } else { // object variable
                                            [self.object.project.variables addObjectVariable:variable forObject:self.object];
                                        }
                                        UserVariable *var = [self.object.project.variables getUserVariableNamed:(NSString*)variableName forSpriteObject:self.object];
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
                                 promptMessage:kUIFEOtherName
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourVariableNameHere
                                minInputLength:kMinNumOfVariableNameCharacters
                                maxInputLength:kMaxNumOfVariableNameCharacters
                      invalidInputAlertMessage:kUIFENewVarExists
                                 existingNames:allVariableNames];
}

#pragma mark - Add new List
- (void)addListForBrick:(Brick*)brick atIndexPath:(NSIndexPath*)indexPath andIsProjectList:(BOOL)isProjectList
{

    NSMutableArray *allListNames = [NSMutableArray new];
    if (isProjectList) {
        for(UserVariable *list in [self.object.project.variables allLists]) {
            [allListNames addObject:list.name];
        }
    } else {
        for(UserVariable *list in [self.object.project.variables allListsForObject:self.object]) {
            [allListNames addObject:list.name];
        }
    }
    
    self.variableIndexPath = indexPath;
    
    [Util askUserForUniqueNameAndPerformAction:@selector(addVariableWithName:andCompletion:)
                                        target:self
                                  cancelAction:@selector(reloadData)
                                    withObject:(id) ^(NSString* listName) {
                                        UserVariable *list = [UserVariable new];
                                        list.name = listName;
                                        list.value = [[NSMutableArray alloc] init];
                                        list.isList = YES;
                                        if (isProjectList) {
                                            [self.object.project.variables.programListOfLists addObject:list];
                                        } else { // object list
                                            [self.object.project.variables addObjectList:list forObject:self.object];
                                        }
                                        UserVariable *listToSet = [self.object.project.variables getUserListNamed:(NSString*)listName forSpriteObject:self.object];
                                        BrickCell *brickCell = (BrickCell*)[self.collectionView cellForItemAtIndexPath:self.variableIndexPath];
                                        Brick * brick = (Brick*)brickCell.scriptOrBrick;
                                        Brick<BrickListProtocol> *listBrick;
                                        if ([brick conformsToProtocol:@protocol(BrickListProtocol)]) {
                                            listBrick = (Brick<BrickListProtocol>*)brick;
                                        }
                                        
                                        if(listToSet)
                                            [listBrick setList:listToSet forLineNumber:self.variableIndexPath.row andParameterNumber:self.variableIndexPath.section];
                                    }
                                   promptTitle:kUIFENewList
                                 promptMessage:kUIFEOtherName
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourListNameHere
                                minInputLength:kMinNumOfVariableNameCharacters
                                maxInputLength:kMaxNumOfVariableNameCharacters
                      invalidInputAlertMessage:kUIFENewVarExists
                                 existingNames:allListNames];
}


#pragma mark - Setup
- (void)setupCollectionView
{
    self.collectionView.backgroundColor = UIColor.background;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.collectionViewLayout = [CatrobatReorderableCollectionViewFlowLayout new];
    self.navigationController.title = self.title = kLocalizedScripts;
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete style:UIBarButtonItemStylePlain target:self action:@selector(enterDeleteMode)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    [self changeDeleteBarButtonState];
    self.brickScaleTransition = [[BrickTransition alloc] initWithViewToAnimate:nil];
    [[BrickSelectionManager sharedInstance] reset];
    
    NSArray *allBricks = [[CatrobatSetup class] registeredBricks];
    for (id brick in allBricks) {
        Class<BrickCellProtocol> brickCell = [brick brickCell];
        [self.collectionView registerClass:brickCell forCellWithReuseIdentifier:NSStringFromClass([brick class])];
    }
}


#pragma mark - BrickCellData Delegate
- (void)addMessageWithName:(NSString*)messageName andCompletion:(id)completion
{
    if (completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(messageName);
    }
    [self.object.project saveToDiskWithNotification:YES];
    [self enableUserInteractionAndResetHighlight];
}

- (void)addVariableWithName:(NSString*)variableName andCompletion:(id)completion
{
    if (completion) {
        void (^block)(NSString*) = (void (^)(NSString*))completion;
        block(variableName);
    }
    [self.object.project saveToDiskWithNotification:YES];
    [self enableUserInteractionAndResetHighlight];
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
            ProjectTableViewController *ptvc = [self.storyboard instantiateViewControllerWithIdentifier:kProjectTableViewControllerIdentifier];
            [ptvc setProject:self.object.project];
            ptvc.showAddObjectActionSheetAtStart = YES;
            ptvc.afterSafeBlock =  ^(SpriteObject* object) {
                [objectBrick setObject:object forLineNumber:line andParameterNumber:parameter];
                [self.navigationController popToViewController:self animated:YES];
                [self enableUserInteractionAndResetHighlight];
            };
            [self.navigationController pushViewController:ptvc animated:YES];
            return;
        } else {
            [objectBrick setObject:[Util objectWithName:(NSString*)value forProject:self.object.project] forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellFormulaData class]] && [brick conformsToProtocol:@protocol(BrickFormulaProtocol)]) {
        [(Brick<BrickFormulaProtocol>*)brick setFormula:(Formula*)value forLineNumber:line andParameterNumber:parameter];
        [self.object.project saveToDiskWithNotification:YES];
        return;
    } else
    if ([brickCellData isKindOfClass:[BrickCellTextData class]] && [brick conformsToProtocol:@protocol(BrickTextProtocol)]) {
        [(Brick<BrickTextProtocol>*)brick setText:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellStaticChoiceData class]] && [brick conformsToProtocol:@protocol(BrickStaticChoiceProtocol)]) {
            [(Brick<BrickStaticChoiceProtocol>*)brick setChoice:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    }else
    if ([brickCellData isKindOfClass:[BrickCellMessageData class]] && [brick conformsToProtocol:@protocol(BrickMessageProtocol)]) {
        Brick<BrickMessageProtocol> *messageBrick = (Brick<BrickMessageProtocol>*)brick;
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            [Util askUserForUniqueNameAndPerformAction:@selector(addMessageWithName:andCompletion:)
                                                target:self
                                          cancelAction:@selector(enableUserInteractionAndResetHighlight)
                                            withObject:(id) ^(NSString* message){
                                                [messageBrick setMessage:message forLineNumber:line andParameterNumber:parameter];
                                            }
                                           promptTitle:kLocalizedNewMessage
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedMessage]
                                           promptValue:nil
                                     promptPlaceholder:kLocalizedEnterYourMessageHere
                                        minInputLength:kMinNumOfMessageNameCharacters
                                        maxInputLength:kMaxNumOfMessageNameCharacters
                              invalidInputAlertMessage:kLocalizedMessageAlreadyExistsDescription
                                         existingNames:[Util allMessagesForProject:self.object.project]];
            [self enableUserInteractionAndResetHighlight];
            return;
        } else {
            [messageBrick setMessage:(NSString*)value forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellVariableData class]] && [brick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            CBAssert([brickCellData.brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
            
            NSIndexPath *path = [self.collectionView indexPathForCell:(UICollectionViewCell*)brickCellData.brickCell];
            Brick *brick = (Brick*)brickCellData.brickCell.scriptOrBrick;
            [[[[[[AlertControllerBuilder actionSheetWithTitle:kUIFEActionVar]
             addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kUIFEActionVarPro handler:^{
                 [self addVariableForBrick:brick atIndexPath:path andIsProjectVariable:YES];
             }]
             addDefaultActionWithTitle:kUIFEActionVarObj handler:^{
                 [self addVariableForBrick:brick atIndexPath:path andIsProjectVariable:NO];
             }]
             build]
             showWithController:[Util topmostViewController]];
            
            [self enableUserInteractionAndResetHighlight];
            return;
        } else {
            Brick<BrickVariableProtocol> *variableBrick = (Brick<BrickVariableProtocol>*)brick;
            UserVariable *variable = [self.object.project.variables getUserVariableNamed:(NSString*)value forSpriteObject:self.object];
            if(variable)
                [variableBrick setVariable:variable forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellListData class]] && [brick conformsToProtocol:@protocol(BrickListProtocol)]) {
        if([(NSString*)value isEqualToString:kLocalizedNewElement]) {
            CBAssert([brickCellData.brickCell.scriptOrBrick isKindOfClass:[Brick class]]);
                
            NSIndexPath *path = [self.collectionView indexPathForCell:(UICollectionViewCell*)brickCellData.brickCell];
            Brick *brick = (Brick*)brickCellData.brickCell.scriptOrBrick;
            [[[[[[AlertControllerBuilder actionSheetWithTitle:kUIFEActionList]
             addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kUIFEActionVarPro handler:^{
                 [self addListForBrick:brick atIndexPath:path andIsProjectList:YES];
             }]
             addDefaultActionWithTitle:kUIFEActionVarObj handler:^{
                 [self addListForBrick:brick atIndexPath:path andIsProjectList:NO];
             }]
             build]
             showWithController:[Util topmostViewController]];
                
            [self enableUserInteractionAndResetHighlight];
            return;
        } else {
            Brick<BrickListProtocol> *listBrick = (Brick<BrickListProtocol>*)brick;
            UserVariable *list = [self.object.project.variables getUserListNamed:(NSString*)value forSpriteObject:self.object];
            if(list)
                [listBrick setList:list forLineNumber:line andParameterNumber:parameter];
        }
    } else
    if ([brickCellData isKindOfClass:[BrickCellPhiroMotorData class]] && [brick conformsToProtocol:@protocol(BrickPhiroMotorProtocol)]) {
        Brick<BrickPhiroMotorProtocol> *motorBrick = (Brick<BrickPhiroMotorProtocol>*)brick;
        [motorBrick setMotor:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellPhiroToneData class]] && [brick conformsToProtocol:@protocol(BrickPhiroToneProtocol)]) {
        Brick<BrickPhiroToneProtocol> *toneBrick = (Brick<BrickPhiroToneProtocol>*)brick;
        [toneBrick setTone:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellPhiroLightData class]] && [brick conformsToProtocol:@protocol(BrickPhiroLightProtocol)]) {
        Brick<BrickPhiroLightProtocol> *lightBrick = (Brick<BrickPhiroLightProtocol>*)brick;
        [lightBrick setLight:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    } else
    if ([brickCellData isKindOfClass:[BrickCellPhiroIfSensorData class]] && [brick conformsToProtocol:@protocol(BrickPhiroIfSensorProtocol)]) {
        Brick<BrickPhiroIfSensorProtocol> *phiroIfBrick = (Brick<BrickPhiroIfSensorProtocol>*)brick;
        [phiroIfBrick setSensor:(NSString*)value forLineNumber:line andParameterNumber:parameter];
    }
    
    [self.object.project saveToDiskWithNotification:NO];
    [self enableUserInteractionAndResetHighlight];
}

-(void)enableUserInteractionAndResetHighlight
{
    CatrobatReorderableCollectionViewFlowLayout *collectionViewLayout = (CatrobatReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
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
    
    [self reloadData];
}

-(void)disableUserInteractionAndHighlight:(BrickCell*)brickCell withMarginBottom:(CGFloat)marginBottom
{
    CatrobatReorderableCollectionViewFlowLayout *collectionViewLayout = (CatrobatReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
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
        if (cell != brickCell) {
            cell.enabled = NO;
            cell.alpha = kBrickCellInactiveWhileEditingOpacity;
        }
    }
    
    // only scroll if BrickCell is covered by option view
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:brickCell];
    UICollectionViewLayoutAttributes *brickCellAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGFloat collectionViewHeight = self.collectionView.frame.size.height;
    CGFloat brickCellOriginVert = [self.collectionView convertRect:brickCellAttributes.frame toView:[self.collectionView superview]].origin.y + [brickCell inlineViewHeight] + [brickCell inlineViewOffsetY];

    if ((collectionViewHeight - brickCellOriginVert) < marginBottom) {
        CGFloat additionalOffset = marginBottom - (collectionViewHeight - brickCellOriginVert);
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + additionalOffset) animated:YES];
    }
}

-(void)reloadData
{
    if (self.batchUpdateMutex)
        return;

    dispatch_async(dispatch_get_main_queue(),^{
        [self.collectionView reloadData];
        [self changeDeleteBarButtonState];
        [self.collectionView setNeedsDisplay];
    });

}

-(void)reloadDataSynchronous
{
    if (self.batchUpdateMutex)
        return;

    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(),^{
        [self changeDeleteBarButtonState];
        [self.collectionView setNeedsDisplay];
    });
}

#pragma mark Rotation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self reloadData];
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if ([[BrickInsertManager sharedInstance] isBrickInsertionMode]) {
             NSMutableArray<Script*>* scriptlist = [self object].scriptList;
             for (int section = 0; section < scriptlist.count; section++) {
                 for (int row = 0; row < scriptlist[section].brickList.count; row++) {
                     if (scriptlist[section].brickList[row].animateInsertBrick) {
                         [self.collectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForRow:row inSection:section]
                                                     atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                             animated:NO];
                         return;
                    }
                 }
             }
         }
        }];
    }


- (void)selectAllRows:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (!self.allBricksSelected) {
            button.title = kLocalizedUnselectAllItems;
            self.allBricksSelected = YES;
            [[BrickSelectionManager sharedInstance] selectAllBricks:self.collectionView];
        } else {
            button.title = kLocalizedSelectAllItems;
            self.allBricksSelected = NO;
            [[BrickSelectionManager sharedInstance] deselectAllBricks];
        }
    }

    [self reloadData];
}

-(void)enterDeleteMode
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel style:UIBarButtonItemStylePlain target:self action:@selector(exitDeleteMode)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    [UIView animateWithDuration:0.5f  delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (BrickCell *brickCell in self.collectionView.visibleCells) {
            brickCell.center = CGPointMake(brickCell.center.x + kSelectButtonTranslationOffsetX, brickCell.center.y);
            brickCell.selectButton.alpha = 1.0f;
        }
    } completion:^(BOOL finished) {
        for (BrickCell *brickCell in self.collectionView.visibleCells) {
            brickCell.enabled = NO;
        }
    }];
    self.editing = YES;
}

-(void)exitDeleteMode
{
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete style:UIBarButtonItemStylePlain target:self action:@selector(enterDeleteMode)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.65f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut
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
                         [[BrickSelectionManager sharedInstance] reset];
                     }];
    self.editing = NO;
    self.allBricksSelected = NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end
