/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "SceneTableViewController.h"
#import "TableUtil.h"
#import "ObjectTableViewController.h"
#import "SegueDefines.h"
#import "Brick.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Util.h"
#import "UIUtil.h"
#import "CellTagDefines.h"
#import "ProjectTableHeaderView.h"
#import "RuntimeImageCache.h"
#import "LooksTableViewController.h"
#import "ViewControllerDefines.h"
#import "PlaceHolderView.h"
#import "Pocket_Code-Swift.h"

@interface SceneTableViewController () <UINavigationBarDelegate, SetProjectDescriptionDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic) BOOL deletionMode;
@property (nonatomic, strong) ProjectManager *projectManager;
@end

@implementation SceneTableViewController

#pragma mark - getters and setters
- (ProjectManager*)projectManager
{
    if (! _projectManager) {
        _projectManager = [ProjectManager shared];
    }
    return _projectManager;
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedEdit
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - view events

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsObjectsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsObjectsKey];
    self.useDetailCells = [showDetailsObjectsValue boolValue];
    [self initNavigationBar];
    [self.tableView registerClass:[ProjectTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.editableSections = @[@(kObjectSectionIndex)];
    
    if (self.scene.project.header.programName) {
        self.navigationItem.title = self.scene.project.header.programName;
        self.title = self.scene.project.header.programName;
    }
    self.placeHolderView.title = kLocalizedTapPlusToAddSprite;
    [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    [self setupToolBar];
    if(self.showAddObjectActionSheetAtStart) {
        [self addObjectAction:nil];
    }
    [self checkUnsupportedElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

#pragma mark - actions
- (void)addObjectAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    [[[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedAddObject message:[NSString stringWithFormat:@"%@:", kLocalizedObjectName]]
          placeholder:kLocalizedEnterYourObjectNameHere]
         addCancelActionWithTitle:kLocalizedCancel handler:^{
        [self cancelAddingObjectFromScriptEditor];
    }]
        addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *name) {
        [self addObjectActionWithName:name];
    }]
       valueValidator:^InputValidationResult *(NSString *name) {
        InputValidationResult *result = [Util validationResultWithName:name
                                                             minLength:kMinNumOfObjectNameCharacters
                                                             maxlength:kMaxNumOfObjectNameCharacters];
        if (!result.valid) {
            return result;
        }
        // Alert for Objects with same name
        if ([[self.scene allObjectNames] containsObject:name]) {
            return [InputValidationResult invalidInputWithLocalizedMessage:kLocalizedObjectNameAlreadyExistsDescription];
        }
        return [InputValidationResult validInput];
    }] build]
     showWithController:self];
}

-(void)cancelAddingObjectFromScriptEditor
{
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
}

- (void)addObjectActionWithName:(NSString*)objectName
{
    [self showLoadingView];
    [self.scene addObjectWithName:[Util uniqueName:objectName existingNames:[self.scene allObjectNames]]];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:(([self.scene numberOfNormalObjects] == 1) ? UITableViewRowAnimationFade : UITableViewRowAnimationBottom)];
    
    LooksTableViewController *ltvc = [self.storyboard instantiateViewControllerWithIdentifier:kLooksTableViewControllerIdentifier];
    [ltvc setObject:[self.scene.objects objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)]];
    ltvc.showAddLookActionSheetAtStartForObject = YES;
    ltvc.showAddLookActionSheetAtStartForScriptEditor = NO;
    ltvc.afterSafeBlock =  ^(Look* look) {
        [self.navigationController popViewControllerAnimated:YES];
        if (!look) {
            NSUInteger index = (kBackgroundObjects + indexPath.row);
            SpriteObject *object = (SpriteObject*)[self.scene.objects objectAtIndex:index];
            [self.scene removeObject:object];
            [self.scene.project saveToDiskWithNotification:NO];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:((indexPath.row != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
        }
        if (self.afterSafeBlock && look ) {
            NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
            self.afterSafeBlock([self.scene.objects objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)]);
        }else if (self.afterSafeBlock && !look){
            self.afterSafeBlock(nil);
        }
        [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    };
    [self.navigationController pushViewController:ltvc animated:NO];
    [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    [self hideLoadingView];
}

- (void)renameProjectActionForProjectWithName:(NSString*)newProjectName
{
    if ([newProjectName isEqualToString:self.scene.project.header.programName])
        return;
    
    [self showLoadingView];
    newProjectName = [Util uniqueName:newProjectName existingNames:[Project allProjectNames]];
    [self.scene.project renameToProjectName:newProjectName andShowSaveNotification:YES];
    self.navigationItem.title = self.title = self.scene.project.header.programName;
    [self hideLoadingView];
}

- (void)copyObjectActionWithSourceObject:(SpriteObject*)sourceObject
{
    [self showLoadingView];
    NSString *nameOfCopiedObject = [Util uniqueName:sourceObject.name existingNames:[self.scene allObjectNames]];
    (void)[self.scene copyObject:sourceObject withNameForCopiedObject:nameOfCopiedObject];
    
    // create new cell
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self hideLoadingView];
}

- (void)confirmCopySelectedObjectsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to copy...
        [super exitEditingMode];
        return;
    }
    [self copySelectedObjectsAction];
}

