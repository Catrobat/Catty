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
    self.navigationItem.title = self.title = @"Scenes";
    
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    [self setupToolBar];
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
    UITableViewCell *cell = cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
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
    imageCell.indexPath = indexPath;
    imageCell.titleLabel.text = [self sceneAtIndexPath:indexPath].name;
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
        
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:@"Edit Scene"]
              addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kLocalizedCopy handler:^{
                 [Util askUserForUniqueNameAndPerformAction:@selector(copySceneActionForSceneWithName:sourceScene:)
                                                     target:self
                                               cancelAction:nil
                                                 withObject:scene
                                                promptTitle:@"Copy scene"
                                              promptMessage:[NSString stringWithFormat:@"%@:", @"Scene name"]
                                                promptValue:scene.name
                                          promptPlaceholder:@"Enter your scene name here..."
                                             minInputLength:kMinNumOfProgramNameCharacters
                                             maxInputLength:kMaxNumOfProgramNameCharacters
                                        blockedCharacterSet:[self blockedCharacterSet]
                                   invalidInputAlertMessage:@"A scene with the same name already exists, try again."
                                              existingNames:[self.program allSceneNames]];
             }]
            addDefaultActionWithTitle:kLocalizedRename handler:^{
                NSMutableArray *unavailableNames = [[self.program allSceneNames] mutableCopy];
                [unavailableNames removeObject:scene.name];
                [Util askUserForUniqueNameAndPerformAction:@selector(renameSceneActionToName:scene:)
                                                    target:self
                                              cancelAction:nil
                                                withObject:scene
                                               promptTitle:@"Rename scene"
                                             promptMessage:[NSString stringWithFormat:@"%@:", @"Scene name"]
                                               promptValue:scene.name
                                         promptPlaceholder:@"Enter your scene name here..."
                                            minInputLength:kMinNumOfObjectNameCharacters
                                            maxInputLength:kMaxNumOfObjectNameCharacters
                                       blockedCharacterSet:[self blockedCharacterSet]
                                  invalidInputAlertMessage:@"A scene with the same name already exists, try again."
                                             existingNames:unavailableNames];
            }] build]
          viewWillDisappear:^{
              [self.tableView setEditing:false animated:YES];
          }]
         showWithController:self];
    }];
    moreAction.backgroundColor = [UIColor globalTintColor];
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [[[[[AlertControllerBuilder alertWithTitle:@"Delete this scene" message:kLocalizedThisActionCannotBeUndone]
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
    [Util askUserForUniqueNameAndPerformAction:@selector(addSceneAndSegueToItActionForSceneWithName:)
                                        target:self
                                   promptTitle:@"New scene"
                                 promptMessage:[NSString stringWithFormat:@"%@:", @"Scene name"]
                                   promptValue:nil
                             promptPlaceholder:@"Enter your scene name here..."
                                minInputLength:1
                                maxInputLength:250
                           blockedCharacterSet:[self blockedCharacterSet]
                      invalidInputAlertMessage:@"A scene with the same name already exists, try again."
                                 existingNames:[self.program allSceneNames]];
}

- (void)addSceneAndSegueToItActionForSceneWithName:(NSString *)name {
    Scene *newScene = [Scene defaultSceneWithName:name];
    [self.program addScene:newScene];
    
    [self segueToScene:newScene];
    
    [self.tableView reloadData];
    [self saveProgram:self.program showingSavedView:YES];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    [[[[[[AlertControllerBuilder actionSheetWithTitle:@"Edit scenes"]
     addCancelActionWithTitle:kLocalizedCancel handler:nil]
     addDefaultActionWithTitle:@"Move scenes" handler:^{
         self.deletionMode = NO;
         [self changeToMoveMode:sender];
     }]
     addDestructiveActionWithTitle:@"Delete scenes" handler:^{
         self.deletionMode = YES;
         [self setupEditingToolBar];
         [super changeToEditingMode:sender];
     }]
     build] showWithController:self];
}

- (void)renameSceneActionToName:(NSString *)newName scene:(Scene *)scene {
    [[ProgramManager instance] renameScene:scene toName:newName];
    
    [self.tableView reloadData];
}

- (void)copySceneActionForSceneWithName:(NSString *)sceneName sourceScene:(Scene *)sourceScene {
    sceneName = [Util uniqueName:sceneName existingNames:[self.program allSceneNames]];
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
    
    [self.program removeScenes:scenesToDelete];
    [self saveProgram:self.program showingSavedView:YES];
    
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
