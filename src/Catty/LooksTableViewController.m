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
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSData+Hashes.h"
#import "LoadingView.h"

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsLooksKey @"detailsForLooks"

#define kFromCameraActionSheetButton @"camera"
#define kChooseImageActionSheetButton @"chooseImage"
#define kDrawNewImageActionSheetButton @"drawNewImage"

@interface ObjectLooksTableViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (strong, nonatomic) NSMutableDictionary *imageCache; // NONatomic, only (!) accessed via main queue = serial (!) queue
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) NSMutableDictionary* addLookActionSheetBtnIndexes;
@end

@implementation ObjectLooksTableViewController

#pragma getters and setters
- (NSMutableDictionary*)addLookActionSheetBtnIndexes
{
    // lazy instantiation
    if (_addLookActionSheetBtnIndexes == nil)
        _addLookActionSheetBtnIndexes = [NSMutableDictionary dictionaryWithCapacity:3];
    return _addLookActionSheetBtnIndexes;
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma - events
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsProgramsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsLooksKey];
    self.useDetailCells = [showDetailsProgramsValue boolValue];
    self.title = self.navigationItem.title = NSLocalizedString(@"Looks", nil);
    [self initNavigationBar];
    [super initTableView];
    [super initPlaceHolder];

    [super setPlaceHolderTitle:([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)
                   Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil),
                                ([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)]];
    [super showPlaceHolder:(! (BOOL)[self.object.lookList count])];
    [self setupToolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.imageCache = nil;
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    if ([self.object.lookList count]) {
        [options addObject:NSLocalizedString(@"Delete Looks",nil)];
    }
    if (self.useDetailCells) {
        [options addObject:NSLocalizedString(@"Hide Details",nil)];
    } else {
        [options addObject:NSLocalizedString(@"Show Details",nil)];
    }
    [Util actionSheetWithTitle:NSLocalizedString(@"Edit Looks",nil)
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditLooksActionSheetTag
                          view:self.view];
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
                                       ? kConfirmTitleDeleteLooks : kConfirmTitleDeleteLook)
                       confirmMessage:kConfirmMessageDelete];
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
    self.imageCache = nil;
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.lookList count])];
}

