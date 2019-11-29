/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import <Photos/Photos.h>
#import "UIDefines.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Look.h"
#import "SpriteObject.h"
#import "LookImageViewController.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "NSData+Hashes.h"
#import "AppDelegate.h"
#import "RuntimeImageCache.h"
#import "PlaceHolderView.h"
#import "UIImage+Rotate.h"
#import "ViewControllerDefines.h"
#import "UIUtil.h"
#import "Pocket_Code-Swift.h"

@interface LooksTableViewController () <UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,
                                        UITextFieldDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, assign) NSInteger selectedLookIndex;
@property (nonatomic, assign) BOOL deletionMode;
@property (nonatomic, assign) BOOL copyMode;
@property (nonatomic,strong)NSString *filePath;
@end

@implementation LooksTableViewController

#pragma mark initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
    [self changeEditingBarButtonState];
}

#pragma mark viewloaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsProjectsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsLooksKey];
    self.useDetailCells = [showDetailsProjectsValue boolValue];
    self.title = self.navigationItem.title = (self.object.isBackground
                                              ? kLocalizedBackgrounds
                                              : kLocalizedLooks);
    [self initNavigationBar];
    if (self.object.isBackground) {
        self.placeHolderView.title = kLocalizedTapPlusToAddBackground;
    } else {
        self.placeHolderView.title = kLocalizedTapPlusToAddLook;
    }
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if(self.showAddLookActionSheetAtStartForScriptEditor || self.showAddLookActionSheetAtStartForObject) {
        [self showAddLookActionSheet];
    }
}

#pragma mark viewwillappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    NSString *actionSheetTitle = self.object.isBackground ? kLocalizedEditBackgrounds : kLocalizedEditLooks;
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:actionSheetTitle]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    
    if (self.object.lookList.count) {
        NSString *destructiveActionTitle = self.object.isBackground ? kLocalizedDeleteBackgrounds : kLocalizedDeleteLooks;
        [[actionSheet
         addDestructiveActionWithTitle:destructiveActionTitle handler:^{
             self.deletionMode = YES;
             self.copyMode = NO;
             [self setupEditingToolBar];
             [super changeToEditingMode:sender];
         }]
         addDefaultActionWithTitle:kLocalizedCopyLooks handler:^{
             self.deletionMode = NO;
             self.copyMode = YES;
             [self setupEditingToolBar];
             [super changeToEditingMode:sender];
         }];

    }
    if (self.object.lookList.count >= 2) {
        [actionSheet addDefaultActionWithTitle:kLocalizedMoveLooks handler:^{
            self.deletionMode = NO;
            self.copyMode = NO;
            [super changeToMoveMode:sender];
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
                           forKey:kUserDetailsShowDetailsLooksKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self reloadData];
}

- (void)addLookAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    [self showAddLookActionSheet];
}

- (void)addLookActionWithName:(NSString*)lookName look:(Look*)look
{
    look.name = [Util uniqueName:lookName existingNames:[self.object allLookNames]];
    // rename temporary file name (example: "temp_D41D8CD98F00B204E9800998ECF8427E.png") as well
    NSString *oldPath = [self.object pathForLook:look];
    NSArray *fileNameParts = [look.fileName componentsSeparatedByString:@"."];
    NSString *hash = [[[fileNameParts firstObject] componentsSeparatedByString:kResourceFileNameSeparator] lastObject];
    NSString *fileExtension = [fileNameParts lastObject];
    look.fileName = [NSString stringWithFormat:@"%@%@%@.%@", hash, kResourceFileNameSeparator,
                     look.name, fileExtension];
    NSString *newPath = [self.object pathForLook:look];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager moveExistingFileAtPath:oldPath toPath:newPath overwrite:YES];
    [self.dataCache removeObjectForKey:look.fileName]; // just to ensure
    [self.object addLook:look AndSaveToDisk:YES];

    [self showPlaceHolder:NO];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationBottom];
    
    if(self.afterSafeBlock) {
        self.afterSafeBlock(look);
    }
    [self reloadData];
}

