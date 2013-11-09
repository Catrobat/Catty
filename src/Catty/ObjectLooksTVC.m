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

#import "ObjectLooksTVC.h"
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "CatrobatImageCell.h"
#import "Look.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "ScenePresenterViewController.h"
#import "ProgramDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LoadingView.h"

#define kTableHeaderIdentifier @"Header"
#define kFromCameraActionSheetButton @"camera"
#define kChooseImageActionSheetButton @"chooseImage"
#define kDrawNewImageActionSheetButton @"drawNewImage"

@interface ObjectLooksTVC () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) NSMutableDictionary* addLookActionSheetBtnIndexes;
@end

@implementation ObjectLooksTVC

#pragma getters and setters
- (NSMutableDictionary*)addLookActionSheetBtnIndexes
{
  // lazy instantiation
  if (_addLookActionSheetBtnIndexes == nil)
    _addLookActionSheetBtnIndexes = [NSMutableDictionary dictionaryWithCapacity:3];
  return _addLookActionSheetBtnIndexes;
}

#pragma marks init
- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)initTableView
{
  [super initTableView];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
  headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  [self.tableView addSubview:headerViewTemplate];
}

- (void)dealloc
{
  [self.loadingView removeFromSuperview];
  self.loadingView = nil;
}

#pragma view events
- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  [self initTableView];
  [super initPlaceHolder];
  [super setPlaceHolderTitle:([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)
                 Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil),
                              ([self.object isBackground] ? kBackgroundsTitle : kLooksTitle)]];
  [super showPlaceHolder:(! (BOOL)[self.object.lookList count])];
  //[TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"New Programs", nil)];

  self.title = self.object.name;
  self.navigationItem.title = self.object.name;
  [self setupToolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
  static NSString *CellIdentifier = @"LookCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

  // Configure the cell...
  if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
    UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
    imageCell.iconImageView.image = nil;
    NSString *previewImagePath = [self.object previewImagePathForLookAtIndex:indexPath.row];
    if (previewImagePath) {
      imageCell.iconImageView.image = [[UIImage alloc] initWithContentsOfFile:previewImagePath];
      imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    Look *look = [self.object.lookList objectAtIndex:indexPath.row];
    imageCell.titleLabel.text = look.name;
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [TableUtil getHeightForImageCell];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  static NSString* toSceneSegueID = kSegueToScene;
  UIViewController* destController = segue.destinationViewController;
  if ([sender isKindOfClass:[UIBarButtonItem class]]) {
    if ([segue.identifier isEqualToString:toSceneSegueID]) {
      if ([destController isKindOfClass:[ScenePresenterViewController class]]) {
        ScenePresenterViewController* scvc = (ScenePresenterViewController*) destController;
        if ([scvc respondsToSelector:@selector(setProgram:)]) {
            [scvc setController:(UITableViewController *)self];
          [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
        }
      }
    }
  }
}

#pragma mark - UIImagePicker Handler
- (void) presentImagePicker:(UIImagePickerControllerSourceType)sourceType
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
  [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *image = info[UIImagePickerControllerEditedImage];
  if (! image)
    image = info[UIImagePickerControllerOriginalImage];

  if (image) {
    // add image to object now
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
//    NSString *imageFileName = [imagePath lastPathComponent];
    [self showLoadingView];

    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
      ALAssetRepresentation *representation = [myasset defaultRepresentation];
      NSString *imageFileName = [representation filename];
      NSLog(@"fileName : %@",imageFileName);

      imageFileName = [[imageFileName componentsSeparatedByString:@"."] firstObject];
      if (! [imageFileName length])
        imageFileName = @"default"; // TODO: outsource this constant...
      
      // save image to programs directory
      // XXX: I do not know whether this fileNamePrefix should be a UUID or any hash string.
      //      Actually the length already equals UUID's length.
      //      But it could also be any hash string since e.g. MD5-strings have the same size too.
      //      ATM I am using UUID.
      // TODO: Fix this unless using UUID is not the right way here, otherwise please delete the comment above until read.
      NSString *fileNamePrefix = [[[NSString uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString];
      NSString *newImageFileName = [NSString stringWithFormat:@"%@%@%@", fileNamePrefix, kResourceFileNameSeparator, imageFileName];
      Look* look = [[Look alloc] initWithName:imageFileName andPath:newImageFileName];

      // TODO: outsource this to FileManager
      NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                 [self.object projectPath], kProgramImagesDirName,
                                 newImageFileName];
      NSString *newPreviewImagePath = [NSString stringWithFormat:@"%@%@/%@",
                                        [self.object projectPath], kProgramImagesDirName,
                                        [look previewImageFileName]];
      NSString *mediaType = info[UIImagePickerControllerMediaType];

      NSLog(@"Writing file to disk");
      if ([mediaType isEqualToString:@"public.image"]) {
        // TODO: update program on disc...
        NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
          [UIImagePNGRepresentation(image) writeToFile:newImagePath atomically:YES];

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
        }];

        // Use the completion block to update UI on the main queue
        [saveOp setCompletionBlock:^{
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // update view
            [super showPlaceHolder:NO];
            [self.object.lookList addObject:look];
//            [self.tableView reloadData];
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet.tag == kAddLookActionSheetTag) {
    NSString *action = self.addLookActionSheetBtnIndexes[@(buttonIndex)];
    if ([action isEqualToString:kFromCameraActionSheetButton]) {
      // take picture from camera
      NSLog(@"Accessing camera");
      [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
    } else if ([action isEqualToString:kChooseImageActionSheetButton]) {
      // choose picture from camera roll
      NSLog(@"Choose image from camera roll");
      [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    } else if ([action isEqualToString:kDrawNewImageActionSheetButton]) {
      // draw new image
      // TODO: @all: in android they invoke Pocket Paint.
      // But there is no Pocket Paint App for iOS a.t.m.
      // What to do here??
      NSLog(@"Draw new image");
      [Util showComingSoonAlertView];
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

  self.addLookActionSheetBtnIndexes[@([sheet addButtonWithTitle:NSLocalizedString(@"Draw new image",nil)])] = kDrawNewImageActionSheetButton;
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

#pragma mark - Helper Methods
- (void)addLookAction:(id)sender
{
  [self showAddLookActionSheet];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
  [self.navigationController setToolbarHidden:NO];
  self.navigationController.toolbar.barStyle = UIBarStyleBlack;
  self.navigationController.toolbar.tintColor = [UIColor orangeColor];
  self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
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
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1.png"]];
  UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
  self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem, flexItem,
                       flexItem, flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
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

- (void) hideLoadingView
{
  [self showPlaceHolder:([self.object.lookList count] == 0)];
  self.tableView.scrollEnabled = YES;
  self.tableView.userInteractionEnabled = YES;
  [self.navigationController.navigationBar setUserInteractionEnabled:YES];
  [self.navigationController.toolbar setUserInteractionEnabled:YES];
  [self.loadingView hide];
}

@end
