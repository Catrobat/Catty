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
#import "LevelUpdateDelegate.h"
#import "SensorHandler.h"
#import "CellTagDefines.h"
#import "AppDelegate.h"

// identifiers
#define kTableHeaderIdentifier @"Header"

@interface ProgramTableViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
UINavigationBarDelegate>
@property (strong, nonatomic) NSMutableDictionary *imageCache;
@end

@implementation ProgramTableViewController

- (void)setProgram:(Program *)program
{
    if (program) {
        [program setAsLastProgram];
    }
    _program = program;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    // TODO: use data source for the ProgramTableViewController instead of reloading the whole data
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    //  [self.tableView beginUpdates];
    //  [self.tableView reloadRowsAtIndexPaths:@[indexPathOfYourCell] withRowAnimation:UITableViewRowAnimationNone];
    //  [self.tableView endUpdates];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isNewProgram) {
        [self.program saveToDisk];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];

    if (self.program.header.programName) {
        self.navigationItem.title = self.program.header.programName;
        self.title = self.program.header.programName;
    }
    [self setupToolBar];
}

#pragma getter & setters
- (NSMutableDictionary*)imageCache
{
    // lazy instantiation
    if (! _imageCache) {
        _imageCache = [NSMutableDictionary dictionaryWithCapacity:[self.program.objectList count]];
    }
    return _imageCache;
}

- (SpriteObject*)createObjectWithName:(NSString*)objectName
{
    // TODO: review this...
    SpriteObject* object = [[SpriteObject alloc] init];
    //object.originalSize;
    //object.spriteManagerDelegate;
    //object.broadcastWaitDelegate = self.broadcastWaitHandler;
    object.currentLook = nil;
    object.name = objectName;
    object.program = self.program;
    return object;
}

#pragma mark init
- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
    headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    [self.tableView addSubview:headerViewTemplate];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.imageCache = nil;
}

#pragma mark - UITableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInProgramTableViewController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kBackgroundSectionIndex:
            return kBackgroundObjects;
        case kObjectSectionIndex:
            return ([self.program.objectList count] - kBackgroundObjects);
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kObjectCell forIndexPath:indexPath];
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
    NSInteger index = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
    SpriteObject *object = [self.program.objectList objectAtIndex:index];
    if (! [object.lookList count]) {
        imageCell.iconImageView.image = nil;
        imageCell.titleLabel.text = object.name;
        return imageCell;
    }

    imageCell.iconImageView.image = nil;
    NSString *previewImagePath = [object previewImagePath];
    NSNumber *indexAsNumber = @(index);
    UIImage *image = [self.imageCache objectForKey:indexAsNumber];
    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (! image) {
        imageCell.iconImageView.image = nil;
        imageCell.indexPath = indexPath;
        if (previewImagePath) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:previewImagePath];
                // perform UI stuff on main queue (UIKit is not thread safe!!)
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // check if cell still needed
                    if ([imageCell.indexPath isEqual:indexPath]) {
                        imageCell.iconImageView.image = image;
                        [imageCell setNeedsLayout];
                        [self.imageCache setObject:image forKey:indexAsNumber];
                    }
                });
            });
        } else {
            // fallback
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                // TODO: outsource this "thumbnail generation code" to helper class
                Look* look = [object.lookList objectAtIndex:kBackgroundObjectIndex];
                NSString *newPreviewImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                                 [object projectPath], kProgramImagesDirName,
                                                 [look previewImageFileName]];

                NSString *imagePath = [NSString stringWithFormat:@"%@%@/%@",
                                       [object projectPath], kProgramImagesDirName,
                                       look.fileName];
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

                // generate thumbnail image (retina)
                CGSize previewImageSize = CGSizeMake(kPreviewImageWidth, kPreviewImageHeight);
                // determine aspect ratio
                if (image.size.height > image.size.width)
                    previewImageSize.width = (image.size.width*previewImageSize.width)/image.size.height;
                else
                    previewImageSize.height = (image.size.height*previewImageSize.height)/image.size.width;
                
                UIGraphicsBeginImageContext(previewImageSize);
                UIImage *previewImage = [image copy];
                [previewImage drawInRect:CGRectMake(0, 0, previewImageSize.width, previewImageSize.height)];
                previewImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [UIImagePNGRepresentation(previewImage) writeToFile:newPreviewImagePath atomically:YES];

                dispatch_sync(dispatch_get_main_queue(), ^{
                    // check if cell still needed
                    if ([imageCell.indexPath isEqual:indexPath]) {
                        imageCell.iconImageView.image = previewImage;
                        [imageCell setNeedsLayout];
                        [self.imageCache setObject:previewImage forKey:indexAsNumber];
                    }
                });
            });
        }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // TODO: outsource to TableUtil
    switch (section) {
        case 0:
            return 45.0;
        case 1:
            return 50.0;
        default:
            return 45.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // TODO: MID outsource to TableUtil
    //UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableHeaderIdentifier];
    // FIXME: HACK do not alloc init there. Use ReuseIdentifier instead!! But does lead to several issues...
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    headerView.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];

    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section]-10.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 0.0f, 265.0f, height)];

    CALayer *layer = titleLabel.layer;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor airForceBlueColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, layer.frame.size.height-1, layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor airForceBlueColor].CGColor];
    [layer addSublayer:bottomBorder];

    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.tag = 1;
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    if (section == 0)
        titleLabel.text = [kBackgroundTitle uppercaseString];
    else if ([self.program.objectList count] > (kBackgroundObjects + 1))
        titleLabel.text = [kObjectTitlePlural uppercaseString];
    else
        titleLabel.text = [kObjectTitleSingular uppercaseString];

    titleLabel.text = [NSString stringWithFormat:@"  %@", titleLabel.text];
    [headerView.contentView addSubview:titleLabel];
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == kObjectSectionIndex) && (([self.program.objectList count] - kBackgroundObjects) > kMinNumOfObjects));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kObjectSectionIndex) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.program.objectList removeObjectAtIndex:(kObjectSectionIndex + indexPath.row)];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the selected object to the new view controller.
    static NSString *toObjectSegueID = kSegueToObject;
    static NSString *toSceneSegueID = kSegueToScene;

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
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.identifier isEqualToString:toSceneSegueID]) {
            if ([destController isKindOfClass:[ScenePresenterViewController class]]) {
                ScenePresenterViewController* scvc = (ScenePresenterViewController*) destController;
                if ([scvc respondsToSelector:@selector(setProgram:)]) {
                    [scvc setController:(UITableViewController *)self];
                    [scvc performSelector:@selector(setProgram:) withObject:self.program];
                }
            }
        }
    }
}

