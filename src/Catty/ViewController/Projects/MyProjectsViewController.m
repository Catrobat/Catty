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

#import "MyProjectsViewController.h"
#import "Util.h"
#import "ProjectLoadingInfo.h"
#import "SceneTableViewController.h"
#import "CBFileManager.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "SegueDefines.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "RuntimeImageCache.h"
#import "UIUtil.h"
#import "Pocket_Code-Swift.h"
#import "ViewControllerDefines.h"

@interface MyProjectsViewController () <UITextFieldDelegate, SetProjectDescriptionDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic) NSInteger projectsCounter;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSMutableDictionary *projectLoadingInfoDict;
@property (nonatomic, strong) Project *defaultProject;
@property (nonatomic, strong) ProjectManager *projectManager;
@end

@implementation MyProjectsViewController

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
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsProjectsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsProjectsKey];
    self.useDetailCells = [showDetailsProjectsValue boolValue];
    self.navigationController.title = self.title = kLocalizedProjects;
    [self initNavigationBar];
    self.defaultProject = nil;
    self.selectedProject = nil;
    
    [self setupToolBar];
    
    [self setSectionHeaders];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.sectionIndexBackgroundColor = UIColor.background;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.defaultProject = nil;
    self.selectedProject = nil;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self reloadTableView];
}

#pragma mark - system events
- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditProjects]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    
    if (self.projectsCounter) {
        [actionSheet addDestructiveActionWithTitle:kLocalizedDeleteProjects handler:^{
            [self setupEditingToolBar];
            [super changeToEditingMode:sender];
        }];
    }
    
    NSString *detailActionTitle = self.useDetailCells ? kLocalizedHideDetails : kLocalizedShowDetails;
    [[[actionSheet
     addDefaultActionWithTitle:detailActionTitle handler:^{
         [self toggleDetailCellsMode];
     }] build]
     showWithController:self];
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
                           forKey:kUserDetailsShowDetailsProjectsKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self reloadTableView];
}

- (void)addProjectAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    [Util askUserForUniqueNameAndPerformAction:@selector(createAndOpenProjectWithName:)
                                        target:self
                                   promptTitle:kLocalizedNewProject
                                 promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                minInputLength:kMinNumOfProjectNameCharacters
                                maxInputLength:kMaxNumOfProjectNameCharacters
                      invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                 existingNames:[Project allProjectNames]];
}

- (void)createAndOpenProjectWithName:(NSString*)projectName
{
    projectName = [Util uniqueName:projectName existingNames:[Project allProjectNames]];
    self.defaultProject = [self.projectManager createProjectWithName:projectName projectId:nil];
    
    if (self.defaultProject) {
        [self addProject:self.defaultProject.header.programName];
        [self openProject:self.defaultProject];
    }
}

- (void)copyProjectActionForProjectWithName:(NSString*)projectName
                   sourceProjectLoadingInfo:(ProjectLoadingInfo*)sourceProjectLoadingInfo
{
    projectName = [Util uniqueName:projectName existingNames:[Project allProjectNames]];
    ProjectLoadingInfo *destinationProjectLoadingInfo = [self addProject:projectName];
    if (! destinationProjectLoadingInfo)
        return;
    
    [self showLoadingView];
    [Project copyProjectWithSourceProjectName:sourceProjectLoadingInfo.visibleName
                              sourceProjectID:sourceProjectLoadingInfo.projectID
                       destinationProjectName:projectName];
    [self.dataCache removeObjectForKey:destinationProjectLoadingInfo.visibleName];
    NSIndexPath* indexPath = [self getPathForProjectLoadingInfo:destinationProjectLoadingInfo];
    if (indexPath.section < self.tableView.numberOfSections)
    {
        [self setSectionHeaders];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        // Section is now completely empty, so delete the entire section.
        [self setSectionHeaders];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    
    [self reloadTableView];
    [self hideLoadingView];
}

- (void)renameProjectActionToName:(NSString*)newProjectName
         sourceProjectLoadingInfo:(ProjectLoadingInfo*)projectLoadingInfo
{
    if ([newProjectName isEqualToString:projectLoadingInfo.visibleName])
        return;
    
    [self showLoadingView];
    Project *project = [Project projectWithLoadingInfo:projectLoadingInfo];
    newProjectName = [Util uniqueName:newProjectName existingNames:[Project allProjectNames]];
    [project renameToProjectName:newProjectName andShowSaveNotification:YES];
    [self renameOldProjectWithName:projectLoadingInfo.visibleName
                         projectID:projectLoadingInfo.projectID
                  toNewProjectName:project.header.programName];
    [self reloadTableView];
    [self hideLoadingView];
}

- (void)confirmDeleteSelectedProjectsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedProjectsAction];
}

