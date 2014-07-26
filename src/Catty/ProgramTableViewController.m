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

#import "ProgramTableViewController.h"
#import "TableUtil.h"
#import "ObjectTableViewController.h"
#import "SegueDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Brick.h"
#import "ObjectTableViewController.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Util.h"
#import "UIDefines.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"
#import "Script.h"
#import "Brick.h"
#import "ActionSheetAlertViewTags.h"
#import "ScenePresenterViewController.h"
#import "FileManager.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "ProgramUpdateDelegate.h"
#import "SensorHandler.h"
#import "CellTagDefines.h"
#import "AppDelegate.h"
#import "LanguageTranslationDefines.h"
#import "ProgramTableHeaderView.h"
#import "RuntimeImageCache.h"

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsObjectsKey @"detailsForObjects"

@interface ProgramTableViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
                                          UINavigationBarDelegate, SWTableViewCellDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (strong, nonatomic) NSCharacterSet *blockedCharacterSet;
@end

@implementation ProgramTableViewController

#pragma mark - getter and setters
- (NSCharacterSet*)blockedCharacterSet
{
    if (! _blockedCharacterSet) {
        _blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters] invertedSet];
    }
    return _blockedCharacterSet;
}

- (void)setProgram:(Program *)program
{
    [program setAsLastProgram];
    _program = program;
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:kUIBarButtonItemTitleEdit
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - ViewController Delegates
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsObjectsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsObjectsKey];
    self.useDetailCells = [showDetailsObjectsValue boolValue];
    [self initNavigationBar];
    [self.tableView registerClass:[ProgramTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.editableSections = @[@(kObjectSectionIndex)];
    if (self.program.header.programName) {
        self.navigationItem.title = self.program.header.programName;
        self.title = self.program.header.programName;
    }
    [self setupToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isNewProgram) {
        [self.program saveToDisk];
    }
}

#pragma mark - actions
- (void)addObjectAction:(id)sender
{
    [Util promptWithTitle:kUIAlertViewTitleAddObject
                  message:[NSString stringWithFormat:@"%@:", kUIAlertViewMessageObjectName]
                 delegate:self
              placeholder:kUIAlertViewPlaceholderEnterObjectName
                      tag:kNewObjectAlertViewTag
        textFieldDelegate:self];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    ScenePresenterViewController *vc =[[ScenePresenterViewController alloc] initWithProgram:[Program programWithLoadingInfo:[Util programLoadingInfoForProgramWithName:[Util lastProgram]]]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    [options addObject:kUIActionSheetButtonTitleRename];
    if ([self.program numberOfNormalObjects]) {
        [options addObject:kUIActionSheetButtonTitleDeleteObjects];
    }
    if (self.useDetailCells) {
        [options addObject:kUIActionSheetButtonTitleHideDetails];
    } else {
        [options addObject:kUIActionSheetButtonTitleShowDetails];
    }
    [Util actionSheetWithTitle:kUIActionSheetTitleEditProgramSingular
                      delegate:self
        destructiveButtonTitle:kUIActionSheetButtonTitleDelete
             otherButtonTitles:options
                           tag:kEditProgramActionSheetTag
                          view:self.view];
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
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        // sanity check
        if (selectedRowIndexPath.section != kObjectSectionIndex) {
            continue;
        }
        SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:(kObjectSectionIndex + selectedRowIndexPath.row)];
        [objectsToRemove addObject:object];
    }
    for (SpriteObject *objectToRemove in objectsToRemove) {
        [self.program removeObject:objectToRemove];
    }
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteObjectForIndexPath:(NSIndexPath*)indexPath
{
    NSUInteger index = (kBackgroundObjects + indexPath.row);
    SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:index];
    [self.program removeObject:object];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteProgramAction
{
    [self.delegate removeProgram:self.program.header.programName];
    [self.program removeFromDisk];
    self.program = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInProgramTableViewController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kBackgroundSectionIndex:
            return [self.program numberOfBackgroundObjects];
        case kObjectSectionIndex:
            return [self.program numberOfNormalObjects];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    SpriteObject *object = [self.program.objectList objectAtIndex:index];
    imageCell.iconImageView.image = nil;
    [imageCell.iconImageView setBorder:[UIColor skyBlueColor] Width:kDefaultImageCellBorderWidth];
    if (indexPath.section == kObjectSectionIndex) {
        imageCell.rightUtilityButtons = @[[Util slideViewButtonMore], [Util slideViewButtonDelete]];
        imageCell.delegate = self;
//    } else if (indexPath.section == kBackgroundSectionIndex) {
//        imageCell.rightUtilityButtons = @[[Util slideViewButtonMore]];
//        imageCell.delegate = self;
    } else {
        imageCell.rightUtilityButtons = nil;
        imageCell.delegate = nil;
    }

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kUILabelTextScripts,
                                              (unsigned long)[object numberOfScripts]];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kUILabelTextBricks,
                                               (unsigned long)[object numberOfTotalBricks]];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kUILabelTextLooks,
                                                 (unsigned long)[object numberOfLooks]];
        detailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomRightDetailLabel.text = [NSString stringWithFormat:@"%@: %lu", kUILabelTextSounds,
                                                  (unsigned long)[object numberOfSounds]];
    }

    if (! [object.lookList count]) {
        imageCell.titleLabel.text = object.name;
        return imageCell;
    }

    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    NSString *previewImagePath = [object previewImagePath];
    NSString *imagePath = [object pathForLook:[object.lookList firstObject]];
    imageCell.iconImageView.image = nil;
    imageCell.indexPath = indexPath;

    UIImage *image = [imageCache cachedImageForPath:previewImagePath];
    if (! image) {
        [imageCache loadThumbnailImageFromDiskWithThumbnailPath:previewImagePath
                                                      imagePath:imagePath
                                             thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)
                                                   onCompletion:^(UIImage *image){
                                                       // check if cell still needed
                                                       if ([imageCell.indexPath isEqual:indexPath]) {
                                                           imageCell.iconImageView.image = image;
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
    return [TableUtil getHeightForImageCell];
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
    ProgramTableHeaderView *headerView = (ProgramTableHeaderView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    if (section == 0) {
        headerView.textLabel.text = [kUILabelTextBackground uppercaseString];
    } else {
        headerView.textLabel.text = (([self.program numberOfNormalObjects] != 1)
                                                    ? [kUILabelTextObjectPlural uppercaseString]
                                                    : [kUILabelTextObjectSingular uppercaseString]);
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
    ProgramTableHeaderView *headerView = (ProgramTableHeaderView*)view;
    headerView.textLabel.textColor = UIColor.headerTextColor;
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
                    SpriteObject* object = [self.program.objectList objectAtIndex:(kBackgroundObjectIndex + indexPath.section + indexPath.row)];
                    [destController performSelector:@selector(setObject:) withObject:object];
                }
            }
        }
    }
}

