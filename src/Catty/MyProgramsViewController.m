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

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsProgramsKey @"detailsForPrograms"
#define kScreenshotThumbnailPrefix @".thumb_"

@interface MyProgramsViewController () <CatrobatActionSheetDelegate, ProgramUpdateDelegate,
                                        UIAlertViewDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
@property (nonatomic, strong) NSCharacterSet *blockedCharacterSet;
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, strong) NSMutableDictionary *dataCache;
@property (nonatomic, strong) NSMutableArray *programLoadingInfos;
@property (nonatomic, strong) Program *selectedProgram;
@property (nonatomic, strong) Program *defaultProgram;
@end

@implementation MyProgramsViewController

#pragma mark - getters and setters
- (NSCharacterSet*)blockedCharacterSet
{
    if (! _blockedCharacterSet) {
        _blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters] invertedSet];
    }
    return _blockedCharacterSet;
}

- (NSMutableDictionary*)dataCache
{
    if (! _dataCache) {
        _dataCache = [NSMutableDictionary dictionaryWithCapacity:[self.programLoadingInfos count]];
    }
    return _dataCache;
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
    self.navigationController.title = self.title = kUIViewControllerTitlePrograms;
    [self loadPrograms];
    [self initNavigationBar];

    self.dataCache = nil;
    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView reloadData];
}

#pragma mark - system events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.dataCache = nil;
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.programLoadingInfos = nil;
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    if (self.useDetailCells) {
        [options addObject:kUIActionSheetButtonTitleHideDetails];
    } else {
        [options addObject:kUIActionSheetButtonTitleShowDetails];
    }
    if ([self.programLoadingInfos count]) {
        [options addObject:kUIActionSheetButtonTitleDeletePrograms];
    }
    [Util actionSheetWithTitle:kUIActionSheetTitleEditProgramPlural
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditProgramsActionSheetTag
                          view:self.navigationController.view];
}

- (void)addProgramAction:(id)sender
{
    static NSString *segueToNewProgram = kSegueToNewProgram;
    if ([self shouldPerformSegueWithIdentifier:segueToNewProgram sender:self]) {
        [self performSegueWithIdentifier:segueToNewProgram sender:sender];
    }
}

- (void)confirmDeleteSelectedProgramsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self performActionOnConfirmation:@selector(deleteSelectedProgramsAction)
                       canceledAction:@selector(exitEditingMode)
                               target:self
                         confirmTitle:(([selectedRowsIndexPaths count] != 1)
                                       ? kUIAlertViewTitleDeleteMultiplePrograms
                                       : kUIAlertViewTitleDeleteSingleProgram)
                       confirmMessage:kUIAlertViewMessageIrreversibleAction];
}

- (void)deleteSelectedProgramsAction
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *programNamesToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:selectedRowIndexPath.row];
        [programNamesToRemove addObject:programLoadingInfo.visibleName];
    }
    for (NSString *programNameToRemove in programNamesToRemove) {
        [self removeProgram:programNameToRemove];
    }
    [super exitEditingMode];
}

- (void)deleteProgramForIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:indexPath.row];
    [self removeProgram:programLoadingInfo.visibleName];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextLastAccess];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextSize];
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
            [Util alertWithText:kUIAlertViewMessageUnableToLoadProgram];
            return NO;
        }
    } else if ([identifier isEqualToString:segueToNewProgram]) {
        // if there is no program name, abort performing this segue and ask user for program name
        // after user entered a valid program name this segue will be called again and accepted
        if (! self.defaultProgram) {
            [Util promptWithTitle:kUIAlertViewTitleNewProgram
                          message:[NSString stringWithFormat:@"%@:", kUIAlertViewMessageProgramName]
                         delegate:self
                      placeholder:kUIAlertViewPlaceholderEnterProgramName
                              tag:kNewProgramAlertViewTag
                textFieldDelegate:self];
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

                // TODO: remove this after persisting programs feature is fully implemented...
                programTableViewController.isNewProgram = NO;
            }
        }
    } else if ([segue.identifier isEqualToString:segueToNewProgram]) {
        ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
        programTableViewController.delegate = self;
        programTableViewController.program = self.defaultProgram;

        // TODO: remove this after persisting programs feature is fully implemented...
        programTableViewController.isNewProgram = YES;
    }
}