- (void)deleteSelectedProjectsAction
{
    [self showLoadingView];
    
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *projectLoadingInfosToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:selectedRowIndexPath.section];
        NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProjectLoadingInfo *info = [sectionInfos objectAtIndex:selectedRowIndexPath.row];
        [projectLoadingInfosToRemove addObject:info];
    }
    for (ProjectLoadingInfo *projectLoadingInfoToRemove in projectLoadingInfosToRemove) {
        [self removeProjectWithName:projectLoadingInfoToRemove.visibleName
                          projectID:projectLoadingInfoToRemove.projectID];
    }
    
    [self reloadTableView];
    [self hideLoadingView];
    [super exitEditingMode];
}

- (void)deleteProjectForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
    ProjectLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
    [self removeProjectWithName:info.visibleName projectID:info.projectID];
    
    [self reloadTableView];
    [self hideLoadingView];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:section];
    NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
    return [sectionInfos count];
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
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    if (! [cell isKindOfClass:[CatrobatBaseCell class]] || ! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    
    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    [self configureImageCell:imageCell atIndexPath:indexPath];
    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLastAccess];
        detailCell.topRightDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = UIColor.textTint;
        detailCell.topRightDetailLabel.text = [kLocalizedLoading stringByAppendingString:@"..."];
        detailCell.bottomRightDetailLabel.text = [kLocalizedLoading stringByAppendingString:@"..."];
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProjectLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
        NSNumber *projectSize = [self.dataCache objectForKey:info.visibleName];
        CBFileManager *fileManager = [CBFileManager sharedManager];
        if (projectSize) {
            NSString *xmlPath = [NSString stringWithFormat:@"%@/%@", info.basePath, kProjectCodeFileName];
            NSDate *lastAccessDate = [fileManager lastModificationTimeOfFile:xmlPath];
            detailCell.topRightDetailLabel.text = [lastAccessDate humanFriendlyFormattedString];
            detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[projectSize unsignedIntegerValue]
                                                                                    countStyle:NSByteCountFormatterCountStyleBinary];
            return detailCell;
        }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // check if cell still needed
            if (! [detailCell.indexPath isEqual:indexPath]) {
                return;
            } else if (! [tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                return;
            }
            
            NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
            NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
            
            ProjectLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
            if (!info) {
                return;
            }
            
            NSNumber *projectSize = [self.dataCache objectForKey:info.visibleName];
            if (! projectSize) {
                NSUInteger resultSize = [fileManager sizeOfDirectoryAtPath:info.basePath];
                projectSize = [NSNumber numberWithUnsignedInteger:resultSize];
                [self.dataCache setObject:projectSize forKey:info.visibleName];
            }
            
            NSString *xmlPath = [NSString stringWithFormat:@"%@/%@", info.basePath, kProjectCodeFileName];
            NSDate *lastAccessDate = [fileManager lastModificationTimeOfFile:xmlPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                detailCell.topRightDetailLabel.text = [lastAccessDate humanFriendlyFormattedString];
                detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[projectSize unsignedIntegerValue]
                                                                                        countStyle:NSByteCountFormatterCountStyleBinary];
                [detailCell setNeedsLayout];
                [self.tableView endUpdates];
            });
        });
        return detailCell;
    }
    return imageCell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // INFO: NEVER REMOVE THIS EMPTY METHOD!!
    // This activates the swipe gesture handler for TableViewCells.
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProjectLoadingInfo *info = sectionInfos[indexPath.row];
        
        [[[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditProject]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             [Util askUserForUniqueNameAndPerformAction:@selector(copyProjectActionForProjectWithName:
                                                                  sourceProjectLoadingInfo:)
                                                 target:self
                                           cancelAction:nil
                                             withObject:info
                                            promptTitle:kLocalizedCopyProject
                                          promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                            promptValue:info.visibleName
                                      promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                         minInputLength:kMinNumOfProjectNameCharacters
                                         maxInputLength:kMaxNumOfProjectNameCharacters
                               invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                          existingNames:[Project allProjectNames]];
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             NSMutableArray *unavailableNames = [[Project allProjectNames] mutableCopy];
             [unavailableNames removeString:info.visibleName];
             [Util askUserForUniqueNameAndPerformAction:@selector(renameProjectActionToName:sourceProjectLoadingInfo:)
                                                 target:self
                                           cancelAction:nil
                                             withObject:info
                                            promptTitle:kLocalizedRenameProject
                                          promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                            promptValue:info.visibleName
                                      promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                         minInputLength:kMinNumOfProjectNameCharacters
                                         maxInputLength:kMaxNumOfProjectNameCharacters
                               invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                          existingNames:unavailableNames];
         }]
         addDefaultActionWithTitle:kLocalizedDescription handler:^{
             Project *project = [Project projectWithLoadingInfo:info];
             ProjectDescriptionViewController *dViewController = [[ProjectDescriptionViewController alloc] init];
             dViewController.delegate = self;
             self.selectedProject = project;
             
             UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dViewController];
             [self.navigationController presentViewController:navigationController animated:YES completion:nil];
         }] build]
         viewWillDisappear:^{
             [self.tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = UIColor.globalTint;
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisProject message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteProjectForIndexPath:indexPath];
         }] build]
         showWithController:self];
    }];
    return @[deleteAction, moreAction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.projectsCounter < 10) {
        return nil;
    }
    return [self.sectionTitles objectAtIndex:section];
}