#pragma mark - swipe delegates
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index == 0) {
        // More button was pressed
        UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                            message:@"More more more"
                                                           delegate:nil
                                                  cancelButtonTitle:kUIAlertViewButtonTitleCancel
                                                  otherButtonTitles:nil];
        [alertTest show];
        [cell hideUtilityButtonsAnimated:YES];
    } else if (index == 1) {
        // Delete button was pressed
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [cell hideUtilityButtonsAnimated:YES];
        if (indexPath.section == kObjectSectionIndex) {
            [self performActionOnConfirmation:@selector(deleteObjectForIndexPath:)
                               canceledAction:nil
                                   withObject:indexPath
                                       target:self
                                 confirmTitle:kUIAlertViewTitleDeleteSingleObject
                               confirmMessage:kUIAlertViewMessageIrreversibleAction];
        }
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - text field delegates
- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters
{
    if ([characters length] > kMaxNumOfObjectNameCharacters) {
        return false;
    }
    return ([characters rangeOfCharacterFromSet:self.blockedCharacterSet].location == NSNotFound);
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag != kEditProgramActionSheetTag) {
        return;
    }

    if (buttonIndex == 1) {
        // Rename button
        [Util promptWithTitle:kUIAlertViewTitleRenameProgram
                      message:[NSString stringWithFormat:@"%@:", kUIAlertViewMessageProgramName]
                     delegate:self
                  placeholder:kUIAlertViewPlaceholderEnterProgramName
                          tag:kRenameAlertViewTag
                        value:((! [self.program.header.programName isEqualToString:kGeneralNewDefaultProgramName])
                               ? self.program.header.programName : nil)
            textFieldDelegate:self];
    } else if (buttonIndex == 2 && [self.program numberOfNormalObjects]) {
        // Delete Objects button
        [self setupEditingToolBar];
        [super changeToEditingMode:actionSheet];
    } else if (buttonIndex == 3 || ((buttonIndex == 2) && (! [self.program numberOfNormalObjects]))) {
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
                               forKey:kUserDetailsShowDetailsObjectsKey];
        [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
        [defaults synchronize];
        [self.tableView reloadData];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Delete Program button
        [self performActionOnConfirmation:@selector(deleteProgramAction)
                           canceledAction:nil
                                   target:self
                             confirmTitle:kUIAlertViewTitleDeleteProgram
                           confirmMessage:kUIAlertViewMessageIrreversibleAction];
    }
}

#pragma mark - alert view delegate handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    if (alertView.tag == kRenameAlertViewTag) {
        NSString *input = [alertView textFieldAtIndex:0].text;
        if (buttonIndex == kAlertViewButtonOK) {
            if ([input isEqualToString:self.program.header.programName])
                return;

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
                NSString *oldProgramName = self.program.header.programName;
                [self.program renameToProgramName:input];
                [self.delegate renameOldProgramName:oldProgramName ToNewProgramName:input];
                [self.program setAsLastProgram];
                self.navigationItem.title = self.title = input;
            }
        }
    }
    if (alertView.tag == kNewObjectAlertViewTag) {
        NSString* input = [alertView textFieldAtIndex:0].text;
        if (buttonIndex != kAlertViewButtonOK) {
            return;
        }
        if (! [input length]) {
            [Util alertWithText:kUIAlertViewMessageInvalidObjectName
                       delegate:self
                            tag:kInvalidObjectNameWarningAlertViewTag];
            return;
        }
        [self.program addNewObjectWithName:input];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == 0) {
            [Util promptWithTitle:kUIAlertViewTitleRenameProgram
                          message:[NSString stringWithFormat:@"%@:", kUIAlertViewMessageProgramName]
                         delegate:self
                      placeholder:kUIAlertViewPlaceholderEnterProgramName
                              tag:kRenameAlertViewTag
                            value:((! [self.program.header.programName isEqualToString:kGeneralNewDefaultProgramName])
                                   ? self.program.header.programName : nil)
                textFieldDelegate:self];
        }
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
                                                                         action:@selector(addObjectAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
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
                                                                    action:@selector(confirmDeleteSelectedObjectsAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}

@end
