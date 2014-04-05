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
#import "ProgramUpdateDelegate.h"
#import "SensorHandler.h"
#import "CellTagDefines.h"
#import "AppDelegate.h"

// identifiers
#define kTableHeaderIdentifier @"Header"

@interface ProgramTableViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
UINavigationBarDelegate>
@property (strong, nonatomic) NSCharacterSet *blockedCharacterSet;
@property (strong, nonatomic) NSMutableDictionary *imageCache;
@end

@implementation ProgramTableViewController

#pragma mark - getter & setters
- (NSCharacterSet*)blockedCharacterSet
{
    if (! _blockedCharacterSet) {
        _blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters] invertedSet];
    }
    return _blockedCharacterSet;
}

- (NSMutableDictionary*)imageCache
{
    // lazy instantiation
    if (! _imageCache) {
        _imageCache = [NSMutableDictionary dictionaryWithCapacity:[self.program numberOfTotalObjects]];
    }
    return _imageCache;
}

- (void)setProgram:(Program *)program
{
    [program setAsLastProgram];
    _program = program;
}

#pragma mark - initialization
- (void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    self.tableView.backgroundColor = backgroundColor;
    UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
    headerViewTemplate.contentView.backgroundColor = backgroundColor;
    [self.tableView addSubview:headerViewTemplate];
}

#pragma mark - view events
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

    self.editing = NO;
    if (self.program.header.programName) {
        self.navigationItem.title = self.program.header.programName;
        self.title = self.program.header.programName;
    }
    [self setupToolBar];
}

#pragma mark - application events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.imageCache = nil;
}

#pragma mark - actions
- (void)addObjectAction:(id)sender
{
    [Util promptWithTitle:NSLocalizedString(@"Add Object",nil)
                  message:NSLocalizedString(@"Object name:",nil)
                 delegate:self
              placeholder:kObjectNamePlaceholder
                      tag:kNewObjectAlertViewTag
        textFieldDelegate:self];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (IBAction)editProgram:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    [options addObject:NSLocalizedString(@"Rename",nil)];
    if ([self.program numberOfNormalObjects]) {
        [options addObject:NSLocalizedString(@"Delete multiple objects",nil)];
    }
    [Util actionSheetWithTitle:NSLocalizedString(@"Edit Program",nil)
                      delegate:self
        destructiveButtonTitle:kBtnDeleteTitle
             otherButtonTitles:options
                           tag:kSceneActionSheetTag
                          view:self.view];
}

- (void)deleteSelectedObjects:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        // sanity check
        if (selectedRowIndexPath.section != kObjectSectionIndex) {
            continue;
        }
        NSLog(@"IndexPath: %@", [selectedRowIndexPath description]);
        SpriteObject *object = (SpriteObject*)[self.program.objectList objectAtIndex:(kObjectSectionIndex + selectedRowIndexPath.row)];
        [self.imageCache objectForKey:object.name];
        [objectsToRemove addObject:object];
    }
    for (SpriteObject *objectToRemove in objectsToRemove) {
        [self.program removeObject:objectToRemove];
    }
    [super exitEditingMode:sender];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kObjectCell forIndexPath:indexPath];
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
    NSInteger index = (kBackgroundSectionIndex + indexPath.section + indexPath.row);
    SpriteObject *object = [self.program.objectList objectAtIndex:index];
    if (! [object.lookList count]) {
        imageCell.iconImageView.image = nil;
        imageCell.titleLabel.text = object.name;
        return imageCell;
    }

    imageCell.iconImageView.image = nil;
    NSString *previewImagePath = [object previewImagePath];
    UIImage *image = [self.imageCache objectForKey:object.name];
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
                        [self.imageCache setObject:image forKey:object.name];
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
                        [self.imageCache setObject:previewImage forKey:object.name];
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

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    // TODO: outsource to TableUtil
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
    if (section == 0) {
        titleLabel.text = [kBackgroundTitle uppercaseString];
    } else {
        titleLabel.text = (([self.program numberOfNormalObjects] != 1)
                        ? [kObjectTitlePlural uppercaseString]
                        : [kObjectTitleSingular uppercaseString]);
    }
    titleLabel.text = [NSString stringWithFormat:@"  %@", titleLabel.text];
    [headerView.contentView addSubview:titleLabel];
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == kObjectSectionIndex)
            && ([self.program numberOfNormalObjects] > kMinNumOfObjects));
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == kObjectSectionIndex) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            SpriteObject *object = [self.program.objectList objectAtIndex:(kObjectSectionIndex + indexPath.row)];
            [self.imageCache objectForKey:object.name];
            [self.program removeObject:object];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - segue handler
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

#pragma mark - text field delegates
- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters
{
    return ([characters rangeOfCharacterFromSet:self.blockedCharacterSet].location == NSNotFound);
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag != kSceneActionSheetTag) {
        return;
    }

    if (buttonIndex == 1) {
        // Rename button
        [Util promptWithTitle:NSLocalizedString(@"Rename program",nil)
                      message:NSLocalizedString(@"Program name:",nil)
                     delegate:self
                  placeholder:kProgramNamePlaceholder
                          tag:kRenameAlertViewTag
                        value:((! [self.program.header.programName isEqualToString:kNewDefaultProgramName])
                               ? self.program.header.programName : nil)
            textFieldDelegate:self];
    } else if (buttonIndex == 2 && [self.program numberOfNormalObjects]) {
        // Delete multiple objects button
        [self setupEditingToolBar];
        [super changeToEditingMode:actionSheet editableSections:@[@(kObjectSectionIndex)]];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Delete program button
        [self.delegate removeProgram:self.program.header.programName];
        [self.program removeFromDisk];
        self.program = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - alert view delegate handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kRenameAlertViewTag) {
        NSString* input = [alertView textFieldAtIndex:0].text;
        if (buttonIndex == kAlertViewButtonOK) {
            if ([input isEqualToString:self.program.header.programName])
                return;

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
            [Util alertWithText:kMsgInvalidObjectName delegate:self tag:kInvalidObjectNameWarningAlertViewTag];
            return;
        }
        [self.program addNewObjectWithName:input];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)]
                      withRowAnimation:UITableViewRowAnimationFade];
    }
    if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == 0) {
            [Util promptWithTitle:NSLocalizedString(@"Rename program",nil)
                          message:NSLocalizedString(@"Program name:",nil)
                         delegate:self
                      placeholder:kProgramNamePlaceholder
                              tag:kRenameAlertViewTag
                            value:((! [self.program.header.programName isEqualToString:kNewDefaultProgramName])
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
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(deleteSelectedObjects:)];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, flexItem, deleteButton, nil];
}

@end
