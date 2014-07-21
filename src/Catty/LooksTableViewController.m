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

#import "LooksTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Look.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "ScenePresenterViewController.h"
#import "LookImageViewController.h"
#import "ProgramDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "NSData+Hashes.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"
#import "CatrobatActionSheet.h"
#import "CatrobatAlertView.h"

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsLooksKey @"detailsForLooks"

@interface ObjectLooksTableViewController () <CatrobatActionSheetDelegate, UIImagePickerControllerDelegate,
                                              UINavigationControllerDelegate, CatrobatAlertViewDelegate,
                                              UITextFieldDelegate, SWTableViewCellDelegate>
@property (nonatomic, strong) NSCharacterSet *blockedCharacterSet;
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, strong) Look *lookToAdd;
@property (nonatomic, strong) LoadingView* loadingView;
@end

@implementation ObjectLooksTableViewController

#pragma mark - getters and setters
- (NSCharacterSet*)blockedCharacterSet
{
    if (! _blockedCharacterSet) {
        _blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters] invertedSet];
    }
    return _blockedCharacterSet;
}

#pragma mark - data helpers
- (NSArray*)existantLookNames
{
    // get all look names of that object
    NSMutableArray *lookNames = [NSMutableArray arrayWithCapacity:[self.object.lookList count]];
    for (Look *look in self.object.lookList) {
        [lookNames addObject:look.name];
    }
    return [lookNames copy];
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lookToAdd = nil;
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsProgramsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsLooksKey];
    self.useDetailCells = [showDetailsProgramsValue boolValue];
    self.title = self.navigationItem.title = kUIViewControllerTitleLooks;
    [self initNavigationBar];
    self.placeHolderView.title = kUIViewControllerPlaceholderTitleLooks;
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    if ([self.object.lookList count]) {
        [options addObject:kUIActionSheetButtonTitleDeleteLooks];
    }
    if (self.useDetailCells) {
        [options addObject:kUIActionSheetButtonTitleHideDetails];
    } else {
        [options addObject:kUIActionSheetButtonTitleShowDetails];
    }
    [Util actionSheetWithTitle:kUIActionSheetTitleEditLooks
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditLooksActionSheetTag
                          view:self.navigationController.view];
}

- (void)addLookAction:(id)sender
{
    [self showAddLookActionSheet];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)confirmDeleteSelectedLooksAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self performActionOnConfirmation:@selector(deleteSelectedLooksAction)
                       canceledAction:@selector(exitEditingMode)
                               target:self
                         confirmTitle:(([selectedRowsIndexPaths count] != 1)
                                       ? kUIAlertViewTitleDeleteMultipleLooks
                                       : kUIAlertViewTitleDeleteSingleLook)
                       confirmMessage:kUIAlertViewMessageIrreversibleAction];
}

- (void)deleteSelectedLooksAction
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *looksToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        Look *look = (Look*)[self.object.lookList objectAtIndex:selectedRowIndexPath.row];
        [looksToRemove addObject:look];
    }
    for (Look *lookToRemove in looksToRemove) {
        [self.object removeLook:lookToRemove];
    }
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
}

