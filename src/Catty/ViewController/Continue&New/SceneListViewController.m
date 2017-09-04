/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "SceneListViewController.h"
#import "TableUtil.h"
#import "CatrobatBaseCell.h"
#import "CatrobatImageCell.h"
#import "Scene.h"
#import "SegueDefines.h"
#import "ObjectListViewController.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"
#import "ViewControllerDefines.h"
#import "UIUtil.h"
#import "ProgramManager.h"
#import "NSArray+CustomExtension.h"
#import "AppDelegate.h"

@interface SceneListViewController ()
@property (nonatomic, getter=isDeletionMode) BOOL deletionMode;
@end

@implementation SceneListViewController

static NSCharacterSet *blockedCharacterSet = nil;
- (NSCharacterSet*)blockedCharacterSet {
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
}

- (void)initNavigationBar {
    self.navigationItem.title = self.title = kLocalizedScenes;
    
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    [self setupToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView reloadData];
}

- (NSInteger)numberOfScenes {
    return [self.program.scenes count];
}

- (Scene *)sceneAtIndex:(NSInteger)index {
    return self.program.scenes[index];
}

- (Scene *)sceneAtIndexPath:(NSIndexPath *)indexPath {
    return [self sceneAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfScenes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    if (! [cell isKindOfClass:[CatrobatBaseCell class]] || ! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    
    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    [self configureImageCell:imageCell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell> *)imageCell atIndexPath:(NSIndexPath *)indexPath {
    Scene *scene = [self sceneAtIndexPath:indexPath];
    imageCell.indexPath = indexPath;
    imageCell.titleLabel.text = scene.name;
    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    imageCell.iconImageView.image = nil;
    
    // check if one of these screenshot files is available in memory
    NSArray *fallbackPaths = @[[FileSystemStorage manualScreenshotPathForScene:scene],
                               [FileSystemStorage automaticScreenshotPathForScene:scene]];
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    for (NSString *fallbackPath in fallbackPaths) {
        NSString *thumbnailPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:fallbackPath];
        UIImage *image = [imageCache cachedImageForPath:thumbnailPath];
        if (image) {
            imageCell.iconImageView.image = image;
            return;
        }
    }
    
    // no screenshot files in memory, check if one of these screenshot files exists on disk
    // if a screenshot file is found, then load it from disk and cache it in memory for future access
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
        for (NSString *fallbackPath in fallbackPaths) {
            if ([fileManager fileExists:fallbackPath]) {
                NSString *thumbnailPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:fallbackPath];
                [imageCache loadThumbnailImageFromDiskWithThumbnailPath:thumbnailPath
                                                              imagePath:fallbackPath
                                                     thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)
                                                           onCompletion:^(UIImage *image, NSString* path){
                                                               // check if cell still needed
                                                               if ([imageCell.indexPath isEqual:indexPath]) {
                                                                   imageCell.iconImageView.image = image;
                                                                   [imageCell setNeedsLayout];
                                                                   [self.tableView endUpdates];
                                                               }
                                                           }];
                return;
            }
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isEditing]) {
        [self segueToScene:[self sceneAtIndexPath:indexPath]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isDeletionMode == NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.program moveSceneAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    [self saveProgram:self.program showingSavedView:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        Scene *scene = [self sceneAtIndexPath:indexPath];
        
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditScene]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             
             [[[[[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedCopyScene message:[NSString stringWithFormat:@"%@:", kLocalizedSceneName]]
              initialText:scene.name]
              placeholder:kLocalizedEnterYourSceneNameHere]
              addCancelActionWithTitle:kLocalizedCancel handler:NULL]
              addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
                        [self copySceneActionForSceneWithName:name sourceScene:scene];
              }]
              characterValidator:^BOOL(NSString *symbol) {
                       return ![[self blockedCharacterSet] characterIsMember:[symbol characterAtIndex:0]];
              }]
              valueValidator:^InputValidationResult *(NSString *name) {
                      return [self.program isValidNewSceneName:name];
              }]
              build] showWithController:self];
             
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             
             [[[[[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedRenameScene message:[NSString stringWithFormat:@"%@:", kLocalizedSceneName]]
              initialText:scene.name]
              placeholder:kLocalizedEnterYourSceneNameHere]
              addCancelActionWithTitle:kLocalizedCancel handler:NULL]
              addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
                  [self renameSceneActionToName:name scene:scene];
              }]
              characterValidator:^BOOL(NSString *symbol) {
                  return ![[self blockedCharacterSet] characterIsMember:[symbol characterAtIndex:0]];
              }]
              valueValidator:^InputValidationResult *(NSString *name) {
                  if ([name caseInsensitiveCompare:scene.name] == NSOrderedSame) {
                      return [InputValidationResult validInput];
                  }
                  return [self.program isValidNewSceneName:name];
              }]
              build] showWithController:self];
             
         }] build]
         viewWillDisappear:^{
             [self.tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = [UIColor globalTintColor];
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisScene message:kLocalizedThisActionCannotBeUndone]
            addCancelActionWithTitle:kLocalizedCancel handler:nil]
           addDefaultActionWithTitle:kLocalizedYes handler:^{
               [self deleteScenesAtIndexPaths:@[indexPath]];
           }] build]
         showWithController:self];
    }];
    return @[deleteAction, moreAction];
}