#pragma mark - IBActions
- (IBAction)editProgram:(id)sender
{
    [self showSceneActionSheet];
}

#pragma mark - UIActionSheetDelegate Handlers
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kSceneActionSheetTag) {
        // Rename button
        if (buttonIndex == 1)
            [self showRenameProgramAlertView];
        // Delete button
        if (buttonIndex == actionSheet.destructiveButtonIndex)
        {
            NSLog(@"Delete button pressed");
            [self.delegate removeLevel:self.program.header.programName];
            [self.program removeFromDisk];
            self.program = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIAlertViewDelegate Handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kRenameAlertViewTag) {
        NSString* input = [alertView textFieldAtIndex:0].text;
        if (buttonIndex == kAlertViewButtonOK) {
            if ([input isEqualToString:self.program.header.programName])
                return;

            kProgramNameValidationResult validationResult = [Program validateProgramName:input];
            if (validationResult == kProgramNameValidationResultInvalid) {
                [Util alertWithText:NSLocalizedString(@"No or invalid program name entered, try again.",nil) delegate:self tag:kInvalidProgramNameWarningAlertViewTag];
            } else if (validationResult == kProgramNameValidationResultAlreadyExists) {
                [Util alertWithText:NSLocalizedString(@"A program with the same name already exists, try again.",nil) delegate:self tag:kInvalidProgramNameWarningAlertViewTag];
            } else {
                [self.delegate renameOldLevelName:self.program.header.programName ToNewLevelName:input];
                [self.program renameToProgramName:input];
                [self.program setAsLastProgram];
                self.navigationItem.title = self.title = input;
            }
        }
    }
    if (alertView.tag == kNewObjectAlertViewTag) {
        NSString* input = [[alertView textFieldAtIndex:0] text];
        if (buttonIndex == kAlertViewButtonOK) {
            return;
        }
        if (! [input length]) {
            [Util alertWithText:NSLocalizedString(@"No or invalid object name entered, aborted.",nil) delegate:self tag:kInvalidObjectNameWarningAlertViewTag];
            return;
        }
        [self.program.objectList addObject:[self createObjectWithName:input]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == 0) {
            [self showRenameProgramAlertView];
        }
    }
}

//------------------------------------------------------------------------------------------------------------
// TODO: outsource all this view stuff below to UserInterface group
//       and create own helper classes for the helper stuff.
//       This is not part of the controller logic and highly decreases readability!!

#pragma mark - UIAlertView Views
- (void)showRenameProgramAlertView
{
    UIAlertView *renameProgramAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename program",nil)
                                                                 message:NSLocalizedString(@"Program name:",nil)
                                                                delegate:self
                                                       cancelButtonTitle:kBtnCancelTitle
                                                       otherButtonTitles:kBtnOKTitle, nil];
    [renameProgramAlert setTag:kRenameAlertViewTag];
    renameProgramAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [renameProgramAlert textFieldAtIndex:0];
    textField.placeholder = kProgramNamePlaceholder;

    // populate with current program name if not default name given
    if (! [self.program.header.programName isEqualToString:kDefaultProgramName])
        textField.text = self.program.header.programName;

    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [renameProgramAlert show];
}

- (void)showNewObjectAlertView
{
    UIAlertView *newObjectAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Add Object",nil)
                                                            message:NSLocalizedString(@"Object name:",nil)
                                                           delegate:self
                                                  cancelButtonTitle:kBtnCancelTitle
                                                  otherButtonTitles:kBtnOKTitle, nil];
    newObjectAlert.tag = kNewObjectAlertViewTag;
    newObjectAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[newObjectAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [newObjectAlert show];
}

#pragma mark - UIActionSheet Views
- (void)showSceneActionSheet
{
    UIActionSheet *edit = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Edit Program",nil)
                                                      delegate:self
                                             cancelButtonTitle:kBtnCancelTitle
                                        destructiveButtonTitle:kBtnDeleteTitle
                                             otherButtonTitles:NSLocalizedString(@"Rename",nil), nil];
    edit.tag = kSceneActionSheetTag;
    edit.actionSheetStyle = UIActionSheetStyleDefault;
    [edit showInView:self.view];
}

#pragma mark - Helper Methods
- (void)addObjectAction:(id)sender
{
    [self showNewObjectAlertView];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
    // @INFO: Please do not modify or remove this code again, unless you don't exactly know what you are doing.
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1.png"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
}

@end