- (void)deleteLookForIndexPath:(NSIndexPath*)indexPath
{
    Look *look = (Look*)[self.object.lookList objectAtIndex:indexPath.row];
    [self.object removeLook:look];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.object.lookList count];
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

    CatrobatBaseCell<CatrobatImageCell>* imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    Look *look = [self.object.lookList objectAtIndex:indexPath.row];
    imageCell.iconImageView.image = nil;
    [imageCell.iconImageView setBorder:[UIColor skyBlueColor] Width:kDefaultImageCellBorderWidth];
    imageCell.rightUtilityButtons = @[[Util slideViewButtonMore], [Util slideViewButtonDelete]];
    imageCell.delegate = self;

    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    NSString *previewImagePath = [self.object previewImagePathForLookAtIndex:indexPath.row];
    NSString *imagePath = [self.object pathForLook:look];
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
    imageCell.titleLabel.text = look.name;

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        // TODO: enhancement: use data cache for this later...
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextMeasure];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        CGSize dimensions = [self.object dimensionsOfLook:look];
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%lux%lu",
                                               (unsigned long)dimensions.width,
                                               (unsigned long)dimensions.height];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextSize];
        detailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];
        NSUInteger resultSize = [self.object fileSizeOfLook:look];
        NSNumber *sizeOfSound = [NSNumber numberWithUnsignedInteger:resultSize];
        detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[sizeOfSound unsignedIntegerValue]
                                                                                countStyle:NSByteCountFormatterCountStyleBinary];
        return detailCell;
    }
    return imageCell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
  return [TableUtil getHeightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    static NSString *segueToImage = kSegueToImage;
    if (! self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self shouldPerformSegueWithIdentifier:segueToImage sender:cell]) {
            [self performSegueWithIdentifier:segueToImage sender:cell];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* segueToSceneIdentifier = kSegueToScene;
    static NSString* segueToImageIdentifier = kSegueToImage;
    UIViewController* destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.identifier isEqualToString:segueToSceneIdentifier]) {
            if ([destController isKindOfClass:[ScenePresenterViewController class]]) {
                ScenePresenterViewController *scvc = (ScenePresenterViewController*)destController;
                if ([scvc respondsToSelector:@selector(setProgram:)]) {
                    [scvc setController:(UITableViewController*)self];
                    [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
                }
            }
        }
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if ([segue.identifier isEqualToString:segueToImageIdentifier]) {
            if ([destController isKindOfClass:[LookImageViewController class]]) {
                LookImageViewController *livc = (LookImageViewController*)destController;
                if ([livc respondsToSelector:@selector(setImageName:)] && [livc respondsToSelector:@selector(setImagePath:)]) {
                    Look *look = [self.object.lookList objectAtIndex:indexPath.row];
                    [livc performSelector:@selector(setImageName:) withObject:look.name];
                    NSString *lookImagePath = [self.object pathForLook:look];
                    [livc performSelector:@selector(setImagePath:) withObject:lookImagePath];
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
        [self performActionOnConfirmation:@selector(deleteLookForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kUIAlertViewTitleDeleteSingleLook
                           confirmMessage:kUIAlertViewMessageIrreversibleAction];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - UIImagePicker Handler
- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if (! [UIImagePickerController isSourceTypeAvailable:sourceType])
        return;

    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if (! [availableMediaTypes containsObject:(NSString *)kUTTypeImage])
        return;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.mediaTypes = @[(NSString*)kUTTypeImage];
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // executed on the main queue
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (! image) {
        image = info[UIImagePickerControllerOriginalImage];
    }

    if (! image) {
        return;
    }

    // add image to object now
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self showLoadingView];

    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        // still on the main queue here
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        NSString *imageFileName = [representation filename];
        NSLog(@"fileName: %@",imageFileName);
        NSArray *imageFileNameParts = [imageFileName componentsSeparatedByString:@"."];
        imageFileName = [imageFileNameParts firstObject];
        NSString *imageFileNameExtension = [imageFileNameParts lastObject];
        if ((! [imageFileName length]) || (! [imageFileNameExtension length])) {
            imageFileName = kDefaultImportedImageName;
            imageFileNameExtension = kDefaultImportedImageNameExtension;
        }

        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *lookName = imageFileName;
        // use temporary filename, will be renamed by user afterwards
        NSString *newImageFileName = [NSString stringWithFormat:@"temp_%@.%@",
                                      [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                                      imageFileNameExtension];
        Look *look = [[Look alloc] initWithName:[Util uniqueName:lookName
                                                   existingNames:[self existantLookNames]]
                                        andPath:newImageFileName];

        // TODO: outsource this to FileManager
        NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                  [self.object projectPath], kProgramImagesDirName,
                                  newImageFileName];
        NSString *mediaType = info[UIImagePickerControllerMediaType];

        NSLog(@"Writing file to disk");
        if ([mediaType isEqualToString:@"public.image"]) {
            // leaving the main queue here!
            NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock:^{
                // save image to programs directory
                [imageData writeToFile:newImagePath atomically:YES];
            }];
            // completion block is NOT executed on the main queue
            [saveOp setCompletionBlock:^{
                // execute this on the main queue
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self hideLoadingView];

                    // ask user for image name
                    self.lookToAdd = look;
                    CatrobatAlertView *alertView = [Util promptWithTitle:kUIAlertViewTitleAddImage
                                                                 message:[NSString stringWithFormat:@"%@:", kUIAlertViewMessageImageName]
                                                                delegate:self
                                                             placeholder:kUIAlertViewPlaceholderEnterImageName
                                                                     tag:kNewImageAlertViewTag
                                                       textFieldDelegate:self];
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.text = look.name;
                }];
            }];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperation:saveOp];
        }
    };
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
}

#pragma mark - text field delegates
- (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)characters
{
    if ([characters length] > kMaxNumOfLookNameCharacters) {
        return false;
    }
    return ([characters rangeOfCharacterFromSet:self.blockedCharacterSet].location == NSNotFound);
}