- (void)segueToScene:(Scene *)scene {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
    
    ObjectListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kObjectListViewControllerIdentifier];
    controller.scene = scene;
    controller.delegate = self.delegate;
    
    UINavigationController *navController = self.navigationController;
    
    if ([self numberOfScenes] == 1) {
        [navController popViewControllerAnimated:NO];
        controller.shouldBehaveAsIfObjectsBelongToProgram = YES;
    }
    [navController pushViewController:controller animated:YES];
}

- (void)addSceneAction:(id)sender
{
    [[[[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedNewScene message:[NSString stringWithFormat:@"%@:", kLocalizedSceneName]]
     placeholder:kLocalizedEnterYourSceneNameHere]
     addCancelActionWithTitle:kLocalizedCancel handler:NULL]
     addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *value) {
         [self addSceneAndSegueToItActionForSceneWithName:value];
     }]
     characterValidator:^BOOL(NSString *symbol) {
         return ![[self blockedCharacterSet] characterIsMember:[symbol characterAtIndex:0]];
     }]
     valueValidator:^InputValidationResult *(NSString *name) {
         return [self.program isValidNewSceneName:name];
     }]
     build] showWithController:self];
}

- (void)addSceneAndSegueToItActionForSceneWithName:(NSString *)name {
    Scene *newScene = [Scene defaultSceneWithName:name];
    [[ProgramManager instance] addScene:newScene toProgram:self.program];
    
    [self segueToScene:newScene];
    
    [self.tableView reloadData];
    [self saveProgram:self.program showingSavedView:YES];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    [[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditScenes]
     addCancelActionWithTitle:kLocalizedCancel handler:nil]
     addDefaultActionWithTitle:kLocalizedMoveScenes handler:^{
         self.deletionMode = NO;
         [self changeToMoveMode:sender];
     }]
     addDestructiveActionWithTitle:kLocalizedDeleteScenes handler:^{
         self.deletionMode = YES;
         [self setupEditingToolBar];
         [super changeToEditingMode:sender];
     }]
     build] showWithController:self];
}

- (void)renameSceneActionToName:(NSString *)newName scene:(Scene *)scene {
    [self showLoadingView];
    [[ProgramManager instance] renameScene:scene toName:newName];
    [self hideLoadingView];
    
    [self.tableView reloadData];
}

- (void)copySceneActionForSceneWithName:(NSString *)sceneName sourceScene:(Scene *)sourceScene {
    [[ProgramManager instance] copyScene:sourceScene destinationSceneName:sceneName];
    
    [self.tableView reloadData];
}

- (void)confirmDeleteSelectedScenesAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    [super exitEditingMode];
    
    if ([selectedRowsIndexPaths count] != 0) {
        [self deleteScenesAtIndexPaths:selectedRowsIndexPaths];
    }
}

- (void)deleteScenesAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSParameterAssert(indexPaths.count);
    NSMutableArray<Scene *> *scenesToDelete = [NSMutableArray arrayWithCapacity:[indexPaths count]];
    
    for (NSIndexPath *indexPath in indexPaths) {
        [scenesToDelete addObject:[self sceneAtIndexPath:indexPath]];
    }
    BOOL newSceneWasCreated = [scenesToDelete count] == [self numberOfScenes];
    
    [[ProgramManager instance] removeScenes:scenesToDelete fromProgram:self.program];
    
    if (newSceneWasCreated) {
        [self.tableView reloadData];
    } else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    
    if ([self numberOfScenes] == 1) {
        [self segueToScene:[self sceneAtIndex:0]];
    }
}

- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addSceneAction:)];
    self.toolbarItems = @[flexItem, add, flexItem];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmDeleteSelectedScenesAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}

@end