#pragma mark - swipe delegates
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        // More button was pressed
        NSArray *options = @[kUIActionSheetButtonTitleCopy, kUIActionSheetButtonTitleRename,
                             kUIActionSheetButtonTitleDescription, kUIActionSheetButtonTitleUpload];
        [Util actionSheetWithTitle:kUIActionSheetTitleEditProgramSingular
                          delegate:self
            destructiveButtonTitle:nil
                 otherButtonTitles:options
                               tag:kEditProgramActionSheetTag
                              view:self.navigationController.view];
    } else if (index == 1) {
        // Delete button was pressed
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self performActionOnConfirmation:@selector(deleteProgramForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kUIAlertViewTitleDeleteSingleProgram
                           confirmMessage:kUIAlertViewMessageIrreversibleAction];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - text field delegates
- (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)characters
{
    if ([characters length] > kMaxNumOfProgramNameCharacters) {
        return false;
    }
    return ([characters rangeOfCharacterFromSet:self.blockedCharacterSet].location == NSNotFound);
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
            
        } else if (buttonIndex == 1) {
            // Rename button
        } else if (buttonIndex == 2) {
            // Description button
        } else if (buttonIndex == 3) {
            // Upload button
        }
    }
}

#pragma mark - alert view handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    if (alertView.tag == kNewProgramAlertViewTag) {
        NSString *input = [alertView textFieldAtIndex:0].text;
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }
        kProgramNameValidationResult validationResult = [Program validateProgramName:input];
        if (validationResult == kProgramNameValidationResultInvalid) {
            [Util alertWithText:kUIAlertViewMessageInvalidProgramName
                       delegate:self
                            tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultAlreadyExists) {
            [Util alertWithText:kUIAlertViewMessageProgramNameAlreadyExists
                       delegate:self
                            tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultOK) {
            self.defaultProgram = [Program defaultProgramWithName:input];
            if ([self shouldPerformSegueWithIdentifier:segueToNewProgramIdentifier sender:self]) {
                [self addProgram:input];
                [self performSegueWithIdentifier:segueToNewProgramIdentifier sender:self];
            }
        }
    } else if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == alertView.cancelButtonIndex) {
            [Util promptWithTitle:kUIAlertViewTitleNewProgram
                          message:kUIAlertViewMessageProgramName
                         delegate:self
                      placeholder:kUIAlertViewPlaceholderEnterProgramName
                              tag:kNewProgramAlertViewTag
                textFieldDelegate:self];
        }
    } else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - program handling
- (void)loadPrograms
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *programLoadingInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    self.programLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[programLoadingInfos count]];
    for (NSString *programLoadingInfo in programLoadingInfos) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([programLoadingInfo isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
        info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, programLoadingInfo];
        info.visibleName = programLoadingInfo;
        NSDebug(@"Adding loaded program: %@", info.basePath);
        [self.programLoadingInfos addObject:info];
    }
}

- (void)addProgram:(NSString*)programName
{
    NSString *basePath = [Program basePath];

    // check if program already exists, then update
    BOOL exists = NO;
    for (ProgramLoadingInfo *programLoadingInfo in self.programLoadingInfos) {
        if ([programLoadingInfo.visibleName isEqualToString:programName])
            exists = YES;
    }
    // add if not exists
    if (! exists) {
        ProgramLoadingInfo *programLoadingInfo = [[ProgramLoadingInfo alloc] init];
        programLoadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", basePath, programName];
        programLoadingInfo.visibleName = programName;
        NSLog(@"Adding program: %@", programLoadingInfo.basePath);
        [self.programLoadingInfos addObject:programLoadingInfo];

        // create new cell
        NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)removeProgram:(NSString*)programName
{
    NSInteger rowIndex = 0;
    for (ProgramLoadingInfo *info in self.programLoadingInfos) {
        if ([info.visibleName isEqualToString:programName]) {
            [Program removeProgramFromDiskWithProgramName:programName];
            [self.programLoadingInfos removeObjectAtIndex:rowIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // flush asset/image cache
            self.dataCache = nil;
            // needed to avoid unexpected behaviour when renaming programs
            [[RuntimeImageCache sharedImageCache] clearImageCache];
            break;
        }
        ++rowIndex;
    }
    // if last program was removed [programLoadingInfos count] returns 0,
    // then default program was automatically recreated, therefore reload
    if (! [self.programLoadingInfos count]) {
        [self loadPrograms];
        [self.tableView reloadData];
    }
}

- (void)renameOldProgramName:(NSString*)oldProgramName ToNewProgramName:(NSString*)newProgramName
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
    self.toolbarItems = @[flexItem, add, flexItem];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kUIBarButtonItemTitleDelete
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

@end
