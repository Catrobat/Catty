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
#import "WhenScript.h"
#import "BroadcastScript.h"
#import "WaitBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "NoteBrick.h"
#import "ForeverBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "RepeatBrick.h"
#import "PlaceAtBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeYByNBrick.h"
#import "IfOnEdgeBounceBrick.h"
#import "MoveNStepsBrick.h"
#import "TurnLeftBrick.h"
#import "TurnRightBrick.h"
#import "PointInDirectionBrick.h"
#import "PointToBrick.h"
#import "GlideToBrick.h"
#import "GoNStepsBackBrick.h"
#import "ComeToFrontBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByNBrick.h"
#import "SpeakBrick.h"
#import "SetLookBrick.h"
#import "NextLookBrick.h"
#import "SetSizeToBrick.h"
#import "ChangeSizeByNBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetGhostEffectBrick.h"
#import "ChangeGhostEffectByNBrick.h"
#import "SetBrightnessBrick.h"
#import "ChangeBrightnessByNBrick.h"
#import "ClearGraphicEffectBrick.h"
#import "SetVariableBrick.h"
#import "ChangeVariableBrick.h"
#import "StartScriptBrickCell.h"

@interface ScriptCollectionViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation ScriptCollectionViewController


#pragma view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [super initPlaceHolder];
    [super setPlaceHolderTitle:kScriptsTitle
                   Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil),
                                kScriptsTitle]];
    [super showPlaceHolder:(!(BOOL)[self.object.lookList count])];
    [self setupToolBar];
    [super setPlaceHolderTitle:kScriptsTitle
                   Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil), kScriptsTitle]];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.brickList = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(brickAdded:) name:BrickCellAddedNotification object:nil];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc removeObserver:self name:BrickCellAddedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [self.object.scriptList count];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    Script *script = [self.object.scriptList objectAtIndex:section];
    //    if (! script) {
    //        NSError(@"This should never happen");
    //        abort();
    //    }
    //    return ([script.brickList count] + 1); // because script itself is a brick in IDE too
    return [self.brickList count];
}


#pragma mark Collection View Datasource

