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

#import "MyProgramsViewController.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "ObjectListViewController.h"
#import "SceneListViewController.h"
#import "AppDelegate.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "CatrobatImageCell.h"
#import "SegueDefines.h"
#import "ProgramUpdateDelegate.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "NSDate+CustomExtensions.h"
#import "RuntimeImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "NSMutableArray+CustomExtensions.h"
#import "UIUtil.h"
#import "DescriptionViewController.h"
#import "Pocket_Code-Swift.h"
#import "ProgramManager.h"

@interface MyProgramsViewController () <ProgramUpdateDelegate, UITextFieldDelegate, SetDescriptionDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic) NSInteger programsCounter;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSMutableDictionary *programLoadingInfoDict;
@end

@implementation MyProgramsViewController

#pragma mark - data helpers
static NSCharacterSet *blockedCharacterSet = nil;
- (NSCharacterSet*)blockedCharacterSet
{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
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
    NSNumber *showDetailsProgramsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsProgramsKey];
    self.useDetailCells = [showDetailsProgramsValue boolValue];
    self.navigationController.title = self.title = kLocalizedPrograms;
    [self initNavigationBar];
    self.selectedProgram = nil;
    [self setupToolBar];
    
    [self setSectionHeaders];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.sectionIndexBackgroundColor = [UIColor backgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name:kProgramDownloadedNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedProgram = nil;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView reloadData];
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
    
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditPrograms]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    
    if (self.programsCounter) {
        [actionSheet addDestructiveActionWithTitle:kLocalizedDeletePrograms handler:^{
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
                           forKey:kUserDetailsShowDetailsProgramsKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self reloadTableView];
}

- (void)addProgramAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    [Util askUserForUniqueNameAndPerformAction:@selector(addProgramAndSegueToItActionForProgramWithName:)
                                        target:self
                                   promptTitle:kLocalizedNewProgram
                                 promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                minInputLength:kMinNumOfProgramNameCharacters
                                maxInputLength:kMaxNumOfProgramNameCharacters
                           blockedCharacterSet:[self blockedCharacterSet]
                      invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                 existingNames:[self allProgramNames]];
}

- (NSArray<NSString *> *)allProgramNames {
    return [[ProgramManager instance] allProgramNames];
}

- (void)addProgramAndSegueToItActionForProgramWithName:(NSString*)programName
{
    NSParameterAssert(![[self allProgramNames] containsObject:programName]);
    
    Program *newProgram = [Program defaultProgramWithName:programName];
    ProgramLoadingInfo *newProgramLaodingInfo = [[ProgramManager instance] addProgram:newProgram];
    
    [self segueToProgramWithLoadingInfo:newProgramLaodingInfo];
}

- (void)segueToProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    self.selectedProgram = [[ProgramManager instance] programWithLoadingInfo:programLoadingInfo];
    
    NSString *segueIdentifier = self.selectedProgram.scenes.count > 1 ? kSegueToSceneList : kSegueToObjectList;
    
    if ([self shouldPerformSegueWithIdentifier:segueIdentifier sender:self]) {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

- (void)copyProgramActionForProgramWithName:(NSString*)programName
                   sourceProgramLoadingInfo:(ProgramLoadingInfo*)sourceProgramLoadingInfo
{
    programName = [Util uniqueName:programName existingNames:[self allProgramNames]];
    ProgramLoadingInfo *destinationProgramLoadingInfo = [[ProgramManager instance] copyProgramWithLoadingInfo:sourceProgramLoadingInfo
                                                                                       destinationProgramName:programName];
    
    [self showLoadingView];
    [self.dataCache removeObjectForKey:destinationProgramLoadingInfo.visibleName];
    NSIndexPath* indexPath = [self getPathForProgramLoadingInfo:destinationProgramLoadingInfo];
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

- (void)renameProgramActionToName:(NSString*)newProgramName
         sourceProgramLoadingInfo:(ProgramLoadingInfo*)programLoadingInfo
{
    if ([newProgramName isEqualToString:programLoadingInfo.visibleName])
        return;
    
    [self showLoadingView];
    
    newProgramName = [Util uniqueName:newProgramName existingNames:[self allProgramNames]];
    Program *program = [[ProgramManager instance] programWithLoadingInfo:programLoadingInfo];
    [self renameOldProgram:program toNewProgramName:newProgramName];
    
    [self reloadTableView];
    [self hideLoadingView];
}

- (void)updateProgramDescriptionActionWithText:(NSString*)descriptionText
                                 sourceProgram:(Program*)program
{
    [self showLoadingView];
    program.programDescription = descriptionText;
    [self reloadTableView];
    [self hideLoadingView];
}

- (void)confirmDeleteSelectedProgramsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedProgramsAction];
}