#pragma mark - table view helpers
- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
    ProjectLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.iconImageView.image = nil;
    cell.indexPath = indexPath;
    [cell setNeedsLayout];
    
    [self.projectManager loadPreviewImageAndCacheWithProjectLoadingInfo:info completion:^(UIImage *image, NSString *path) {
      
        if(image) {
            if ([cell.indexPath isEqual:indexPath]) {
                cell.iconImageView.image = image;
                [cell setNeedsLayout];
                dispatch_queue_main_t queue = dispatch_get_main_queue();
                dispatch_async(queue, ^{
                    [self.tableView endUpdates];
                });
            }
        }
        
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (! self.editing) {
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionInfos = [self.projectLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];

        ProjectLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
        self.selectedProject = [Project projectWithLoadingInfo:info];
        
        if (!self.selectedProject) {
            [Util alertWithText:kLocalizedUnableToLoadProject];
            return;
        }
        
        if (![self.selectedProject.header.programName isEqualToString:info.visibleName]) {
            self.selectedProject.header.programName = info.visibleName;
            [self.selectedProject saveToDiskWithNotification:YES];
        }
        
        [self openProject:self.selectedProject];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.projectsCounter < 10) {
        return nil;
    }
    //    return self.sectionTitles; // only the existing ones
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.sectionTitles indexOfObject:title];
}
#pragma mark - project handling
- (ProjectLoadingInfo*)addProject:(NSString*)projectName
{
    // check if project already exists, then update
    BOOL exists = NO;
    NSMutableArray* projectLoadingInfos = [[Project allProjectLoadingInfos] mutableCopy];
    for (ProjectLoadingInfo *projectLoadingInfo in projectLoadingInfos) {
        if ([projectLoadingInfo.visibleName isEqualToString:projectName])
            exists = YES;
    }
    
    ProjectLoadingInfo *projectLoadingInfo = nil;
    
    // add if not exists
    if (! exists) {
        projectLoadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName
                                                                            projectID:nil];
        NSDebug(@"Adding project: %@", projectLoadingInfo.basePath);
        
        
    }
    [self reloadTableView];
    return projectLoadingInfo;
}