- (void)copySelectedObjectsAction
{
    [self showLoadingView];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToCopy = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        
        if (selectedRowIndexPath.section != kObjectSectionIndex) {
            continue;
        }
        SpriteObject *object = (SpriteObject*)[self.scene.objects objectAtIndex:(kObjectSectionIndex + selectedRowIndexPath.row)];
        [objectsToCopy addObject:object];
    }
    (void)[self.scene copyObjects:objectsToCopy];
    [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    [super exitEditingMode];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:kObjectSectionIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:kObjectSectionIndex];
    [self.tableView insertRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView reloadData];
    [self hideLoadingView];
}

- (void)renameObjectActionToName:(NSString*)newObjectName spriteObject:(SpriteObject*)spriteObject
{
    if ([newObjectName isEqualToString:spriteObject.name])
        return;
    
    [self showLoadingView];
    newObjectName = [Util uniqueName:newObjectName existingNames:[self.scene allObjectNames]];
    [self.scene renameObject:spriteObject toName:newObjectName];
    NSUInteger spriteObjectIndex = [self.scene.objects indexOfObject:spriteObject];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(spriteObjectIndex - kBackgroundObjects)
                                                inSection:kObjectSectionIndex];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self hideLoadingView];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditProject]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    
    
    if ([self.scene numberOfNormalObjects]) {
        [actionSheet addDestructiveActionWithTitle:kLocalizedDeleteObjects handler:^{
            self.deletionMode = YES;
            [self setupEditingToolBar];
            [super changeToEditingMode:sender];
        }];
    }
    if ([self.scene numberOfNormalObjects] >= 2) {
        [actionSheet addDefaultActionWithTitle:kLocalizedMoveObjects handler:^{
            self.deletionMode = NO;
            [super changeToMoveMode:sender];
        }];
    }
    if ([self.scene numberOfNormalObjects]) {
        [actionSheet addDefaultActionWithTitle:kLocalizedCopyObjects handler:^{
            self.deletionMode = NO;
            [self setupCopyingToolBar];
            [self changeToCopyMode:sender];
        }];
    }
    
    NSString *detailActionTitle = self.useDetailCells ? kLocalizedHideDetails : kLocalizedShowDetails;
    
    NSString *changeOrientation = self.scene.project.header.landscapeMode ? kLocalizedMakeItPortrait : kLocalizedMakeItLandscape;
    
    [[[[[actionSheet
         addDefaultActionWithTitle:changeOrientation handler:^{
        [self changeProjectOrientationAction:self.scene.project];
    }]
        addDefaultActionWithTitle:kLocalizedRenameProject handler:^{
        NSMutableArray *unavailableNames = [[Project allProjectNames] mutableCopy];
        [unavailableNames removeString:self.scene.project.header.programName];
        [Util askUserForUniqueNameAndPerformAction:@selector(renameProjectActionForProjectWithName:)
                                            target:self
                                       promptTitle:kLocalizedRenameProject
                                     promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                       promptValue:((! [self.scene.project.header.programName isEqualToString:kLocalizedNewProject])
                                                    ? self.scene.project.header.programName : nil)
                                 promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                    minInputLength:kMinNumOfProjectNameCharacters
                                    maxInputLength:kMaxNumOfProjectNameCharacters
                          invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                     existingNames:unavailableNames];
    }]
       addDefaultActionWithTitle:detailActionTitle handler:^{
        [self toggleDetailCellsMode];
    }]
      build]
     showWithController:self];
}

- (void)changeProjectOrientationAction:(Project*) project {
    [self showLoadingView];
    [self.scene.project changeProjectOrientation];
    
    [self.scene.project saveToDiskWithNotification:YES andCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [super viewDidLoad];
            [self hideLoadingView];
        });
    }];
}