- (void)deleteLookForIndexPath:(NSIndexPath*)indexPath
{
    Look *look = (Look*)[self.object.lookList objectAtIndex:indexPath.row];
    [self.imageCache removeObjectForKey:@(indexPath.row)];
    [self.object removeLook:look];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.lookList count])];
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
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }

    UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
    Look *look = [self.object.lookList objectAtIndex:indexPath.row];
    imageCell.iconImageView.image = nil;
    [imageCell.iconImageView setBorder:[UIColor skyBlueColor] Width:kDefaultImageCellBorderWidth];
    NSString *previewImagePath = [self.object previewImagePathForLookAtIndex:indexPath.row];
    NSNumber *indexAsNumber = @(indexPath.row);
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
                NSString *newPreviewImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                                 [self.object projectPath], kProgramImagesDirName,
                                                 [look previewImageFileName]];

                NSString *imagePath = [NSString stringWithFormat:@"%@%@/%@",
                                       [self.object projectPath], kProgramImagesDirName,
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
    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        // TODO: enhancement: use data cache for this later...
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:",
                                              NSLocalizedString(@"Measure", nil)];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        CGSize dimensions = [self.object dimensionsOfLook:look];
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%lux%lu",
                                               (unsigned long)dimensions.width,
                                               (unsigned long)dimensions.height];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:",
                                                 NSLocalizedString(@"Size", nil)];
        detailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];
        NSUInteger resultSize = [self.object fileSizeOfLook:look];
        NSNumber *sizeOfSound = [NSNumber numberWithUnsignedInteger:resultSize];
        detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[sizeOfSound unsignedIntegerValue]
                                                                                countStyle:NSByteCountFormatterCountStyleBinary];
    }
    imageCell.titleLabel.text = look.name;
    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [TableUtil getHeightForImageCell];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self performActionOnConfirmation:@selector(deleteLookForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kConfirmTitleDeleteLook
                           confirmMessage:kConfirmMessageDelete];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* segueToSceneIdentifier = kSegueToScene;
    static NSString* segueToImage1Identifier = kSegueToImage1;
    static NSString* segueToImage2Identifier = kSegueToImage2;
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
        if ([segue.identifier isEqualToString:segueToImage1Identifier] || [segue.identifier isEqualToString:segueToImage2Identifier]) {
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
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (! image) {
        image = info[UIImagePickerControllerOriginalImage];
    }

    if (image) {
        // add image to object now
        NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        [self showLoadingView];

        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            NSString *imageFileName = [representation filename];
            NSLog(@"fileName: %@",imageFileName);

            imageFileName = [[imageFileName componentsSeparatedByString:@"."] firstObject];
            if (! [imageFileName length])
                imageFileName = kDefaultImportedImageName;

            // save image to programs directory
            NSData *imageData = UIImagePNGRepresentation(image);
            NSString *fileNamePrefix = [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString];
            NSString *lookName = imageFileName;
            NSString *newImageFileName = [NSString stringWithFormat:@"%@%@%@", fileNamePrefix, kResourceFileNameSeparator, imageFileName];

            // get all look names of that object
            NSMutableArray *lookNames = [NSMutableArray arrayWithCapacity:[self.object.lookList count]];
            for (Look *look in self.object.lookList) {
                [lookNames addObject:look.name];
            }
            Look *look = [[Look alloc] initWithName:[Util uniqueName:lookName existingNames:lookNames] andPath:newImageFileName];
            NSLog(@"FilePath: %@", newImageFileName);

            // TODO: outsource this to FileManager
            NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                      [self.object projectPath], kProgramImagesDirName,
                                      newImageFileName];
            NSString *mediaType = info[UIImagePickerControllerMediaType];

            NSLog(@"Writing file to disk");
            if ([mediaType isEqualToString:@"public.image"]) {
                // TODO: update program on disc...
                NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
                    [imageData writeToFile:newImagePath atomically:YES];
                }];

                // Use the completion block to update UI on the main queue
                [saveOp setCompletionBlock:^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        // update view
                        [super showPlaceHolder:NO];
                        [self.object.lookList addObject:look];
                        [self hideLoadingView];
                        NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                              withRowAnimation:UITableViewRowAnimationFade];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate Handlers
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
        NSString *action = self.addLookActionSheetBtnIndexes[@(buttonIndex)];
        if ([action isEqualToString:kFromCameraActionSheetButton]) {
            // take picture from camera
            NSLog(@"Accessing camera");
            [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
        } else if ([action isEqualToString:kChooseImageActionSheetButton]) {
            // choose picture from camera roll
            NSLog(@"Choose image from camera roll");
            [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

            // TODO: implement this after Pocket Paint is fully integrated
//        } else if ([action isEqualToString:kDrawNewImageActionSheetButton]) {
//            // draw new image
//            NSLog(@"Draw new image");
//            [Util showComingSoonAlertView];
        }
    }
}

#pragma mark - UIActionSheet Views
- (void)showAddLookActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = NSLocalizedString(@"Add look",@"Action sheet menu title");
    sheet.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage])
            self.addLookActionSheetBtnIndexes[@([sheet addButtonWithTitle:NSLocalizedString(@"From Camera",nil)])] = kFromCameraActionSheetButton;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage])
            self.addLookActionSheetBtnIndexes[@([sheet addButtonWithTitle:NSLocalizedString(@"Choose image",nil)])] = kChooseImageActionSheetButton;
    }

//    self.addLookActionSheetBtnIndexes[@([sheet addButtonWithTitle:NSLocalizedString(@"Draw new image",nil)])] = kDrawNewImageActionSheetButton;
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:kBtnCancelTitle];
    sheet.tag = kAddLookActionSheetTag;
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.view];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // this line forces to hide the status bar when UIImagePickerController is shown
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
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