- (void)deleteSelectedProgramsAction
{
    [self showLoadingView];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *programLoadingInfosToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:selectedRowIndexPath.section];
        NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProgramLoadingInfo *info = [sectionInfos objectAtIndex:selectedRowIndexPath.row];
        [programLoadingInfosToRemove addObject:info];
    }
    for (ProgramLoadingInfo *programLoadingInfoToRemove in programLoadingInfosToRemove) {
        [self removeProgramWithLoadingInfo:programLoadingInfoToRemove];
    }
    [self hideLoadingView];
    [super exitEditingMode];
}

- (void)deleteProgramForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
    ProgramLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
    [self removeProgramWithLoadingInfo:info];
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
    NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
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
        detailCell.topLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLastAccess];
        detailCell.topRightDetailLabel.textColor = [UIColor textTintColor];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = [UIColor textTintColor];
        detailCell.topRightDetailLabel.text = [kLocalizedLoading stringByAppendingString:@"..."];
        detailCell.bottomRightDetailLabel.text = [kLocalizedLoading stringByAppendingString:@"..."];
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProgramLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
        NSNumber *programSize = [self.dataCache objectForKey:info.visibleName];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if (programSize) {
            NSString *xmlPath = [NSString stringWithFormat:@"%@/%@", info.basePath, kProgramCodeFileName];
            NSDate *lastAccessDate = [appDelegate.fileManager lastModificationTimeOfFile:xmlPath];
            detailCell.topRightDetailLabel.text = [lastAccessDate humanFriendlyFormattedString];
            detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[programSize unsignedIntegerValue]
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
            NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
            ProgramLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
            NSNumber *programSize = [self.dataCache objectForKey:info.visibleName];
            if (! programSize) {
                NSUInteger resultSize = [appDelegate.fileManager sizeOfDirectoryAtPath:info.basePath];
                programSize = [NSNumber numberWithUnsignedInteger:resultSize];
                [self.dataCache setObject:programSize forKey:info.visibleName];
            }
            
            NSString *xmlPath = [NSString stringWithFormat:@"%@/%@", info.basePath, kProgramCodeFileName];
            NSDate *lastAccessDate = [appDelegate.fileManager lastModificationTimeOfFile:xmlPath];
            detailCell.topRightDetailLabel.text = [lastAccessDate humanFriendlyFormattedString];
            detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[programSize unsignedIntegerValue]
                                                                                    countStyle:NSByteCountFormatterCountStyleBinary];
            dispatch_async(dispatch_get_main_queue(), ^{
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
        NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProgramLoadingInfo *info = sectionInfos[indexPath.row];
        
        [[[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditProgram]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             [Util askUserForUniqueNameAndPerformAction:@selector(copyProgramActionForProgramWithName:
                                                                  sourceProgramLoadingInfo:)
                                                 target:self
                                           cancelAction:nil
                                             withObject:info
                                            promptTitle:kLocalizedCopyProgram
                                          promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                            promptValue:info.visibleName
                                      promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                         minInputLength:kMinNumOfProgramNameCharacters
                                         maxInputLength:kMaxNumOfProgramNameCharacters
                                    blockedCharacterSet:[self blockedCharacterSet]
                               invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                          existingNames:[self allProgramNames]];
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             NSMutableArray *unavailableNames = [[self allProgramNames] mutableCopy];
             [unavailableNames removeString:info.visibleName];
             [Util askUserForUniqueNameAndPerformAction:@selector(renameProgramActionToName:sourceProgramLoadingInfo:)
                                                 target:self
                                           cancelAction:nil
                                             withObject:info
                                            promptTitle:kLocalizedRenameProgram
                                          promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                            promptValue:info.visibleName
                                      promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                         minInputLength:kMinNumOfProgramNameCharacters
                                         maxInputLength:kMaxNumOfProgramNameCharacters
                                    blockedCharacterSet:[self blockedCharacterSet]
                               invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                          existingNames:unavailableNames];
         }]
         addDefaultActionWithTitle:kLocalizedDescription handler:^{
             Program *program = [[ProgramManager instance] programWithLoadingInfo:info];
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
             DescriptionViewController * dViewController = [storyboard instantiateViewControllerWithIdentifier:@"DescriptionViewController"];
             dViewController.delegate = self;
             self.selectedProgram = program;
             [self.navigationController presentViewController:dViewController animated:YES completion:nil];
         }] build]
         viewWillDisappear:^{
             [self.tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = [UIColor globalTintColor];
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisProgram message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteProgramForIndexPath:indexPath];
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
    if (self.programsCounter < 10) {
        return nil;
    }
    return [self.sectionTitles objectAtIndex:section];
}