- (void)copySelectedLooksAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    
    NSMutableArray *looksToCopy = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        Look *look = (Look*)[self.object.lookList objectAtIndex:selectedRowIndexPath.row];
        [looksToCopy addObject:look];
    }
    [self copyLooksActionWithSourceLooks:looksToCopy];
    [super exitEditingMode];
}

- (void)copyLooksActionWithSourceLooks:(NSArray<Look *> *)sourceLooks
{
    [self showLoadingView];
    NSMutableArray<NSIndexPath *> *paths = [NSMutableArray arrayWithCapacity:[sourceLooks count]];
    
    for (id look in sourceLooks) {
        if ([look isKindOfClass:[Look class]]) {
            Look *sourceLook = (Look*) look;
            NSString *nameOfCopiedLook = [Util uniqueName:sourceLook.name existingNames:[self.object allLookNames]];
            [self.object copyLook:sourceLook withNameForCopiedLook:nameOfCopiedLook AndSaveToDisk:YES];
            
            NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
            [paths addObject:indexPath];
        }
    }
    
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    [self hideLoadingView];
}

- (void)renameLookActionToName:(NSString*)newLookName look:(Look*)look
{
    if ([newLookName isEqualToString:look.name])
        return;

    [self showLoadingView];
    newLookName = [Util uniqueName:newLookName existingNames:[self.object allLookNames]];
    [self.object renameLook:look toName:newLookName AndSaveToDisk:YES];
    NSUInteger lookIndex = [self.object.lookList indexOfObject:look];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lookIndex inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self hideLoadingView];
}

- (void)confirmDeleteSelectedLooksAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedLooksAction];
}

- (void)deleteSelectedLooksAction
{
    [self showLoadingView];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *looksToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        Look *look = (Look*)[self.object.lookList objectAtIndex:selectedRowIndexPath.row];
        [looksToRemove addObject:look];
        [self.dataCache removeObjectForKey:look.fileName];
    }
    [self.object removeLooks:looksToRemove AndSaveToDisk:YES];
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
    [self hideLoadingView];
}

