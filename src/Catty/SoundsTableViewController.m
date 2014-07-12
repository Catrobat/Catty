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

#import "SoundsTableViewController.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "Sound.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "ScenePresenterViewController.h"
#import "SpriteObject.h"
#import "AudioManager.h"
#import "ProgramDefines.h"
#import "Util.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "SoundPickerTableViewController.h"
#import "NSData+Hashes.h"
#import <AVFoundation/AVFoundation.h>
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"
#import "SharkfoodMuteSwitchDetector.h"

// TODO: outsource...
#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserDetailsShowDetailsSoundsKey @"detailsForSounds"

#define kPocketCodeRecorderActionSheetButton @"pocketCodeRecorder"
#define kSelectMusicTrackActionSheetButton @"selectMusicTrack"

@interface SoundsTableViewController () <UIActionSheetDelegate, AVAudioPlayerDelegate, SWTableViewCellDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (nonatomic, strong) NSMutableDictionary* addSoundActionSheetBtnIndexes;
@property (atomic, strong) Sound *currentPlayingSong;
@property (atomic, weak) UITableViewCell<CatrobatImageCell> *currentPlayingSongCell;
@property (nonatomic, strong) SharkfoodMuteSwitchDetector *silentDetector;

@end

@implementation SoundsTableViewController

#pragma mark - getters and setters
- (NSMutableDictionary*)addSoundActionSheetBtnIndexes
{
    if (_addSoundActionSheetBtnIndexes == nil)
        _addSoundActionSheetBtnIndexes = [NSMutableDictionary dictionaryWithCapacity:3];
    return _addSoundActionSheetBtnIndexes;
}

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma mark - events
- (void)viewDidLoad
{
    [super viewDidLoad];

    // automatically stop current playing sound after the user turns
    // on the silent switcher on the iPhone/iPad (device is in silent state)
    self.silentDetector = [SharkfoodMuteSwitchDetector shared];
    // must be weak (!!) since SoundsTableViewController is holding the SharkfoodMuteSwitchDetector
    // instance strongly!
    __weak SoundsTableViewController *soundsTableViewController = self;
    self.silentDetector.silentNotify = ^(BOOL silent){
        if (silent) {
            [soundsTableViewController stopAllSounds];
        }
    };

    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsSoundsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsSoundsKey];
    self.useDetailCells = [showDetailsSoundsValue boolValue];
    self.navigationController.title = self.title = kUIViewControllerTitleSounds;
    [self initNavigationBar];
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
    self.placeHolderView.title = kUIViewControllerPlaceholderTitleSounds;
    [self showPlaceHolder:(! (BOOL)[self.object.soundList count])];
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(soundAdded:) name:kSoundAddedNotification object:nil];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self name:kSoundAddedNotification object:nil];
    self.currentPlayingSongCell = nil;
    [self stopAllSounds];
}

#pragma mark - notification
- (void)soundAdded:(NSNotification*)notification
{
    if (notification.userInfo) {
        NSLog(@"soundAdded notification received with userInfo: %@", [notification.userInfo description]);
        id sound = notification.userInfo[kUserInfoSound];
        if ([sound isKindOfClass:[Sound class]]) {
            [self addSoundToObjectAction:(Sound*)sound];
        }
    }
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    NSMutableArray *options = [NSMutableArray array];
    if ([self.object.soundList count]) {
        [options addObject:kUIActionSheetButtonTitleDeleteSounds];
    }
    if (self.useDetailCells) {
        [options addObject:kUIActionSheetButtonTitleHideDetails];
    } else {
        [options addObject:kUIActionSheetButtonTitleShowDetails];
    }
    [Util actionSheetWithTitle:kUIActionSheetTitleEditSounds
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditSoundsActionSheetTag
                          view:self.view];
}

- (void)addSoundToObjectAction:(Sound*)sound
{
    NSMutableArray *soundNames = [NSMutableArray arrayWithCapacity:[self.object.soundList count]];
    for (Sound *currentSound in self.object.soundList) {
        [soundNames addObject:currentSound.name];
    }
    sound.name = [Util uniqueName:sound.name existingNames:soundNames];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *oldPath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, sound.fileName];
    NSData *data = [NSData dataWithContentsOfFile:oldPath];
    NSString *newFileName = [NSString stringWithFormat:@"%@%@%@", [data md5], kResourceFileNameSeparator, sound.fileName];
    sound.fileName = newFileName;
    NSString *newPath = [self.object pathForSound:sound];
    [delegate.fileManager copyExistingFileAtPath:oldPath toPath:newPath overwrite:YES];
    [self.object.soundList addObject:sound];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    [self showPlaceHolder:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)confirmDeleteSelectedSoundsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self performActionOnConfirmation:@selector(deleteSelectedSoundsAction)
                       canceledAction:@selector(exitEditingMode)
                               target:self
                         confirmTitle:(([selectedRowsIndexPaths count] != 1)
                                       ? kUIAlertViewTitleDeleteMultipleSounds
                                       : kUIAlertViewTitleDeleteSingleSound)
                       confirmMessage:kUIAlertViewMessageIrreversibleAction];
}

