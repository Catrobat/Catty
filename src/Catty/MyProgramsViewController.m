/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "Program.h"
#import "ProgramTableViewController.h"
#import "AppDelegate.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "CatrobatImageCell.h"
#import "Logger.h"
#import "SegueDefines.h"
#import "ProgramUpdateDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "Program.h"
#import "UIDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "NSDate+CustomExtensions.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "CatrobatActionSheet.h"
#import "CatrobatAlertView.h"
#import "DataTransferMessage.h"
#import "NSMutableArray+CustomExtensions.h"
#import "UIDefines.h"

@interface MyProgramsViewController () <CatrobatActionSheetDelegate, ProgramUpdateDelegate,
                                        CatrobatAlertViewDelegate, UITextFieldDelegate,
                                        SWTableViewCellDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, strong) NSMutableArray *programLoadingInfos;
@property (nonatomic, strong) Program *selectedProgram;
@property (nonatomic, strong) Program *defaultProgram;
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
    self.programLoadingInfos = [[Program allProgramLoadingInfos] mutableCopy];
    [self initNavigationBar];

    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFinished:)
                                                 name:kProgramDownloadedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.defaultProgram = nil;
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
    self.programLoadingInfos = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    if (self.useDetailCells) {
        [options addObject:kLocalizedHideDetails];
    } else {
        [options addObject:kLocalizedShowDetails];
    }
    if ([self.programLoadingInfos count]) {
        [options addObject:kLocalizedDeletePrograms];
    }
    [Util actionSheetWithTitle:kLocalizedEditPrograms
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditProgramsActionSheetTag
                          view:self.navigationController.view];
}

- (void)addProgramAction:(id)sender
{
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
                                 existingNames:[Program allProgramNames]];
}

- (void)addProgramAndSegueToItActionForProgramWithName:(NSString*)programName
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    programName = [Util uniqueName:programName existingNames:[Program allProgramNames]];
    self.defaultProgram = [Program defaultProgramWithName:programName];
    if ([self shouldPerformSegueWithIdentifier:segueToNewProgramIdentifier sender:self]) {
        [self addProgram:self.defaultProgram.header.programName];
        [self performSegueWithIdentifier:segueToNewProgramIdentifier sender:self];
    }
}

- (void)copyProgramActionForProgramWithName:(NSString*)programName
                   sourceProgramLoadingInfo:(ProgramLoadingInfo*)sourceProgramLoadingInfo
{
    programName = [Util uniqueName:programName existingNames:[Program allProgramNames]];
    ProgramLoadingInfo *destinationProgramLoadingInfo = [self addProgram:programName];
    if (! destinationProgramLoadingInfo)
        return;

    [self showLoadingView];
    [Program copyProgramWithName:sourceProgramLoadingInfo.visibleName destinationProgramName:programName];
    [self.dataCache removeObjectForKey:destinationProgramLoadingInfo.visibleName];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)renameProgramActionToName:(NSString*)newProgramName
         sourceProgramLoadingInfo:(ProgramLoadingInfo*)programLoadingInfo
{
    if ([newProgramName isEqualToString:programLoadingInfo.visibleName])
        return;

    [self showLoadingView];
    Program *program = [Program programWithLoadingInfo:programLoadingInfo];
    newProgramName = [Util uniqueName:newProgramName existingNames:[Program allProgramNames]];
    [program renameToProgramName:newProgramName];
    [self renameOldProgramName:programLoadingInfo.visibleName toNewProgramName:program.header.programName];
}

- (void)updateProgramDescriptionActionWithText:(NSString*)descriptionText
                                 sourceProgram:(Program*)program
{
    [self showLoadingView];
    [program updateDescriptionWithText:descriptionText];
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
    NSMutableArray *programNamesToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:selectedRowIndexPath.row];
        [programNamesToRemove addObject:programLoadingInfo.visibleName];
    }
    for (NSString *programNameToRemove in programNamesToRemove) {
        [self removeProgram:programNameToRemove];
    }
    [self hideLoadingView];
    [super exitEditingMode];
}

- (void)deleteProgramForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:indexPath.row];
    [self removeProgram:programLoadingInfo.visibleName];
    [self hideLoadingView];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programLoadingInfos count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    static NSString *DetailCellIdentifier = kDetailImageCell;
    UITableViewCell *cell = nil;
    if (! self.useDetailCells) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    }
    if (! [cell isKindOfClass:[CatrobatBaseCell class]] || ! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }

    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    [self configureImageCell:imageCell atIndexPath:indexPath];
    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLastAccess];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];

        ProgramLoadingInfo *info = [self.programLoadingInfos objectAtIndex:indexPath.row];
        NSNumber *programSize = [self.dataCache objectForKey:info.visibleName];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
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
        return detailCell;
    }
    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}