- (void)deleteLookForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    Look *look = (Look*)[self.object.lookList objectAtIndex:indexPath.row];
    [self.dataCache removeObjectForKey:look.fileName];
    [self.object removeLook:look AndSaveToDisk:YES];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self showPlaceHolder:(! (BOOL)[self.object.lookList count])];
    [self hideLoadingView];
    [self reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.object.lookList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
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
                                                  thumbnailFrameSize:CGSizeMake(kPreviewThumbnailWidth, kPreviewThumbnailHeight)
                                                   onCompletion:^(UIImage *img, NSString* path){
                                                       // check if cell still needed
                                                       if ([imageCell.indexPath isEqual:indexPath]) {
                                                           imageCell.iconImageView.image = img;
                                                           [imageCell setNeedsLayout];
                                                       }
                                                   }];
    } else {
        imageCell.iconImageView.image = image;
    }
    imageCell.titleLabel.text = look.name;

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedMeasure];
        detailCell.topRightDetailLabel.textColor = UIColor.textTint;

        NSValue *value = [self.dataCache objectForKey:look.fileName];
        CGSize dimensions;
        if (! value) {
            dimensions = [self.object dimensionsOfLook:look];
            [self.dataCache setObject:[NSValue valueWithCGSize:dimensions] forKey:look.fileName];
        } else {
            dimensions = [value CGSizeValue];
        }
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%lux%lu",
                                               (unsigned long)dimensions.width,
                                               (unsigned long)dimensions.height];
        detailCell.bottomLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = UIColor.textTint;
        NSUInteger resultSize = [self.object fileSizeOfLook:look];
        NSNumber *sizeOfSound = [NSNumber numberWithUnsignedInteger:resultSize];
        detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[sizeOfSound unsignedIntegerValue]
                                                                                countStyle:NSByteCountFormatterCountStyleBinary];
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

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.deletionMode || self.copyMode){
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Look* itemToMove = self.object.lookList[sourceIndexPath.row];
    [self.object.lookList removeObjectAtIndex:sourceIndexPath.row];
    [self.object.lookList insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.object.project saveToDiskWithNotification:NO];
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        NSString *actionSheetTitle = self.object.isBackground ? kLocalizedEditBackground : kLocalizedEditLook;
        
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:actionSheetTitle]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             [self copyLooksActionWithSourceLooks:@[[self.object.lookList objectAtIndex:indexPath.row]]];
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             Look *look = [self.object.lookList objectAtIndex:indexPath.row];
             [Util askUserForTextAndPerformAction:@selector(renameLookActionToName:look:)
                                           target:self
                                     cancelAction:nil
                                       withObject:look
                                      promptTitle:kLocalizedRenameImage
                                    promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedImageName]
                                      promptValue:look.name
                                promptPlaceholder:kLocalizedEnterYourImageNameHere
                                   minInputLength:kMinNumOfLookNameCharacters
                                   maxInputLength:kMaxNumOfLookNameCharacters
                         invalidInputAlertMessage:kLocalizedInvalidImageNameDescription];
         }] build]
         viewWillDisappear:^{
             [tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = UIColor.globalTint;
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        NSString *alertTitle = (self.object.isBackground ? kLocalizedDeleteThisBackground : kLocalizedDeleteThisLook);
        [[[[[AlertControllerBuilder alertWithTitle:alertTitle message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteLookForIndexPath:indexPath];
         }] build]
         showWithController:self];
    }];
    return @[deleteAction, moreAction];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
  return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    static NSString *segueToImage = kSegueToImage;
    if (! self.editing) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        PaintViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:kPaintViewControllerIdentifier];
        vc.delegate = self;
        self.selectedLookIndex = indexPath.row;
        NSString *lookImagePath = [self.object pathForLook:[self.object.lookList objectAtIndex:self.selectedLookIndex]];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:lookImagePath];
        vc.editingImage = image;
        vc.editingPath = lookImagePath;
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        [self.navigationController pushViewController:vc animated:YES];
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
    picker.allowsEditing = NO;
    picker.delegate = self;
    picker.navigationBar.tintColor = UIColor.navTint;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.showAddLookActionSheetAtStartForScriptEditor || self.showAddLookActionSheetAtStartForObject){
        if (self.afterSafeBlock) {
            self.afterSafeBlock(nil);
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // executed on the main queue
    [self dismissViewControllerAnimated:NO completion:^{
        [self showLoadingView];
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (! image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        image = [image fixOrientation];
        if (!image) {
            [self hideLoadingView];
            return; 
        }
        image = [UIImage imageWithImage:image
                       scaledToMaxWidth:[Util screenWidth]
                              maxHeight:[Util screenHeight]];
        
        // add image to object now
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        NSDebug(@"Writing file to disk");
        if ([mediaType isEqualToString:@"public.image"]) {
            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
                PHAsset *asset;
                if (result != nil && result.count > 0) {
                    // get last photo from Photos
                    asset = [result lastObject];
                }
                if (asset) {
                    // get photo info from this asset IOS8 hack?!
                    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
                    imageRequestOptions.synchronous = YES;
                    [[PHImageManager defaultManager]
                     requestImageDataForAsset:asset
                     options:imageRequestOptions
                     resultHandler:^(NSData *imageData, NSString *dataUTI,
                                     UIImageOrientation orientation,
                                     NSDictionary *info)
                     {
                         if ([info objectForKey:@"PHImageFileURLKey"]) {
                             NSURL *path = [info objectForKey:@"PHImageFileURLKey"];
                             NSString* imageFileName = [path lastPathComponent];
                             NSArray *imageFileNameParts = [imageFileName componentsSeparatedByString:@"."];
                             imageFileName = [imageFileNameParts firstObject];
                             NSString *imageFileNameExtension = [imageFileNameParts lastObject];
                             [self saveImageData:imageData withFileName:imageFileName andImageFileNameExtension:imageFileNameExtension];
                         } else {
                             [self saveImageData:imageData withFileName:@"" andImageFileNameExtension:@""];
                         }
                     }];
                }
            } else if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
                NSData *imageData = UIImagePNGRepresentation(image);
                [self saveImageData:imageData withFileName:@"" andImageFileNameExtension:@""];
            }
        }
        [self hideLoadingView];
    }];
}