- (void)toggleDetailCellsMode {
    self.useDetailCells = !self.useDetailCells;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *showDetails = [defaults objectForKey:kUserDetailsShowDetailsKey];
    NSMutableDictionary *showDetailsMutable = nil;
    if (! showDetails) {
        showDetailsMutable = [NSMutableDictionary dictionary];
    } else {
        showDetailsMutable = [showDetails mutableCopy];
    }
    [showDetailsMutable setObject:[NSNumber numberWithBool:self.useDetailCells]
                           forKey:kUserDetailsShowDetailsObjectsKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self.tableView reloadData];
}

- (void)confirmDeleteSelectedObjectsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedObjectsAction];
}

- (void)deleteSelectedObjectsAction
{
    [self showLoadingView];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        // sanity check
        if (selectedRowIndexPath.section != kObjectSectionIndex) {
            continue;
        }
        SpriteObject *object = (SpriteObject*)[self.scene.objects objectAtIndex:(kObjectSectionIndex + selectedRowIndexPath.row)];
        [objectsToRemove addObject:object];
    }
    [self.projectManager removeObjects:self.scene.project objects:objectsToRemove];
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:(([self.scene numberOfNormalObjects] != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
    [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    [self hideLoadingView];
}

- (void)deleteObjectForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    NSUInteger index = (kBackgroundObjects + indexPath.row);
    SpriteObject *object = (SpriteObject*)[self.scene.objects objectAtIndex:index];
    [self.scene removeObject:object];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:((indexPath.row != 0) ? UITableViewRowAnimationTop : UITableViewRowAnimationFade)];
    [self showPlaceHolder:!(BOOL)[self.scene numberOfNormalObjects]];
    [self hideLoadingView];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInSceneTableViewController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kBackgroundSectionIndex:
            return [self.scene numberOfBackgroundObjects];
        case kObjectSectionIndex:
            return [self.scene numberOfNormalObjects];
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    static NSString *DetailCellIdentifier = kDetailImageCell;
    UITableViewCell *cell = nil;
    if (! self.useDetailCells) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    }
    
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)] || ! [cell isKindOfClass:[CatrobatBaseCell class]]) {
        return cell;
    }
    
    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    NSInteger index = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
    SpriteObject *object = [self.scene.objects objectAtIndex:index];
    imageCell.iconImageView.image = nil;
    
    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedScripts,
                                              (unsigned long)[object numberOfScripts]];
        detailCell.topRightDetailLabel.textColor = UIColor.textTint;
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedBricks,
                                               (unsigned long)[object numberOfTotalBricks]];
        detailCell.bottomLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedLooks,
                                                 (unsigned long)[object numberOfLooks]];
        detailCell.bottomRightDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kLocalizedSounds,
                                                  (unsigned long)[object numberOfSounds]];
    }
    
    if (! [object.lookList count]) {
        imageCell.titleLabel.text = object.name;
        return imageCell;
    }
    
    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    imageCell.iconImageView.image = nil;
    imageCell.indexPath = indexPath;
    
    NSString *previewImagePath = [object previewImagePath];
    
    UIImage *image = [imageCache cachedImageForPath:previewImagePath andSize:UIDefines.previewImageSize];
    if (! image) {
        [imageCache loadImageFromDiskWithPath:previewImagePath
                                      andSize:UIDefines.previewImageSize
                                 onCompletion:^(UIImage *img, NSString* path) {
            if ([imageCell.indexPath isEqual:indexPath]) {
                imageCell.iconImageView.image = img;
                [imageCell setNeedsLayout];
            }
        }];
    } else {
        imageCell.iconImageView.image = image;
    }
    imageCell.titleLabel.text = object.name;
    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // INFO: NEVER REMOVE THIS EMPTY METHOD!!
    // This activates the swipe gesture handler for TableViewCells.
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    if(self.deletionMode) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger index = (kBackgroundSectionIndex + sourceIndexPath.section + sourceIndexPath.row);
    NSInteger destIndex = (kBackgroundSectionIndex + destinationIndexPath.section + destinationIndexPath.row);
    SpriteObject* itemToMove = self.scene.objects[index];
    [self.scene removeObjectAtIndex:index];
    [self.scene insertObject:itemToMove atIndex:destIndex];
    [self.scene.project saveToDiskWithNotification:NO];
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        NSInteger spriteObjectIndex = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
        
        SpriteObject *spriteObject = [self.scene.objects objectAtIndex:spriteObjectIndex];
        
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditObject]
              addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kLocalizedCopy handler:^{
            [self copyObjectActionWithSourceObject:spriteObject];
        }]
            addDefaultActionWithTitle:kLocalizedRename handler:^{
            NSMutableArray *unavailableNames = [[self.scene allObjectNames] mutableCopy];
            [unavailableNames removeString:spriteObject.name];
            [Util askUserForUniqueNameAndPerformAction:@selector(renameObjectActionToName:spriteObject:)
                                                target:self
                                          cancelAction:nil
                                            withObject:spriteObject
                                           promptTitle:kLocalizedRenameObject
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedObjectName]
                                           promptValue:spriteObject.name
                                     promptPlaceholder:kLocalizedEnterYourObjectNameHere
                                        minInputLength:kMinNumOfObjectNameCharacters
                                        maxInputLength:kMaxNumOfObjectNameCharacters
                              invalidInputAlertMessage:kLocalizedObjectNameAlreadyExistsDescription
                                         existingNames:unavailableNames];
        }] build]
          viewWillDisappear:^{
            [self.tableView setEditing:false animated:YES];
        }]
         showWithController:self];
    }];
    moreAction.backgroundColor = UIColor.globalTint;
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        // check just to ensure that background object can never be deleted!!
        if (indexPath.section != kObjectSectionIndex) {
            return;
        }
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisObject message:kLocalizedThisActionCannotBeUndone]
            addCancelActionWithTitle:kLocalizedCancel handler:nil]
           addDefaultActionWithTitle:kLocalizedYes handler:^{
            [self deleteObjectForIndexPath:indexPath];
        }] build]
         showWithController:self];
    }];
    return @[deleteAction, moreAction];
}