#pragma mark - table view helpers
- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *info = [self.programLoadingInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.rightUtilityButtons = @[[Util slideViewButtonMore], [Util slideViewButtonDelete]];
    cell.delegate = self;
    cell.iconImageView.image = nil;
    cell.indexPath = indexPath;
    [cell.iconImageView setBorder:[UIColor skyBlueColor] Width:kDefaultImageCellBorderWidth];

    // check if one of these screenshot files is available in memory
    FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    NSArray *fallbackPaths = @[[[NSString alloc] initWithFormat:@"%@small_screenshot.png", info.basePath],
                               [[NSString alloc] initWithFormat:@"%@screenshot.png", info.basePath],
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
                                                           onCompletion:^(UIImage *image){
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
    static NSString *segueToContinue = kSegueToContinue;
    if (! self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self shouldPerformSegueWithIdentifier:segueToContinue sender:cell]) {
            [self performSegueWithIdentifier:segueToContinue sender:cell];
        }
    }
}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.editing) {
        return NO;
    }

    static NSString *segueToContinue = kSegueToContinue;
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([identifier isEqualToString:segueToContinue]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *path = [self.tableView indexPathForCell:sender];
            // check if program loaded successfully -> not nil
            self.selectedProgram = [Program programWithLoadingInfo:[self.programLoadingInfos objectAtIndex:path.row]];
            if (self.selectedProgram) {
                return YES;
            }

            // program failed loading...
            [Util alertWithText:kLocalizedUnableToLoadProgram];
            return NO;
        }
    } else if ([identifier isEqualToString:segueToNewProgram]) {
        if (! self.defaultProgram) {
            return NO;
        }
        return YES;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    static NSString *segueToContinue = kSegueToContinue;
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([segue.identifier isEqualToString:segueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                [self.dataCache removeObjectForKey:self.selectedProgram.header.programName];
                ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
                programTableViewController.delegate = self;
                programTableViewController.program = self.selectedProgram;
            }
        }
    } else if ([segue.identifier isEqualToString:segueToNewProgram]) {
        ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
        programTableViewController.delegate = self;
        programTableViewController.program = self.defaultProgram;
    }
}

#pragma mark - swipe delegates
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        // More button was pressed
        NSArray *options = @[kLocalizedCopy, kLocalizedRename,
                             kLocalizedDescription/*, kLocalizedUpload*/];
#if kIsFirstRelease // kIsFirstRelease
        CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kLocalizedThisFeatureIsComingSoon
                                                             delegate:self
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:options
                                                                  tag:kEditProgramActionSheetTag
                                                                 view:self.navigationController.view];
        // disable all buttons except cancel button (index of cancel button: ([actionSheet.buttons count] - 1))
        for (IBActionSheetButton *button in actionSheet.buttons) {
            if (button.index != ([actionSheet.buttons count] - 1)) {
                button.enabled = NO;
                [actionSheet setButtonTextColor:[UIColor grayColor] forButtonAtIndex:button.index];
            }
        }
#else // kIsFirstRelease
        CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kLocalizedEditProgram
                                                             delegate:self
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:options
                                                                  tag:kEditProgramActionSheetTag
                                                                 view:self.navigationController.view];