-(void)saveImageData:(NSData*)imageData withFileName:(NSString*)imageFileName andImageFileNameExtension:(NSString*)imageFileNameExtension
{
    if ((! [imageFileName length])) {
        imageFileName = kLocalizedMyImage;
        imageFileNameExtension = kLocalizedMyImageExtension;
    }
    NSString *lookName = imageFileName;
    // use temporary filename, will be renamed by user afterwards
    NSString *newImageFileName = [NSString stringWithFormat:@"temp_%@.%@",
                                  [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                                  imageFileNameExtension];
    Look *look = [[Look alloc] initWithName:[Util uniqueName:lookName
                                               existingNames:[self.object allLookNames]]
                                    andPath:newImageFileName];
    
    NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                              [self.object projectPath], kProjectImagesDirName, newImageFileName];
    self.filePath = newImagePath;
    // leaving the main queue here!
    [imageData writeToFile:newImagePath atomically:YES];
    
    [self hideLoadingView];
    [self showPlaceHolder:([self.object.lookList count] == 0)];
    if (self.showAddLookActionSheetAtStartForObject) {
        [self addLookActionWithName:look.name look:look];
    } else {
        // ask user for image name
        [Util askUserForTextAndPerformAction:@selector(addLookActionWithName:look:)
                                      target:self
                                cancelAction:@selector(cancelPaintSave)
                                  withObject:look
                                 promptTitle:kLocalizedAddImage
                               promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedImageName]
                                 promptValue:look.name
                           promptPlaceholder:kLocalizedEnterYourImageNameHere
                              minInputLength:kMinNumOfLookNameCharacters
                              maxInputLength:kMaxNumOfLookNameCharacters
                    invalidInputAlertMessage:kLocalizedInvalidImageNameDescription];
    }
}

#pragma mark - text field delegates
- (BOOL)textField:(UITextField*)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)characters
{
    return [characters length] <= kMaxNumOfLookNameCharacters;
}

#pragma mark - action sheet
- (void)showAddLookActionSheet
{
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedAddLook]
                                               addCancelActionWithTitle:kLocalizedCancel handler:^{
                                                   if (self.showAddLookActionSheetAtStartForObject || self.showAddLookActionSheetAtStartForScriptEditor) {
                                                       SAFE_BLOCK_CALL(self.afterSafeBlock, nil);
                                                   }
                                               }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            [actionSheet addDefaultActionWithTitle:kLocalizedFromCamera handler:^{
                if (![self checkUserAuthorisation:UIImagePickerControllerSourceTypeCamera]) {
                    return;
                }
                // Authorization status determined
                if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
                    [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
                } else {
                    [self suggestToOpenSettingsAppWithMessage:kLocalizedNoAccesToCameraCheckSettingsDescription];
                }
            }];
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            [actionSheet addDefaultActionWithTitle:kLocalizedChooseImage handler:^{
                if (![self checkUserAuthorisation:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    return;
                }
                // Authorization status determined
                if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                    [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                } else {
                    [self suggestToOpenSettingsAppWithMessage:kLocalizedNoAccesToImagesCheckSettingsDescription];
                }
            }];
        }
    }
    
    [[[[actionSheet
     addDefaultActionWithTitle:kLocalizedDrawNewImage handler:^{
         dispatch_async(dispatch_get_main_queue(), ^{
             PaintViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:kPaintViewControllerIdentifier];
             vc.delegate = self;
             vc.editingPath = nil;
             vc.projectHeight = self.object.project.header.screenHeight.floatValue;
             vc.projectWidth = self.object.project.header.screenWidth.floatValue;
             NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
             [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
             [self.navigationController pushViewController:vc animated:YES];
         });
     }]
     addDefaultActionWithTitle:kLocalizedMediaLibrary handler:^{
         dispatch_async(dispatch_get_main_queue(), ^{
             if (self.object.isBackground) {
                 [self showBackgroundsMediaLibrary];
             } else {
                 [self showLooksMediaLibrary];
             }
         });
     }] build]
     showWithController:self];
}