-  (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - collection view delegate

// TODO: TO BE REFACTORED!!
//- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
//{
//    CGFloat width = self.view.frame.size.width;
//    kBrickCategoryType categoryType = kControlBrick;
//    NSInteger brickType = kProgramStartedBrick;
//    Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
//    if (indexPath.row == 0) {
//      // case it's a script brick
//      categoryType = kControlBrick;
//      brickType = kReceiveBrick;
//      if ([script isKindOfClass:[StartScript class]]) {
//        brickType = kProgramStartedBrick;
//      } else if ([script isKindOfClass:[WhenScript class]]) {
//        brickType = kTappedBrick;
//      }
//    } else {
//      // case it's a normal brick
////      categoryType = kControlBrick;
////      brickType = kIfBrick;
//      Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
//
//      // TODO: use brick name to class name mapping with >> Class class = NSClassFromString(@"ClassName") <<
//      // control bricks
//      if ([brick isKindOfClass:[WaitBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kWaitBrick;
//      } else if ([brick isKindOfClass:[BroadcastBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kBroadcastBrick;
//      } else if ([brick isKindOfClass:[BroadcastWaitBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kBroadcastWaitBrick;
//      } else if ([brick isKindOfClass:[NoteBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kNoteBrick;
//      } else if ([brick isKindOfClass:[ForeverBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kForeverBrick;
//      } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kIfBrick;
//      } else if ([brick isKindOfClass:[RepeatBrick class]]) {
//        categoryType = kControlBrick;
//        brickType = kRepeatBrick;
//      // motion bricks
//      } else if ([brick isKindOfClass:[PlaceAtBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kPlaceAtBrick;
//      } else if ([brick isKindOfClass:[SetXBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kSetXBrick;
//      } else if ([brick isKindOfClass:[SetYBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kSetYBrick;
//      } else if ([brick isKindOfClass:[ChangeXByNBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kChangeXByNBrick;
//      } else if ([brick isKindOfClass:[ChangeYByNBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kChangeYByNBrick;
//      } else if ([brick isKindOfClass:[IfOnEdgeBounceBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kIfOnEdgeBounceBrick;
//      } else if ([brick isKindOfClass:[MoveNStepsBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kMoveNStepsBrick;
//      } else if ([brick isKindOfClass:[TurnLeftBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kTurnLeftBrick;
//      } else if ([brick isKindOfClass:[TurnRightBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kTurnRightBrick;
//      } else if ([brick isKindOfClass:[PointInDirectionBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kPointInDirectionBrick;
//      } else if ([brick isKindOfClass:[PointToBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kPointToBrick;
//      } else if ([brick isKindOfClass:[GlideToBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kGlideToBrick;
//      } else if ([brick isKindOfClass:[GoNStepsBackBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kGoNStepsBackBrick;
//      } else if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
//        categoryType = kMotionBrick;
//        brickType = kComeToFrontBrick;
//      // sound bricks
//      } else if ([brick isKindOfClass:[PlaySoundBrick class]]) {
//        categoryType = kSoundBrick;
//        brickType = kPlaySoundBrick;
//      } else if ([brick isKindOfClass:[StopAllSoundsBrick class]]) {
//        categoryType = kSoundBrick;
//        brickType = kStopAllSoundsBrick;
//      } else if ([brick isKindOfClass:[SetVolumeToBrick class]]) {
//        categoryType = kSoundBrick;
//        brickType = kSetVolumeToBrick;
//      } else if ([brick isKindOfClass:[ChangeVolumeByNBrick class]]) {
//        categoryType = kSoundBrick;
//        brickType = kChangeVolumeByNBrick;
//      } else if ([brick isKindOfClass:[SpeakBrick class]]) {
//        categoryType = kSoundBrick;
//        brickType = kSpeakBrick;
//      // look bricks
//      } else if ([brick isKindOfClass:[SetLookBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kSetBackgroundBrick;
//      } else if ([brick isKindOfClass:[NextLookBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kNextBackgroundBrick;
//      } else if ([brick isKindOfClass:[SetSizeToBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kSetSizeToBrick;
//      } else if ([brick isKindOfClass:[ChangeSizeByNBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kChangeSizeByNBrick;
//      } else if ([brick isKindOfClass:[HideBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kHideBrick;
//      } else if ([brick isKindOfClass:[ShowBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kShowBrick;
//      } else if ([brick isKindOfClass:[SetGhostEffectBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kSetGhostEffectBrick;
//      } else if ([brick isKindOfClass:[ChangeGhostEffectByNBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kChangeGhostEffectByNBrick;
//      } else if ([brick isKindOfClass:[SetBrightnessBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kSetBrightnessBrick;
//      } else if ([brick isKindOfClass:[ChangeBrightnessByNBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kChangeBrightnessByNBrick;
//      } else if ([brick isKindOfClass:[ClearGraphicEffectBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kClearGraphicEffectBrick;
//      // variable bricks
//      } else if ([brick isKindOfClass:[SetVariableBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kSetVariableBrick;
//      } else if ([brick isKindOfClass:[ChangeVariableBrick class]]) {
//        categoryType = kLookBrick;
//        brickType = kChangeVariableBrick;
//      // FIXME: if-else, if-end, loop-end bricks are already missing... implement them!!!
//      }
//    }
//    CGFloat height = [BrickCell brickCellHeightForCategoryType:categoryType AndBrickType:brickType];
//
//    // TODO: increase top margin of all script bricks
//    height -= 4.0f; // TODO: outsource to const...
//    if (indexPath.section == ([self.object.scriptList count] - 1)) {
//        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
//        if (! script) {
//            NSError(@"This should never happen");
//            abort();
//        }
//        if (indexPath.row == [script.brickList count]) { // NOTE: there are ([brickList count]+1) cells!!
//            height += 8.0f; // TODO: outsource to const...
//        }
//    }
//    return CGSizeMake(width, height);
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Just for testing if adding brick works
    BrickCell *brickCell = [self.brickList objectAtIndex:indexPath.row];
    
    if (brickCell && [brickCell isKindOfClass:[BrickCell class]]) {
        return brickCell;
    }
    return nil;
    
    // TODO: TO BE REFACTORED!!
    //    BrickCell *brickCell = (BrickCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"BrickCell" forIndexPath:indexPath];
    //        Script *script = [self.object.scriptList objectAtIndex:indexPath.section];
    //        if (! script) {
    //            NSError(@"This should never happen");
    //            abort();
    //        }
    //
    //        // TODO: performance!!
    //        if (indexPath.row == 0) {
    //            // case it's a script brick
    //            kControlBrickType scriptBrickType = kReceiveBrick;
    //            if ([script isKindOfClass:[StartScript class]]) {
    //                scriptBrickType = kProgramStartedBrick;
    //            } else if ([script isKindOfClass:[WhenScript class]]) {
    //                scriptBrickType = kTappedBrick;
    //            }
    //            [brickCell convertToBrickCellForCategoryType:kControlBrick AndBrickType:scriptBrickType];
    //        } else {
    //            // case it's a normal brick
    //            kBrickCategoryType categoryType = kControlBrick;
    //            NSInteger brickType = kIfBrick;
    //            Brick *brick = [script.brickList objectAtIndex:(indexPath.row - 1)];
    //
    //            // TODO: use brick name to class name mapping with >> Class class = NSClassFromString(@"ClassName") <<
    //            // control bricks
    //            if ([brick isKindOfClass:[WaitBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kWaitBrick;
    //            } else if ([brick isKindOfClass:[BroadcastBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kBroadcastBrick;
    //            } else if ([brick isKindOfClass:[BroadcastWaitBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kBroadcastWaitBrick;
    //            } else if ([brick isKindOfClass:[NoteBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kNoteBrick;
    //            } else if ([brick isKindOfClass:[ForeverBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kForeverBrick;
    //            } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kIfBrick;
    //            } else if ([brick isKindOfClass:[RepeatBrick class]]) {
    //                categoryType = kControlBrick;
    //                brickType = kRepeatBrick;
    //            // motion bricks
    //            } else if ([brick isKindOfClass:[PlaceAtBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kPlaceAtBrick;
    //            } else if ([brick isKindOfClass:[SetXBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kSetXBrick;
    //            } else if ([brick isKindOfClass:[SetYBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kSetYBrick;
    //            } else if ([brick isKindOfClass:[ChangeXByNBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kChangeXByNBrick;
    //            } else if ([brick isKindOfClass:[ChangeYByNBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kChangeYByNBrick;
    //            } else if ([brick isKindOfClass:[IfOnEdgeBounceBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kIfOnEdgeBounceBrick;
    //            } else if ([brick isKindOfClass:[MoveNStepsBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kMoveNStepsBrick;
    //            } else if ([brick isKindOfClass:[TurnLeftBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kTurnLeftBrick;
    //            } else if ([brick isKindOfClass:[TurnRightBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kTurnRightBrick;
    //            } else if ([brick isKindOfClass:[PointInDirectionBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kPointInDirectionBrick;
    //            } else if ([brick isKindOfClass:[PointToBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kPointToBrick;
    //            } else if ([brick isKindOfClass:[GlideToBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kGlideToBrick;
    //            } else if ([brick isKindOfClass:[GoNStepsBackBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kGoNStepsBackBrick;
    //            } else if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
    //                categoryType = kMotionBrick;
    //                brickType = kComeToFrontBrick;
    //            // sound bricks
    //            } else if ([brick isKindOfClass:[PlaySoundBrick class]]) {
    //                categoryType = kSoundBrick;
    //                brickType = kPlaySoundBrick;
    //            } else if ([brick isKindOfClass:[StopAllSoundsBrick class]]) {
    //                categoryType = kSoundBrick;
    //                brickType = kStopAllSoundsBrick;
    //            } else if ([brick isKindOfClass:[SetVolumeToBrick class]]) {
    //                categoryType = kSoundBrick;
    //                brickType = kSetVolumeToBrick;
    //            } else if ([brick isKindOfClass:[ChangeVolumeByNBrick class]]) {
    //                categoryType = kSoundBrick;
    //                brickType = kChangeVolumeByNBrick;
    //            } else if ([brick isKindOfClass:[SpeakBrick class]]) {
    //                categoryType = kSoundBrick;
    //                brickType = kSpeakBrick;
    //            // look bricks
    //            } else if ([brick isKindOfClass:[SetLookBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kSetBackgroundBrick;
    //            } else if ([brick isKindOfClass:[NextLookBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kNextBackgroundBrick;
    //            } else if ([brick isKindOfClass:[SetSizeToBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kSetSizeToBrick;
    //            } else if ([brick isKindOfClass:[ChangeSizeByNBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kChangeSizeByNBrick;
    //            } else if ([brick isKindOfClass:[HideBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kHideBrick;
    //            } else if ([brick isKindOfClass:[ShowBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kShowBrick;
    //            } else if ([brick isKindOfClass:[SetGhostEffectBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kSetGhostEffectBrick;
    //            } else if ([brick isKindOfClass:[ChangeGhostEffectByNBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kChangeGhostEffectByNBrick;
    //            } else if ([brick isKindOfClass:[SetBrightnessBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kSetBrightnessBrick;
    //            } else if ([brick isKindOfClass:[ChangeBrightnessByNBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kChangeBrightnessByNBrick;
    //            } else if ([brick isKindOfClass:[ClearGraphicEffectBrick class]]) {
    //                categoryType = kLookBrick;
    //                brickType = kClearGraphicEffectBrick;
    //            // variable bricks
    //            } else if ([brick isKindOfClass:[SetVariableBrick class]]) {
    //              categoryType = kLookBrick;
    //              brickType = kSetVariableBrick;
    //            } else if ([brick isKindOfClass:[ChangeVariableBrick class]]) {
    //              categoryType = kLookBrick;
    //              brickType = kChangeVariableBrick;
    //              // FIXME: if-else, if-end, loop-end bricks are already missing... implement them!!!
    //            }
    //            [brickCell convertToBrickCellForCategoryType:categoryType AndBrickType:brickType];
    //        }
    //    // TODO: continue here
    //    return brickCell;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* toSceneSegueID = kSegueToScene;
    //    static NSString* toScriptCategoriesSegueID = kSegueToScriptCategories;
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

#pragma mark - Helper Methods

- (void)addScriptAction:(id)sender
{
    // [self performSegueWithIdentifier:kSegueToScriptCategories sender:sender];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    
    BrickCategoriesTableViewController *brickCategoryTVC = [storyboard instantiateViewControllerWithIdentifier:@"BricksCategoryTVC"];
    brickCategoryTVC.object = self.object;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:brickCategoryTVC];
    
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addScriptAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1.png"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
}

- (void)initCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

#pragma mark Notification

- (void)brickAdded:(NSNotification *)notification {
    if (notification.userInfo) {
        NSLog(@"%@: Notification Received with UserInfo: %@", [self class], notification.userInfo);
        [self.brickList addObject:notification.userInfo[UserInfoKeyBrickCell]];
        [super showPlaceHolder:NO];
    }
}

@end