- (void)removeProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    ProjectLoadingInfo *oldProjectLoadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName projectID:projectID];
    NSInteger rowIndex = 0;
    NSMutableArray* projectLoadingInfos = [[Project allProjectLoadingInfos] mutableCopy];
    for (ProjectLoadingInfo *info in projectLoadingInfos) {
        if ([info isEqualToLoadingInfo:oldProjectLoadingInfo]) {
            [Project removeProjectFromDiskWithProjectName:projectName projectID:projectID];
            NSIndexPath* indexPath = [self getPathForProjectLoadingInfo:info];
            
            if ([self.tableView numberOfRowsInSection:indexPath.section] > 1)
            {
                [self setSectionHeaders];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationTop];
            }
            else
            {
                // Section is now completely empty, so delete the entire section.
                [self setSectionHeaders];
                // There should be always one project so don't delete sections of the tableView
                if (self.projectsCounter > 1) {
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                                  withRowAnimation:UITableViewRowAnimationTop];
                }
            }
            // flush cache
            self.dataCache = nil;
            // needed to avoid unexpected behaviour when projects are renamed
            [[RuntimeImageCache sharedImageCache] clearImageCache];
            return;
        }
        ++rowIndex;
    }
}

- (NSIndexPath*)getPathForProjectLoadingInfo:(ProjectLoadingInfo*)info
{
    NSInteger sectionCounter = 0;
    for (NSString* sectionTitle in self.sectionTitles) {
        if ([sectionTitle isEqualToString:[[info.visibleName substringToIndex:1] uppercaseString]]) {
            break;
        }
        sectionCounter++;
    }
    
    NSMutableArray* infosArray = [self.projectLoadingInfoDict objectForKey:[[info.visibleName substringToIndex:1] uppercaseString]];
    NSInteger rowCounter = 0;
    for (ProjectLoadingInfo *projectInfo in infosArray) {
        if ([projectInfo isEqualToLoadingInfo:info]) {
            break;
        }
        rowCounter++;
    }
    
    
    return [NSIndexPath indexPathForRow:rowCounter inSection:sectionCounter];
}

- (void)renameOldProjectWithName:(NSString*)oldProjectName
                       projectID:(NSString*)projectID
                toNewProjectName:(NSString*)newProjectName
{
    ProjectLoadingInfo *oldProjectLoadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:oldProjectName
                                                                                               projectID:projectID];
    NSInteger rowIndex = 0;
    NSMutableArray* projectLoadingInfos = [[Project allProjectLoadingInfos] mutableCopy];
    for (ProjectLoadingInfo *info in projectLoadingInfos) {
        if ([info isEqualToLoadingInfo:oldProjectLoadingInfo]) {
            ProjectLoadingInfo *newInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:newProjectName
                                                                                         projectID:oldProjectLoadingInfo.projectID];
            [projectLoadingInfos replaceObjectAtIndex:rowIndex withObject:newInfo];
            // flush cache
            self.dataCache = nil;
            // needed to avoid unexpected behaviour when renaming projects
            [[RuntimeImageCache sharedImageCache] clearImageCache];
            
            // update table view
            [self.tableView reloadRowsAtIndexPaths:@[[self getPathForProjectLoadingInfo:info]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++rowIndex;
    }
}

#pragma mark - helpers

- (void)setupToolBar
{
    [super setupToolBar];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addProjectAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = @[flex, add, flex];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];

    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmDeleteSelectedProjectsAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: self.selectAllRowsButtonItem, flex, deleteButton, nil];
}

- (void)setSectionHeaders
{
    self.projectLoadingInfoDict = [NSMutableDictionary new];
    self.projectsCounter = 0;
    NSArray* projectLoadingInfos = [[Project allProjectLoadingInfos] mutableCopy];
    for (ProjectLoadingInfo* info in projectLoadingInfos) {
        NSMutableArray* array = [self.projectLoadingInfoDict objectForKey:[[info.visibleName substringToIndex:1] uppercaseString]];
        if (!array.count) {
            array = [NSMutableArray new];
        }
        [array addObject:info];
        [self.projectLoadingInfoDict setObject:array forKey:[[info.visibleName substringToIndex:1] uppercaseString]];
        self.projectsCounter++;
    }
    
    self.sectionTitles = [[self.projectLoadingInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark reload TableView

- (void)reloadTableView
{
    [self setSectionHeaders];
    [self.tableView reloadData];
}

#pragma mark - description delegate
- (void)setDescription:(NSString *)description
{
    [self showLoadingView];
    [self.selectedProject setDescription:description];
    [self.selectedProject saveToDiskWithNotification:NO andCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableView];
            [self hideLoadingView];
            [Util showNotificationForSaveAction];
        });
    }];
}



@end