- (void)deleteSelectedSoundsAction
{
    [self stopAllSounds];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *soundsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        Sound *sound = (Sound*)[self.object.soundList objectAtIndex:selectedRowIndexPath.row];
        [soundsToRemove addObject:sound];
    }
    for (Sound *soundToRemove in soundsToRemove) {
        [self.object removeSound:soundToRemove];
    }
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.soundList count])];
}

- (void)deleteSoundForIndexPath:(NSIndexPath*)indexPath
{
    [self stopAllSounds];
    Sound *sound = (Sound*)[self.object.soundList objectAtIndex:indexPath.row];
    [self.object removeSound:sound];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.soundList count])];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.object.soundList count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    static NSString *DetailCellIdentifier = kDetailImageCell;
    UITableViewCell *cell = nil;
    if (! self.useDetailCells) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    }

    Sound *sound = (Sound*)[self.object.soundList objectAtIndex:indexPath.row];
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)] || ! [cell isKindOfClass:[CatrobatBaseCell class]]) {
        return cell;
    }
    CatrobatBaseCell<CatrobatImageCell>* imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    imageCell.rightUtilityButtons = @[[Util slideViewButtonMore], [Util slideViewButtonDelete]];
    imageCell.delegate = self;
    imageCell.indexPath = indexPath;

    static NSString *playIconName = @"ic_media_play";
    static NSString *stopIconName = @"ic_media_pause";

    // determine right icon, therefore check if this song is played currently
    NSString *rightIconName = playIconName;
    @synchronized(self) {
        if (sound.isPlaying && [self.currentPlayingSong.name isEqual:sound.name]) {
            rightIconName = stopIconName;
        }
    }

    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    UIImage *image = [imageCache cachedImageForName:rightIconName];
    if (! image) {
        [imageCache loadImageWithName:rightIconName
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

    imageCell.titleLabel.text = sound.name;
    imageCell.iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound:)];
    tapped.numberOfTapsRequired = 1;
    [imageCell.iconImageView addGestureRecognizer:tapped];

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        // TODO: enhancement: use data cache for this later...
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextLength];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%.02fs",
                                               (float)[self.object durationOfSound:sound]];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kUILabelTextSize];
        detailCell.bottomRightDetailLabel.textColor = [UIColor whiteColor];
        NSUInteger resultSize = [self.object fileSizeOfSound:sound];
        NSNumber *sizeOfSound = [NSNumber numberWithUnsignedInteger:resultSize];
        detailCell.bottomRightDetailLabel.text = [NSByteCountFormatter stringFromByteCount:[sizeOfSound unsignedIntegerValue]
                                                                                countStyle:NSByteCountFormatterCountStyleBinary];
        return detailCell;
    }
    return imageCell;
}

#pragma mark - player actions
- (void)playSound:(id)sender
{
    // TODO: too many nested codeblocks...
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if ([gesture.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView*)gesture.view;
        CGPoint position = [imageView convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
            if (indexPath.row < [self.object.soundList count]) {
                // acquire lock
                @synchronized(self) {
                    if (self.silentDetector.isMute) {
                        [Util alertWithText:(IS_IPHONE ? kUIAlertViewMessageDeviceIsInMutedStateIPhone
                                                       : kUIAlertViewMessageDeviceIsInMutedStateIPad)];
                        return;
                    }
                    Sound *sound = (Sound*)[self.object.soundList objectAtIndex:indexPath.row];
                    BOOL isPlaying = sound.isPlaying;
                    if (self.currentPlayingSong && self.currentPlayingSongCell) {
                        self.currentPlayingSong.playing = NO;
                        self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"ic_media_play"];
                    }
                    self.currentPlayingSong = sound;
                    self.currentPlayingSongCell = imageCell;
                    self.currentPlayingSong.playing = (! isPlaying);
                    self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"ic_media_play"];
                    if (! isPlaying)
                        imageCell.iconImageView.image = [UIImage imageNamed:@"ic_media_pause"];

                    // ASYNC !! lock lost here...
                    // acquire new lock, because this part is executed asynchronously (!) on another thread
                    dispatch_queue_t queue = dispatch_queue_create("at.tugraz.ist.catrobat.PlaySoundTVCQueue", NULL);
                    dispatch_async(queue, ^{
                        @synchronized(self) {
                            [[AudioManager sharedAudioManager] stopAllSounds];
                            if (! isPlaying) {
                                BOOL isPlayable = [[AudioManager sharedAudioManager] playSoundWithFileName:sound.fileName
                                                                                                    andKey:self.object.name
                                                                                                atFilePath:[NSString stringWithFormat:@"%@%@", [self.object projectPath], kProgramSoundsDirName]
                                                                                                  delegate:self];
                                if (! isPlayable) {
                                    // SYNC !! so lock is not lost => busy waiting in PlaySoundTVCQueue
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [Util alertWithText:kUIAlertViewMessageUnableToPlaySound];
                                        [self stopAllSounds];
                                    });
                                }
                            }
                        }
                    });
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [TableUtil getHeightForImageCell];
}