#endif // kIsFirstRelease
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *payload = @{ kDTPayloadProgramLoadingInfo : [self.programLoadingInfos objectAtIndex:indexPath.row] };
        DataTransferMessage *message = [DataTransferMessage messageForActionType:kDTMActionEditProgram
                                                                     withPayload:[payload mutableCopy]];
        actionSheet.dataTransferMessage = message;
    } else if (index == 1) {
        // Delete button was pressed
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self performActionOnConfirmation:@selector(deleteProgramForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kLocalizedDeleteThisProgram
                           confirmMessage:kLocalizedThisActionCannotBeUndone];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - action sheet delegates
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kEditProgramsActionSheetTag) {
        if (buttonIndex == 0) {
            // Show/Hide Details button
            self.useDetailCells = (! self.useDetailCells);
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
            [self.tableView reloadData];
        } else if ((buttonIndex == 1) && [self.programLoadingInfos count]) {
            // Delete Programs button
            [self setupEditingToolBar];
            [super changeToEditingMode:actionSheet];
        }
    } else if (actionSheet.tag == kEditProgramActionSheetTag) {
        if (buttonIndex == 0) {
            // Copy button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            ProgramLoadingInfo *info = (ProgramLoadingInfo*)payload[kDTPayloadProgramLoadingInfo];
            [Util askUserForUniqueNameAndPerformAction:@selector(copyProgramActionForProgramWithName:sourceProgramLoadingInfo:)
                                                target:self
                                            withObject:info
                                           promptTitle:kLocalizedCopyProgram
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                           promptValue:info.visibleName
                                     promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                        minInputLength:kMinNumOfProgramNameCharacters
                                        maxInputLength:kMaxNumOfProgramNameCharacters
                                   blockedCharacterSet:[self blockedCharacterSet]
                              invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                         existingNames:[Program allProgramNames]];
        } else if (buttonIndex == 1) {
            // Rename button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            ProgramLoadingInfo *info = (ProgramLoadingInfo*)payload[kDTPayloadProgramLoadingInfo];
            NSMutableArray *unavailableNames = [[Program allProgramNames] mutableCopy];
            [unavailableNames removeString:info.visibleName];
            [Util askUserForUniqueNameAndPerformAction:@selector(renameProgramActionToName:sourceProgramLoadingInfo:)
                                                target:self
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
        } else if (buttonIndex == 2) {
            // Description button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            ProgramLoadingInfo *info = (ProgramLoadingInfo*)payload[kDTPayloadProgramLoadingInfo];
            Program *program = [Program programWithLoadingInfo:info];
            [Util askUserForTextAndPerformAction:@selector(updateProgramDescriptionActionWithText:sourceProgram:)
                                          target:self
                                      withObject:program
                                     promptTitle:kLocalizedSetDescription
                                   promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedDescription]
                                     promptValue:program.header.description
                               promptPlaceholder:kLocalizedEnterYourProgramDescriptionHere
                                  minInputLength:kMinNumOfProgramDescriptionCharacters
                                  maxInputLength:kMaxNumOfProgramDescriptionCharacters
                             blockedCharacterSet:[self blockedCharacterSet]
                        invalidInputAlertMessage:kLocalizedInvalidDescriptionDescription];
//        } else if (buttonIndex == 3) {
//            // Upload button
        }
    }
}

#pragma mark - program handling
- (ProgramLoadingInfo*)addProgram:(NSString*)programName
{
    NSString *basePath = [Program basePath];

    // check if program already exists, then update
    BOOL exists = NO;
    for (ProgramLoadingInfo *programLoadingInfo in self.programLoadingInfos) {
        if ([programLoadingInfo.visibleName isEqualToString:programName])
            exists = YES;
    }

    ProgramLoadingInfo *programLoadingInfo = nil;

    // add if not exists
    if (! exists) {
        programLoadingInfo = [[ProgramLoadingInfo alloc] init];
        programLoadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", basePath, programName];
        programLoadingInfo.visibleName = programName;
        NSLog(@"Adding program: %@", programLoadingInfo.basePath);
        [self.programLoadingInfos addObject:programLoadingInfo];

        // create new cell
        NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    return programLoadingInfo;
}

- (void)removeProgram:(NSString*)programName
{
    NSInteger rowIndex = 0;
    for (ProgramLoadingInfo *info in self.programLoadingInfos) {
        if ([info.visibleName isEqualToString:programName]) {
            [Program removeProgramFromDiskWithProgramName:programName];
            [self.programLoadingInfos removeObjectAtIndex:rowIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            // flush asset/image cache
            self.dataCache = nil;
            // needed to avoid unexpected behaviour when programs are renamed
            [[RuntimeImageCache sharedImageCache] clearImageCache];
            break;
        }
        ++rowIndex;
    }
    // if last program was removed [programLoadingInfos count] returns 0,
    // then default program was automatically recreated, therefore reload
    if (! [self.programLoadingInfos count]) {
        self.programLoadingInfos = [[Program allProgramLoadingInfos] mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)renameOldProgramName:(NSString*)oldProgramName toNewProgramName:(NSString*)newProgramName
{
    NSInteger rowIndex = 0;
    for (ProgramLoadingInfo *info in self.programLoadingInfos) {
        if ([info.visibleName isEqualToString:oldProgramName]) {
            ProgramLoadingInfo *newInfo = [[ProgramLoadingInfo alloc] init];
            newInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], newProgramName];
            newInfo.visibleName = newProgramName;
            [self.programLoadingInfos replaceObjectAtIndex:rowIndex withObject:newInfo];

            // flush asset/image cache
            self.dataCache = nil;
            // needed to avoid unexpected behaviour when renaming programs
            [[RuntimeImageCache sharedImageCache] clearImageCache];

            // update table view
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++rowIndex;
    }
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
#if kIsFirstRelease // kIsFirstRelease
    add.enabled = NO;
#endif // kIsFirstRelease
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

#pragma mark Filemanager notification
- (void)downloadFinished:(NSNotification*)notification
{
    if ([[notification name] isEqualToString:kProgramDownloadedNotification]){
        self.programLoadingInfos = [[Program allProgramLoadingInfos] mutableCopy];
        [self.tableView reloadData];
    }
}

@end
