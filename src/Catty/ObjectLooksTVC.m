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
#import "UIDefines.h"
#import "TableUtil.h"
#import "CatrobatImageCell.h"
#import "Look.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "SceneViewController.h"
#import "ProgramDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kTableHeaderIdentifier @"Header"
#define kFromCameraActionSheetButton @"camera"
#define kChooseImageActionSheetButton @"chooseImage"
#define kDrawNewImageActionSheetButton @"drawNewImage"

@interface ObjectLooksTVC () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    Look *look = [self.object.lookList objectAtIndex:indexPath.row];
    NSString *imagePath = [self.object pathForLook:look];
    imageCell.iconImageView.image = [[UIImage alloc] initWithContentsOfFile: imagePath];
    imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
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
      if ([destController isKindOfClass:[SceneViewController class]]) {
        SceneViewController* scvc = (SceneViewController*) destController;
        if ([scvc respondsToSelector:@selector(setProgram:)]) {
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
    NSURL *imagePath = info[@"UIImagePickerControllerReferenceURL"];
    NSString *imageFileName = [imagePath lastPathComponent];
    NSArray *fileNameParts = [imageFileName componentsSeparatedByString:@"."];
    NSString *imageName = ([fileNameParts count] ? fileNameParts[0] : imageFileName);

    // save image to programs directory
    // XXX: I do not know whether this fileNamePrefix should be a UUID or any hash string.
    //      Actually the length already equals UUID's length.
    //      But it could also be any hash string since e.g. MD5-strings have the same size too.
    //      ATM I am using UUID.
    // TODO: Fix this unless using UUID is not the right way here, otherwise please delete the comment above until read.
    NSString *fileNamePrefix = [[[NSString uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString];
    NSString *newImageFileName = [NSString stringWithFormat:@"%@_%@", fileNamePrefix, imageFileName];

    // TODO: outsource this to FileManager
    NSString *newImagePath = [NSString stringWithFormat:@"%@%@/%@", [self.object projectPath], kProgramImagesDirName, newImageFileName];
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
      NSData *webData = UIImagePNGRepresentation(image);
      // FIXME: in case of large images this should not run on the main queue
      [webData writeToFile:newImagePath atomically:YES];
    }

    // FIXME: write program to disc...

    // update view
    Look* look = [[Look alloc] initWithName:imageName andPath:newImageFileName];
    [self.object.lookList addObject:look];
    [super showPlaceHolder:([self.object.soundList count] == 0)];
    [self.tableView reloadData];
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
  self.toolbarItems = [NSArray arrayWithObjects:add, flexItem, play, nil];
}

@end