#pragma mark - swipe delegates
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index == 0) {
        // More button was pressed
        UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                            message:@"More more more"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
        [alertTest show];
        [cell hideUtilityButtonsAnimated:YES];
    } else if (index == 1) {
        // Delete button was pressed
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [cell hideUtilityButtonsAnimated:YES];
        [self performActionOnConfirmation:@selector(deleteSoundForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kUIAlertViewTitleDeleteSingleSound
                           confirmMessage:kUIAlertViewMessageIrreversibleAction];
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma audio delegate methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
    if ((! flag) || (! self.currentPlayingSong) || (! self.currentPlayingSongCell)) {
        return;
    }

    @synchronized(self) {
        Sound *currentPlayingSong = self.currentPlayingSong;
        UITableViewCell<CatrobatImageCell> *currentPlayingSongCell = self.currentPlayingSongCell;
        self.currentPlayingSong.playing = NO;
        self.currentPlayingSong = nil;
        self.currentPlayingSongCell = nil;

        static NSString *playIconName = @"ic_media_play";
        RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
        UIImage *image = [imageCache cachedImageForName:playIconName];

        if (! image) {
            [imageCache loadImageWithName:playIconName
                             onCompletion:^(UIImage *image){
                                 // check if user tapped again on this song in the meantime...
                                 @synchronized(self) {
                                     if ((currentPlayingSong != self.currentPlayingSong) && (currentPlayingSongCell != self.currentPlayingSongCell)) {
                                         currentPlayingSongCell.iconImageView.image = image;
                                     }
                                 }
                             }];
        } else {
            currentPlayingSongCell.iconImageView.image = image;
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString *toSceneSegueID = kSegueToScene;
    UIViewController *destController = segue.destinationViewController;
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

#pragma mark - UIActionSheetDelegate Handlers
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kEditSoundsActionSheetTag) {
        BOOL showHideSelected = NO;
        if ([self.object.soundList count]) {
            if (buttonIndex == 0) {
                // Delete Sounds button
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
                                   forKey:kUserDetailsShowDetailsSoundsKey];
            [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
            [defaults synchronize];
            [self stopAllSounds];
            [self.tableView reloadData];
        }
    } else if (actionSheet.tag == kAddSoundActionSheetTag) {
        NSString *action = self.addSoundActionSheetBtnIndexes[@(buttonIndex)];
        if ([action isEqualToString:kPocketCodeRecorderActionSheetButton]) {
            // TODO: implement this, when Pocket Code Recorder will be implemented...
            // Pocket Code Recorder
            NSLog(@"Pocket Code Recorder");
            [Util showComingSoonAlertView];
        } else if ([action isEqualToString:kSelectMusicTrackActionSheetButton]) {
            // Select music track
            NSLog(@"Select music track");
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (! [delegate.fileManager existPlayableSoundsInDirectory:delegate.fileManager.documentsDirectory]) {
                [Util alertWithText:kUIAlertViewMessageNoImportedSoundsFound];
                return;
            }

            [self stopAllSounds];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
            SoundPickerTableViewController *soundPickerTVC;
            soundPickerTVC = [storyboard instantiateViewControllerWithIdentifier:@"SoundPickerTableViewController"];
            soundPickerTVC.directory = delegate.fileManager.documentsDirectory;
            UINavigationController *navigationController = [[UINavigationController alloc]
                                                            initWithRootViewController:soundPickerTVC];
            [self presentViewController:navigationController animated:YES completion:NULL];
        }
    }
}

#pragma mark - UIActionSheet Views
- (void)showAddSoundActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = kUIActionSheetTitleAddSound;
    sheet.delegate = self;
//    self.addSoundActionSheetBtnIndexes[@([sheet addButtonWithTitle:kUIActionSheetButtonTitlePocketCodeRecorder])] = kPocketCodeRecorderActionSheetButton;
    self.addSoundActionSheetBtnIndexes[@([sheet addButtonWithTitle:kUIActionSheetButtonTitleChooseSound])] = kSelectMusicTrackActionSheetButton;
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:kUIActionSheetButtonTitleCancel];
    sheet.tag = kAddSoundActionSheetTag;
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.view];
}

#pragma mark - Helper Methods
- (void)stopAllSounds
{
    [[AudioManager sharedAudioManager] stopAllSounds];
    if (self.currentPlayingSongCell) {
        self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"ic_media_play"];
    }
    self.currentPlayingSong.playing = NO;
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
}

- (void)addSoundAction:(id)sender
{
    [self showAddSoundActionSheet];
}

- (void)playSceneAction:(id)sender
{
    [self stopAllSounds];
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addSoundAction:)];
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
                                                                    action:@selector(confirmDeleteSelectedSoundsAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, invisibleButton, flexItem,
                         invisibleButton, deleteButton, nil];
}

@end