#pragma mark - Header View
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 45.0;
        case 1:
            return 50.0;
        default:
            return 45.0;
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    ProjectTableHeaderView *headerView = (ProjectTableHeaderView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    if (section == 0) {
        headerView.textLabel.text = [kLocalizedBackground uppercaseString];
    } else {
        headerView.textLabel.text = (([self.scene numberOfNormalObjects] != 1)
                                     ? [kLocalizedObjects uppercaseString]
                                     : [kLocalizedObject uppercaseString]);
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    static NSString *segueToObject = kSegueToObject;
    if (! self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self shouldPerformSegueWithIdentifier:segueToObject sender:cell]) {
            [self performSegueWithIdentifier:segueToObject sender:cell];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    ProjectTableHeaderView *headerView = (ProjectTableHeaderView*)view;
    headerView.textLabel.textColor = UIColor.globalTint;
}

#pragma mark - segue handler
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the selected object to the new view controller.
    static NSString *toObjectSegueID = kSegueToObject;
    
    UIViewController *destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*) sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if ([segue.identifier isEqualToString:toObjectSegueID]) {
            if ([destController isKindOfClass:[ObjectTableViewController class]]) {
                ObjectTableViewController *tvc = (ObjectTableViewController*) destController;
                if ([tvc respondsToSelector:@selector(setObject:)]) {
                    SpriteObject* object = [self.scene.objects objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)];
                    [destController performSelector:@selector(setObject:) withObject:object];
                }
            }
        }
    }
}

#pragma mark - helpers

- (void)checkUnsupportedElements
{
    if (self.scene.project.unsupportedElements && self.scene.project.unsupportedElements.count > 0) {
        NSString *unsupportedElementsString = [self.scene.project.unsupportedElements.allObjects componentsJoinedByString:@", "];
        [[[[[[AlertControllerBuilder alertWithTitle:kLocalizedUnsupportedElements message:[NSString stringWithFormat:@"%@\n\n%@", kLocalizedUnsupportedElementsDescription, unsupportedElementsString]] addDefaultActionWithTitle:kLocalizedCancel handler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }] addDefaultActionWithTitle:kLocalizedMoreInformation handler:^{
            [Util openUrlExternal:[NSURL URLWithString:NetworkDefines.unsupportedElementsUrl]];
        }] addDefaultActionWithTitle:kLocalizedOK handler:nil] build]
         showWithController:self];
    }
}

- (void)setupToolBar
{
    [super setupToolBar];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addObjectAction:)];
    UIBarButtonItem *play = [[PlayButton alloc] initWithTarget:self
                                                        action:@selector(playSceneAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: flex, add, flex, flex, play, flex, nil];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmDeleteSelectedObjectsAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, flex, deleteButton, nil];
}

- (void)setupCopyingToolBar
{
    [super setupEditingToolBar];
    
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCopy
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(confirmCopySelectedObjectsAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, flex, copyButton, nil];
}

#pragma mark description delegate
- (void)setDescription:(NSString *)description
{
    [self showLoadingView];
    [self.scene.project setDescription:description];
    [self.scene.project saveToDiskWithNotification:NO andCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingView];
            [Util showNotificationForSaveAction];
        });
    }];
}

@end