- (void)suggestToOpenSettingsAppWithMessage:(NSString *)message {
    [[[[[AlertControllerBuilder alertWithTitle:nil message:message]
     addCancelActionWithTitle:kLocalizedCancel handler:nil]
     addDefaultActionWithTitle:kLocalizedSettings handler:^{
           NSDebug(@"Settings Action");
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
     }] build]
     showWithController:self completion: ^{
         if (self.showAddLookActionSheetAtStartForObject || self.showAddLookActionSheetAtStartForScriptEditor) {
             if (self.afterSafeBlock) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.afterSafeBlock(nil);
                 });
             }
         }
     }];
}

#pragma mark - helpers
- (void)setupToolBar
{
    [super setupToolBar];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addLookAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: flex, add, flex, flex, play, flex, nil];
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];

    UIBarButtonItem *editActionButton;
    if (self.deletionMode){
        editActionButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(confirmDeleteSelectedLooksAction:)];
    } else{
        editActionButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCopy
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(copySelectedLooksAction:)];
    }
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, flex, editActionButton, nil];
}

#pragma mark paintDelegate

- (void)showSavePaintImageAlert:(UIImage *)image andPath:(NSString *)path
{
    [[[[[AlertControllerBuilder alertWithTitle:kLocalizedSaveToPocketCode message:kLocalizedPaintSaveChanges]
     addCancelActionWithTitle:kLocalizedCancel handler:^{
         [self cancelPaintSave];
     }]
     addDefaultActionWithTitle:kLocalizedYes handler:^{
         [self savePaintImage:image andPath:path];
     }] build]
     showWithController:self];
}


- (void)savePaintImage:(UIImage *)image andPath:(NSString *)path
{
    if (image) {
        [self addPaintedImage:image andPath:path];
    } else if (self.showAddLookActionSheetAtStartForObject || self.showAddLookActionSheetAtStartForScriptEditor) {
        SAFE_BLOCK_CALL(self.afterSafeBlock, nil);
    }
}

- (void)cancelPaintSave
{
    if (self.showAddLookActionSheetAtStartForObject || self.showAddLookActionSheetAtStartForScriptEditor){
        if (self.afterSafeBlock) {
            self.afterSafeBlock(nil);
        }
    }
    if (self.filePath && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    }
}

- (void)addMediaLibraryLoadedImage:(UIImage *)image withName:(NSString *)lookName
{
    NSDebug(@"SAVING");  // add image to object now
    [self showLoadingView];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // use temporary filename, will be renamed by user afterwards
    NSString *newImageFileName = [NSString stringWithFormat:@"temp_%@.%@",
                                  [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                                  kLocalizedMyImageExtension];
    Look *look = [[Look alloc] initWithName:[Util uniqueName:lookName
                                               existingNames:[self.object allLookNames]]
                                    andPath:newImageFileName];
    NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                              [self.object projectPath], kProjectImagesDirName, newImageFileName];
    self.filePath = newImagePath;
    NSDebug(@"Writing file to disk");
    
    [imageData writeToFile:newImagePath atomically:YES];
    [self hideLoadingView];
    [self showPlaceHolder:([self.object.lookList count] == 0)];
    
    [self addLookActionWithName:look.name look:look];

    [self reloadData];
}