#pragma mark - table view helpers
- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
    ProgramLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.iconImageView.image = nil;
    cell.indexPath = indexPath;
    [cell.iconImageView setBorder:[UIColor utilityTintColor] Width:kDefaultImageCellBorderWidth];
    
    // check if one of these screenshot files is available in memory
    FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    NSArray *fallbackPaths = @[[[NSString alloc] initWithFormat:@"%@screenshot.png", info.basePath],
                               [[NSString alloc] initWithFormat:@"%@manual_screenshot.png", info.basePath],
                               [[NSString alloc] initWithFormat:@"%@automatic_screenshot.png", info.basePath]];
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    for (NSString *fallbackPath in fallbackPaths) {
        NSString *fileName = [fallbackPath lastPathComponent];
        NSString *thumbnailPath = [NSString stringWithFormat:@"%@%@%@",
                                   info.basePath, kScreenshotThumbnailPrefix, fileName];
        UIImage *image = [imageCache cachedImageForPath:thumbnailPath];
        if (image) {
            cell.iconImageView.image = image;
            return;
        }
    }
    
    // no screenshot files in memory, check if one of these screenshot files exists on disk
    // if a screenshot file is found, then load it from disk and cache it in memory for future access
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        for (NSString *fallbackPath in fallbackPaths) {
            if ([fileManager fileExists:fallbackPath]) {
                NSString *fileName = [fallbackPath lastPathComponent];
                NSString *thumbnailPath = [NSString stringWithFormat:@"%@%@%@",
                                           info.basePath, kScreenshotThumbnailPrefix, fileName];
                [imageCache loadThumbnailImageFromDiskWithThumbnailPath:thumbnailPath
                                                              imagePath:fallbackPath
                                                     thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)
                                                           onCompletion:^(UIImage *image, NSString* path){
                                                               // check if cell still needed
                                                               if ([cell.indexPath isEqual:indexPath]) {
                                                                   cell.iconImageView.image = image;
                                                                   [cell setNeedsLayout];
                                                                   [self.tableView endUpdates];
                                                               }
                                                           }];
                return;
            }
        }
        
        // no screenshot file available -> last fallback, show standard program icon instead
        [imageCache loadImageWithName:@"programs" onCompletion:^(UIImage *image){
            // check if cell still needed
            if ([cell.indexPath isEqual:indexPath]) {
                cell.iconImageView.image = image;
                [cell setNeedsLayout];
                [self.tableView endUpdates];
            }
        }];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (! self.editing) {
        NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionInfos = [self.programLoadingInfoDict objectForKey:[[sectionTitle substringToIndex:1] uppercaseString]];
        ProgramLoadingInfo *info = [sectionInfos objectAtIndex:indexPath.row];

        [self segueToProgramWithLoadingInfo:info];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.programsCounter < 10) {
        return nil;
    }
    //    return self.sectionTitles; // only the existing ones
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.sectionTitles indexOfObject:title];
}
#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.editing) {
        return NO;
    }
    
    if ([identifier isEqualToString:kSegueToSceneList] || [identifier isEqualToString:kSegueToObjectList]) {
        if (self.selectedProgram) {
            return YES;
        }
            
        // program failed loading...
        [Util alertWithText:kLocalizedUnableToLoadProgram];
        return NO;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSAssert(self.selectedProgram, @"Program should be already selected");
    
    if ([segue.identifier isEqualToString:kSegueToSceneList]) {
        SceneListViewController *sceneListViewController = (SceneListViewController *)segue.destinationViewController;
        NSAssert(sceneListViewController != nil, @"");
        
        [self.dataCache removeObjectForKey:self.selectedProgram.programName];
        sceneListViewController.delegate = self;
        sceneListViewController.program = self.selectedProgram;
    } else if ([segue.identifier isEqualToString:kSegueToObjectList]) {
        ObjectListViewController *objectListViewController = (ObjectListViewController *)segue.destinationViewController;
        NSAssert(objectListViewController != nil, @"");
        
        objectListViewController.delegate = self;
        objectListViewController.scene = self.selectedProgram.scenes.firstObject;
        objectListViewController.shouldBehaveAsIfObjectsBelongToProgram = YES;
    } else {
        NSAssert(false, @"Unreachable");
    }
}