#pragma mark - action sheet delegates
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kEditLooksActionSheetTag) {
        BOOL showHideSelected = NO;
        if ([self.object.lookList count]) {
            if (buttonIndex == 0) {
                // Delete Looks button
                [self setupEditingToolBar];
                [super changeToEditingMode:actionSheet];
            } else if (buttonIndex == 1) {
                showHideSelected = YES;
            }
        } else if (buttonIndex == 0) {
            showHideSelected = YES;
        }
        if (showHideSelected) {
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
                                   forKey:kUserDetailsShowDetailsLooksKey];
            [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
            [defaults synchronize];
            [self.tableView reloadData];
        }
    } else if (actionSheet.tag == kAddLookActionSheetTag) {
        NSInteger importFromCameraIndex = NSIntegerMin;
        NSInteger chooseImageIndex = NSIntegerMin;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
                importFromCameraIndex = 0;
            }
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
                chooseImageIndex = ((importFromCameraIndex == 0) ? 1 : 0);
            }
        }

        if (buttonIndex == importFromCameraIndex) {
            // take picture from camera
            [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
        } else if (buttonIndex == chooseImageIndex) {
            // choose picture from camera roll
            [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//        } else if (buttonIndex != actionSheet.cancelButtonIndex) {
//            // TODO: implement this after Pocket Paint is fully integrated
//            // draw new image
//            NSLog(@"Draw new image");
//            [Util showComingSoonAlertView];
        }
    }
}

#pragma mark - alert view delegate handlers
- (void)alertView:(CatrobatAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    if (alertView.tag == kNewImageAlertViewTag) {
        NSString *input = [alertView textFieldAtIndex:0].text;

        if (! input) {
            self.lookToAdd = nil;
            return;
        }

        if (buttonIndex == kAlertViewButtonOK) {
            [self showPlaceHolder:NO];
            NSArray *existantNames = [self existantLookNames];
            [self.object.lookList addObject:self.lookToAdd];
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSString *oldPath = [self.object pathForLook:self.lookToAdd];
            self.lookToAdd.name = [Util uniqueName:input existingNames:existantNames];

            // rename temporary file name (example: "temp_D41D8CD98F00B204E9800998ECF8427E.png") as well
            NSArray *fileNameParts = [self.lookToAdd.fileName componentsSeparatedByString:@"."];
            NSString *hash = [[[fileNameParts firstObject] componentsSeparatedByString:kResourceFileNameSeparator] lastObject];
            NSString *fileExtension = [fileNameParts lastObject];
            self.lookToAdd.fileName = [NSString stringWithFormat:@"%@%@%@.%@",
                                       hash, kResourceFileNameSeparator,
                                       self.lookToAdd.name, fileExtension];
            NSString *newPath = [self.object pathForLook:self.lookToAdd];
            [appDelegate.fileManager moveExistingFileAtPath:oldPath toPath:newPath overwrite:YES];
            NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            // TODO: update program on disk (run async on another queue)...
        }
        self.lookToAdd = nil;
    }
}

#pragma mark - action sheet
- (void)showAddLookActionSheet
{
    NSMutableArray *buttonTitles = [NSMutableArray array];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            [buttonTitles addObject:kUIActionSheetButtonTitleFromCamera];
        }
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            [buttonTitles addObject:kUIActionSheetButtonTitleChooseImage];
        }
    }
//    [buttonTitles addObject:kUIActionSheetButtonTitleDrawNewImage];

    [Util actionSheetWithTitle:kUIActionSheetTitleAddLook
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:buttonTitles
                           tag:kAddLookActionSheetTag
                          view:self.navigationController.view];
}

#pragma mark - view helpers
- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addLookAction:)];
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
                                                                    action:@selector(confirmDeleteSelectedLooksAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}

- (void)showLoadingView
{
    if (! self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.alpha = 1.0;
    CGPoint top = CGPointMake(0, -self.navigationController.navigationBar.frame.size.height);
    [self.tableView setContentOffset:top animated:NO];
    self.tableView.scrollEnabled = NO;
    self.tableView.userInteractionEnabled = NO;
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [self.navigationController.toolbar setUserInteractionEnabled:NO];
    [self showPlaceHolder:NO];
    [self.loadingView show];
}

- (void)hideLoadingView
{
    [self showPlaceHolder:([self.object.lookList count] == 0)];
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.navigationController.toolbar setUserInteractionEnabled:YES];
    [self.loadingView hide];
}

@end
