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

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsProgramsKey @"showDetails"

@interface MyProgramsViewController () <ProgramUpdateDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, strong) NSMutableDictionary *assetCache;
@property (nonatomic, strong) NSMutableArray *programLoadingInfos;
@property (nonatomic, strong) Program *selectedProgram;
@property (nonatomic, strong) Program *defaultProgram;
@end

@implementation MyProgramsViewController

#pragma mark - getters and setters
- (NSMutableDictionary*)assetCache
{
    // lazy instantiation
    if (! _assetCache) {
        _assetCache = [NSMutableDictionary dictionaryWithCapacity:[self.programLoadingInfos count]];
    }
    return _assetCache;
}

#pragma mark - initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initNavigationBar
{
//    if (! [self.programLoadingInfos count]) {
//        [TableUtil initNavigationItem:self.navigationItem withTitle:self.title];
//        return;
//    }
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
    self.navigationController.title = self.title = NSLocalizedString(@"Programs", nil);
    [self loadPrograms];
    [self initNavigationBar];
    [super initTableView];

    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self setupToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.defaultProgram = nil;
    self.selectedProgram = nil;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self initNavigationBar];
    [self.tableView reloadData];
}

#pragma mark - system events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.assetCache = nil;
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
        [options addObject:NSLocalizedString(@"Hide Details",nil)];
    } else {
        [options addObject:NSLocalizedString(@"Show Details",nil)];
    }
    if ([self.programLoadingInfos count]) {
        [options addObject:NSLocalizedString(@"Delete Programs",nil)];
    }
    [Util actionSheetWithTitle:NSLocalizedString(@"Edit Programs",nil)
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditProgramsActionSheetTag
                          view:self.view];
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
                                       ? kConfirmTitleDeletePrograms : kConfirmTitleDeleteProgram)
                       confirmMessage:kConfirmMessageDelete];
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
    [self initNavigationBar];
}

- (void)deleteProgramForIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *programLoadingInfo = [self.programLoadingInfos objectAtIndex:indexPath.row];
    [self removeProgram:programLoadingInfo.visibleName];
    [self initNavigationBar];
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
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier];
    }
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
        if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
            DarkBlueGradientImageDetailCell *imageDetailCell = (DarkBlueGradientImageDetailCell*)imageCell;
            imageDetailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
            imageDetailCell.topLeftDetailLabel.text = @"Last access:";
            imageDetailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
            imageDetailCell.topRightDetailLabel.text = @"Today 10:46 PM";
            imageDetailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
            imageDetailCell.bottomLeftDetailLabel.text = @"Size:";
            imageDetailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];
            imageDetailCell.bottomRightDetailLabel.text = @"429.3 KB";
        }
    }
    NSString *patternName = @"pattern";
    UIColor* color = [self.assetCache objectForKey:patternName];
    if (! color) {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
        [self.assetCache setObject:color forKey:patternName];
    }
    cell.backgroundColor = color;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}


- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self performActionOnConfirmation:@selector(deleteProgramForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kConfirmTitleDeleteProgram
                           confirmMessage:kConfirmMessageDelete];
    }
}

#pragma mark - table view helpers
- (void)configureImageCell:(UITableViewCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *info = [self.programLoadingInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
    NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/small_screenshot.png", info.basePath];
    UIImage* image = [self.assetCache objectForKey:imagePath];
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

    if (! image) {
        cell.iconImageView.image = nil;
        cell.indexPath = indexPath;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
            NSString *newImagePath = nil;
            //image = [UIImage imageWithContentsOfFile:imagePath];
            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                newImagePath = [[NSString alloc] initWithFormat:@"%@/automatic_screenshot.png", info.basePath];
                image = [UIImage imageWithContentsOfFile:newImagePath];
            }

            if (! image) {
                image = [UIImage imageNamed:@"programs"];
            }
            //    CGSize imageSize = image.size;
            //    UIGraphicsBeginImageContext(imageSize);
            //    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            //    image = UIGraphicsGetImageFromCurrentImageContext();
            //    UIGraphicsEndImageContext();

            // perform UI stuff on main queue (UIKit is not thread safe!!)
            dispatch_sync(dispatch_get_main_queue(), ^{
                // check if cell still needed
                if ([cell.indexPath isEqual:indexPath]) {
                    cell.iconImageView.image = image;
                    [cell setNeedsLayout];
                    [self.assetCache setObject:image forKey:imagePath];
                }
            });
        });
    } else {
        cell.iconImageView.image = image;
    }
    [cell.iconImageView setBorder:[UIColor skyBlueColor] Width:kDefaultImageCellBorderWidth];

//    dispatch_queue_t imageQueue = dispatch_queue_create("at.tugraz.ist.catrobat.ImageLoadingQueue", NULL);
//    dispatch_async(imageQueue, ^{
//        
//        NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
//        
//        UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
//        if(!image) {
//            imagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
//            image = [UIImage imageWithContentsOfFile:imagePath];
//        }
//        if(!image) {
//            image = [UIImage imageNamed:@"programs"];
//        }
//        
//        
//        CGSize imageSize = image.size;
//        UIGraphicsBeginImageContext(imageSize);
//        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView beginUpdates];
//            UITableViewCell <CatrobatImageCell>* cell = (UITableViewCell <CatrobatImageCell>*)[self.tableView cellForRowAtIndexPath:indexPath];
//            if(cell) {
//                cell.iconImageView.image = image;
//            }
//            [self.tableView endUpdates];
//        });
//        
//    });

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
            [Util alertWithText:kMsgUnableToLoadProgram];
            return NO;
        }
    } else if ([identifier isEqualToString:segueToNewProgram]) {
        // if there is no program name, abort performing this segue and ask user for program name
        // after user entered a valid program name this segue will be called again and accepted
        if (! self.defaultProgram) {
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
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

#pragma mark - text field delegates
- (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)characters
{
    NSCharacterSet *blockedCharacters = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters] invertedSet];
    return ([characters rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag != kEditProgramsActionSheetTag) {
        return;
    }

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
    } else if (buttonIndex == 1 && [self.programLoadingInfos count]) {
        // Delete Programs button
        [self setupEditingToolBar];
        [super changeToEditingMode:actionSheet];
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
            [Util alertWithText:kMsgInvalidProgramName
                       delegate:self
                            tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultAlreadyExists) {
            [Util alertWithText:kMsgInvalidProgramNameAlreadyExists
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
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
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
            break;
        }
        ++rowIndex;
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
            self.assetCache = nil;

            // update table
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
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
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
