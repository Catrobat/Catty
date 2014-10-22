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
#import "CatrobatActionSheet.h"
#import "DataTransferMessage.h"
#import "ProgramLoadingInfo.h"

@interface SoundsTableViewController () <CatrobatActionSheetDelegate, AVAudioPlayerDelegate,
                                         SWTableViewCellDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (atomic, strong) Sound *currentPlayingSong;
@property (atomic, weak) UITableViewCell<CatrobatImageCell> *currentPlayingSongCell;
@property (nonatomic, strong) SharkfoodMuteSwitchDetector *silentDetector;

@end

@implementation SoundsTableViewController

#pragma mark - data helpers
static NSCharacterSet *blockedCharacterSet = nil;
- (NSCharacterSet*)blockedCharacterSet
{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
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
    self.navigationController.title = self.title = kLocalizedSounds;
    [self initNavigationBar];
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
    self.placeHolderView.title = kLocalizedSounds;
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
        [options addObject:kLocalizedDeleteSounds];
    }
    if (self.useDetailCells) {
        [options addObject:kLocalizedHideDetails];
    } else {
        [options addObject:kLocalizedShowDetails];
    }
#if kIsRelease // kIsRelease
    CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kLocalizedThisFeatureIsComingSoon
                                                         delegate:self
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:options
                                                              tag:kEditSoundsActionSheetTag
                                                             view:self.navigationController.view];

    // disable all buttons except hide/show details + cancel button
    // (index of cancel button: ([actionSheet.buttons count] - 1))
    for (IBActionSheetButton *button in actionSheet.buttons) {
        if ((button.index != ([actionSheet.buttons count] - 2)) && (button.index != ([actionSheet.buttons count] - 1))) {
            button.enabled = NO;
            [actionSheet setButtonTextColor:[UIColor grayColor] forButtonAtIndex:button.index];
        }
    }
#else // kIsRelease
    [Util actionSheetWithTitle:kLocalizedEditSounds
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:options
                           tag:kEditSoundsActionSheetTag
                          view:self.navigationController.view];
#endif // kIsRelease
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
    NSString *fileExtension = [[sound.fileName componentsSeparatedByString:@"."] lastObject];
    sound.fileName = [NSString stringWithFormat:@"%@%@%@.%@",
                      [[[data md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                      kResourceFileNameSeparator,
                      sound.name, fileExtension];
    NSString *newPath = [self.object pathForSound:sound];
    [delegate.fileManager copyExistingFileAtPath:oldPath toPath:newPath overwrite:YES];
    [self.object.soundList addObject:sound];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    [self showPlaceHolder:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.object.program saveToDisk];
}

- (void)copySoundActionWithSourceSound:(Sound*)sourceSound
{
    [self showLoadingView];
    NSString *nameOfCopiedSound = [Util uniqueName:sourceSound.name existingNames:[self.object allSoundNames]];
    [self.object copySound:sourceSound withNameForCopiedSound:nameOfCopiedSound];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)renameSoundActionToName:(NSString*)newSoundName sound:(Sound*)sound
{
    if ([newSoundName isEqualToString:sound.name])
        return;

    [self showLoadingView];
    newSoundName = [Util uniqueName:newSoundName existingNames:[self.object allSoundNames]];
    [self.object renameSound:sound toName:newSoundName];
    NSUInteger soundIndex = [self.object.soundList indexOfObject:sound];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:soundIndex inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)confirmDeleteSelectedSoundsAction:(id)sender
{
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (! [selectedRowsIndexPaths count]) {
        // nothing selected, nothing to delete...
        [super exitEditingMode];
        return;
    }
    [self deleteSelectedSoundsAction];
}

- (void)deleteSelectedSoundsAction
{
    [self showLoadingView];
    [self stopAllSounds];
    NSArray *selectedRowsIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *soundsToRemove = [NSMutableArray arrayWithCapacity:[selectedRowsIndexPaths count]];
    for (NSIndexPath *selectedRowIndexPath in selectedRowsIndexPaths) {
        Sound *sound = (Sound*)[self.object.soundList objectAtIndex:selectedRowIndexPath.row];
        [soundsToRemove addObject:sound];
    }
    [self.object removeSounds:soundsToRemove];
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.soundList count])];
}

- (void)deleteSoundForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
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
                         onCompletion:^(UIImage *img){
                             // check if cell still needed
                             if ([imageCell.indexPath isEqual:indexPath]) {
                                 imageCell.iconImageView.image = img;
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
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLength];
        detailCell.topRightDetailLabel.textColor = [UIColor whiteColor];

        NSNumber *number = [self.dataCache objectForKey:sound.fileName];
        CGFloat duration;
        if (! number) {
            duration = [self.object durationOfSound:sound];
            [self.dataCache setObject:[NSNumber numberWithFloat:duration] forKey:sound.fileName];
        } else {
            duration = [number floatValue];
        }

        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%.02fs", (float)duration];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor whiteColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
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
                        [Util alertWithText:(IS_IPHONE ? kLocalizedDeviceIsInMutedStateIPhoneDescription
                                                       : kLocalizedDeviceIsInMutedStateIPadDescription)];
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
                                        [Util alertWithText:kLocalizedUnableToPlaySoundDescription];
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
    return [TableUtil heightForImageCell];
}