- (void)addPaintedImage:(UIImage *)image andPath:(NSString *)path
{
    UIImage *checkImage = [[UIImage alloc] initWithContentsOfFile:path];
    if (checkImage) {
//        NSDebug(@"Updating");
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *imageDirPath = [[self.object projectPath] stringByAppendingString:kProjectImagesDirName];
        NSString *fileName = [path stringByReplacingOccurrencesOfString:imageDirPath withString:@""];
        
        NSRange result = [fileName rangeOfString:kResourceFileNameSeparator];
        if ((result.location == NSNotFound) || (result.location == 0) || (result.location >= ([fileName length]-1))){
            abort();
            return;
        }


        NSUInteger referenceCount = [self.object referenceCountForLook:[fileName substringFromIndex:1]];
        if(referenceCount > 1) {
            Look *look = [self.object.lookList objectAtIndex:self.selectedLookIndex];
            NSString *newImageFileName = [NSString stringWithFormat:@"%@_%@.%@",
                                          [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                                          look.name,
                                          kLocalizedMyImageExtension];
            path = [path stringByReplacingOccurrencesOfString:[fileName substringFromIndex:1] withString:newImageFileName];
            fileName = newImageFileName;
            look.fileName = fileName;
        }
        
        NSDebug(@"Writing file to disk");
        [imageData writeToFile:path atomically:YES];
        [self.object.project saveToDiskWithNotification:YES];
        
        RuntimeImageCache *cache = [RuntimeImageCache sharedImageCache];
        
        NSString *previewImageName =  [NSString stringWithFormat:@"%@%@%@",
                                       [fileName substringToIndex:result.location+1],
                                       kPreviewImageNamePrefix,
                                       [fileName substringFromIndex:(result.location+1)]
                                       ];
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", imageDirPath, previewImageName];
        [cache overwriteThumbnailImageFromDiskWithThumbnailPath:filePath image:image thumbnailFrameSize:CGSizeMake(kPreviewThumbnailWidth, kPreviewThumbnailHeight)];
        
        
        [cache replaceImage:image withName:filePath];
    } else {
          NSDebug(@"SAVING");  // add image to object now
        [self showLoadingView];
        
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *lookName = kLocalizedLookFilename;
            // use temporary filename, will be renamed by user afterwards
        NSString *newImageFileName = [NSString stringWithFormat:@"temp_%@.%@",
                                      [[[imageData md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                                      kLocalizedMyImageExtension];
        Look *look = [[Look alloc] initWithName:[Util uniqueName:lookName
                                                   existingNames:[self.object allLookNames]]
                                        andPath:newImageFileName];
        NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                  [self.object projectPath], kProjectImagesDirName, newImageFileName];
        self.filePath = newImagePath;
        NSDebug(@"Writing file to disk");
        [imageData writeToFile:newImagePath atomically:YES];
        [self hideLoadingView];
        [self showPlaceHolder:([self.object.lookList count] == 0)];
        
        // ask user for image name
        if (self.showAddLookActionSheetAtStartForObject) {
            [self addLookActionWithName:look.name look:look];
        } else if (path){
            [self addLookActionWithName:@"settings_save" look:look];
        } else {
            [Util askUserForTextAndPerformAction:@selector(addLookActionWithName:look:)
                                          target:self
                                    cancelAction:@selector(cancelPaintSave)
                                      withObject:look
                                     promptTitle:kLocalizedAddImage
                                   promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedImageName]
                                     promptValue:look.name
                               promptPlaceholder:kLocalizedEnterYourImageNameHere
                                  minInputLength:kMinNumOfLookNameCharacters
                                  maxInputLength:kMaxNumOfLookNameCharacters
                        invalidInputAlertMessage:kLocalizedInvalidImageNameDescription];
        }
    }
    [self reloadData];
}

- (BOOL)checkUserAuthorisation:(UIImagePickerControllerSourceType)pickerType
{
    
    BOOL state = NO;
    
    if(pickerType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                        [self presentImagePicker:pickerType];
                        break;
                    case PHAuthorizationStatusRestricted:
                        break;
                    case PHAuthorizationStatusDenied:
                        break;
                    default:
                        break;
                }
            }];
        }else{
          state = YES;
        }
    }else if (pickerType == UIImagePickerControllerSourceTypeCamera)
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    [self presentImagePicker:pickerType];
                    return;
                }
            }];
        }else{
            state = YES;
        }
    }
    return state;
}

- (void)changeEditingBarButtonState
{
    if (self.object.lookList.count >= 1) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)reloadData
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
        [self changeEditingBarButtonState];
    });
}

@end