#pragma mark - program handling

- (void)removeProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo
{
    [[ProgramManager instance] removeProgramWithLoadingInfo:programLoadingInfo];
    NSIndexPath* indexPath = [self getPathForProgramLoadingInfo:programLoadingInfo];
            
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
        // There should be always one program so don't delete sections of the tableView
        if (self.programsCounter > 1) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                          withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    // flush cache
    self.dataCache = nil;
    // needed to avoid unexpected behaviour when programs are renamed
    [[RuntimeImageCache sharedImageCache] clearImageCache];
    [self reloadTableView];
}

- (NSIndexPath*)getPathForProgramLoadingInfo:(ProgramLoadingInfo*)info
{
    NSInteger sectionCounter = 0;
    for (NSString* sectionTitle in self.sectionTitles) {
        if ([sectionTitle isEqualToString:[[info.visibleName substringToIndex:1] uppercaseString]]) {
            break;
        }
        sectionCounter++;
    }
    
    NSMutableArray* infosArray = [self.programLoadingInfoDict objectForKey:[[info.visibleName substringToIndex:1] uppercaseString]];
    NSInteger rowCounter = 0;
    for (ProgramLoadingInfo *programInfo in infosArray) {
        if ([programInfo isEqualToLoadingInfo:info]) {
            break;
        }
        rowCounter++;
    }
    
    
    return [NSIndexPath indexPathForRow:rowCounter inSection:sectionCounter];
}

- (void)renameOldProgram:(Program *)program toNewProgramName:(NSString *)newProgramName {
    ProgramLoadingInfo *oldLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    [[ProgramManager instance] renameProgram:program toName:newProgramName];
    
    // flush cache
    self.dataCache = nil;
    // needed to avoid unexpected behaviour when renaming programs
    [[RuntimeImageCache sharedImageCache] clearImageCache];
    
    
    // update table view
    [self.tableView reloadRowsAtIndexPaths:@[[self getPathForProgramLoadingInfo:oldLoadingInfo]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - helpers
- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addProgramAction:)];
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
                                                                    action:@selector(confirmDeleteSelectedProgramsAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}

- (void)setSectionHeaders
{
    self.programLoadingInfoDict = [NSMutableDictionary new];
    self.programsCounter = 0;
    NSArray* programLoadingInfos = [[ProgramManager instance] allProgramLoadingInfos];
    for (ProgramLoadingInfo* info in programLoadingInfos) {
        NSMutableArray* array = [self.programLoadingInfoDict objectForKey:[[info.visibleName substringToIndex:1] uppercaseString]];
        if (!array.count) {
            array = [NSMutableArray new];
        }
        [array addObject:info];
        [self.programLoadingInfoDict setObject:array forKey:[[info.visibleName substringToIndex:1] uppercaseString]];
        self.programsCounter++;
    }
    
    self.sectionTitles = [[self.programLoadingInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark Filemanager notification
- (void)downloadFinished:(NSNotification*)notification
{
    if ([[notification name] isEqualToString:kProgramDownloadedNotification]){
        [self reloadTableView];
        
    }
}

#pragma mark reload TableView

- (void)reloadTableView
{
    [self setSectionHeaders];
    [self.tableView reloadData];
}

#pragma mark - description delegate

-(void) setDescription:(NSString *)description
{
    [self updateProgramDescriptionActionWithText:description sourceProgram:self.selectedProgram];
}



@end