#pragma mark - swipe delegates
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        // More button was pressed
        NSArray *options = @[kLocalizedCopy, kLocalizedRename];
#if kIsRelease // kIsRelease
        CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kLocalizedThisFeatureIsComingSoon
                                                             delegate:self
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:options
                                                                  tag:kEditSoundActionSheetTag
                                                                 view:self.navigationController.view];
        // disable all buttons except cancel button (index of cancel button: ([actionSheet.buttons count] - 1))
        for (IBActionSheetButton *button in actionSheet.buttons) {
            if (button.index != ([actionSheet.buttons count] - 1)) {
                button.enabled = NO;
                [actionSheet setButtonTextColor:[UIColor grayColor] forButtonAtIndex:button.index];
            }
        }
#else // kIsRelease
        CatrobatActionSheet *actionSheet = [Util actionSheetWithTitle:kLocalizedEditSound
                                                             delegate:self
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:options
                                                                  tag:kEditSoundActionSheetTag
                                                                 view:self.navigationController.view];
#endif // kIsRelease
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *payload = @{ kDTPayloadSound : [self.object.soundList objectAtIndex:indexPath.row] };
        DataTransferMessage *message = [DataTransferMessage messageForActionType:kDTMActionEditSound
                                                                     withPayload:[payload mutableCopy]];
        actionSheet.dataTransferMessage = message;
    } else if (index == 1) {
        // Delete button was pressed
#if kIsRelease // kIsRelease
        [Util showComingSoonAlertView];
#else // kIsRelease
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self performActionOnConfirmation:@selector(deleteSoundForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kLocalizedDeleteThisSound
                           confirmMessage:kLocalizedThisActionCannotBeUndone];
#endif // kIsRelease
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark audio delegate
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
                             onCompletion:^(UIImage *img){
                                 // check if user tapped again on this song in the meantime...
                                 @synchronized(self) {
                                     if ((currentPlayingSong != self.currentPlayingSong) && (currentPlayingSongCell != self.currentPlayingSongCell)) {
                                         currentPlayingSongCell.iconImageView.image = img;
                                     }
                                 }
                             }];
        } else {
            currentPlayingSongCell.iconImageView.image = image;
        }
    }
}


#pragma mark - action sheet handlers
- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
    } else if (actionSheet.tag == kEditSoundActionSheetTag) {
        if (buttonIndex == 0) {
            // Copy sound button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            [self copySoundActionWithSourceSound:(Sound*)payload[kDTPayloadSound]];
        } else if (buttonIndex == 1) {
            // Rename look button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            Sound *sound = (Sound*)payload[kDTPayloadSound];
            [Util askUserForTextAndPerformAction:@selector(renameSoundActionToName:sound:)
                                          target:self
                                      withObject:sound
                                     promptTitle:kLocalizedRenameSound
                                   promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedSoundName]
                                     promptValue:sound.name
                               promptPlaceholder:kLocalizedEnterYourSoundNameHere
                                  minInputLength:kMinNumOfSoundNameCharacters
                                  maxInputLength:kMaxNumOfSoundNameCharacters
                             blockedCharacterSet:[self blockedCharacterSet]
                        invalidInputAlertMessage:kLocalizedInvalidSoundNameDescription];
        }
    } else if (actionSheet.tag == kAddSoundActionSheetTag) {
        if (buttonIndex == 0) {
            // Select music track
            NSLog(@"Select music track");
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (! [delegate.fileManager existPlayableSoundsInDirectory:delegate.fileManager.documentsDirectory]) {
                [Util alertWithText:kLocalizedNoImportedSoundsFoundDescription];
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
    [Util actionSheetWithTitle:kLocalizedAddSound
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:@[/*kLocalizedPocketCodeRecorder, */kLocalizedChooseSound]
                           tag:kAddSoundActionSheetTag
                          view:self.navigationController.view];
}

- (void)playSceneAction:(id)sender
{
    [self stopAllSounds];
    [self.navigationController setToolbarHidden:YES animated:YES];
    ScenePresenterViewController *vc = [[ScenePresenterViewController alloc] initWithProgram:[Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]]];
    [self.navigationController pushViewController:vc animated:YES];
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
#if kIsRelease // kIsRelease
    add.enabled = NO;
#endif // kIsRelease
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
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
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
