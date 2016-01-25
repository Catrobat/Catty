/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "CatrobatAlertController.h"
#import "DataTransferMessage.h"
#import "ProgramLoadingInfo.h"
#import "SRViewController.h"
#import "PlaceHolderView.h"
#import "ViewControllerDefines.h"
#import "UIUtil.h"


@interface SoundsTableViewController () <CatrobatActionSheetDelegate, AVAudioPlayerDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (atomic, strong) Sound *currentPlayingSong;
@property (atomic, strong) Sound *sound;
@property (atomic, weak) UITableViewCell<CatrobatImageCell> *currentPlayingSongCell;
@property (nonatomic, strong) SharkfoodMuteSwitchDetector *silentDetector;
@property (nonatomic,assign) BOOL isAllowed;
@property (nonatomic,assign) BOOL deletionMode;
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
    [self changeEditingBarButtonState];
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
    self.placeHolderView.title = kLocalizedSounds;
    [self showPlaceHolder:(! (BOOL)[self.object.soundList count])];
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isAllowed = YES;
    
    if(self.showAddSoundActionSheetAtStart) {
        [self addSoundAction:nil];
    }
}

- (void)dealloc
{
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self name:kRecordAddedNotification object:nil];
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
    if (self.isAllowed) {
        if (notification.userInfo) {
                NSDebug(@"soundAdded notification received with userInfo: %@", [notification.userInfo description]);
            id sound = notification.userInfo[kUserInfoSound];
            if ([sound isKindOfClass:[Sound class]]) {
                [self addSoundToObjectAction:(Sound*)sound];
                self.isAllowed = NO;
            }
        }
    }
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
    [self reloadData];
}



#pragma mark - actions
- (void)editAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    NSMutableArray *options = [NSMutableArray array];
    NSString* destructive = nil;
    if (self.object.soundList.count) {
        destructive = kLocalizedDeleteSounds;
    }
    if (self.object.soundList.count >= 2) {
        [options addObject:kLocalizedMoveSounds];
    }
    if (self.useDetailCells) {
        [options addObject:kLocalizedHideDetails];
    } else {
        [options addObject:kLocalizedShowDetails];
    }
    [Util actionSheetWithTitle:kLocalizedEditSounds
                      delegate:self
        destructiveButtonTitle:destructive
             otherButtonTitles:options
                           tag:kEditSoundsActionSheetTag
                          view:self.navigationController.view];
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
    [self.object.program saveToDiskWithNotification:YES];
    
    if(self.afterSafeBlock) {
        self.afterSafeBlock(sound);
    }
}

- (void)copySoundActionWithSourceSound:(Sound*)sourceSound
{
    [self showLoadingView];
    NSString *nameOfCopiedSound = [Util uniqueName:sourceSound.name existingNames:[self.object allSoundNames]];
    [self.object copySound:sourceSound withNameForCopiedSound:nameOfCopiedSound AndSaveToDisk:YES];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self hideLoadingView];
}

- (void)renameSoundActionToName:(NSString*)newSoundName sound:(Sound*)sound
{
    if ([newSoundName isEqualToString:sound.name])
        return;

    [self showLoadingView];
    newSoundName = [Util uniqueName:newSoundName existingNames:[self.object allSoundNames]];
    [self.object renameSound:sound toName:newSoundName AndSaveToDisk:YES];
    NSUInteger soundIndex = [self.object.soundList indexOfObject:sound];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:soundIndex inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self hideLoadingView];
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
    [self.object removeSounds:soundsToRemove AndSaveToDisk:YES];
    [super exitEditingMode];
    [self.tableView deleteRowsAtIndexPaths:selectedRowsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.soundList count])];
    [self hideLoadingView];
    [self reloadData];
}

- (void)deleteSoundForIndexPath:(NSIndexPath*)indexPath
{
    [self showLoadingView];
    [self stopAllSounds];
    Sound *sound = (Sound*)[self.object.soundList objectAtIndex:indexPath.row];
    [self.object removeSound:sound AndSaveToDisk:YES];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [super showPlaceHolder:(! (BOOL)[self.object.soundList count])];
    [self hideLoadingView];
    [self reloadData];
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
        detailCell.topLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLength];
        detailCell.topRightDetailLabel.textColor = [UIColor textTintColor];

        NSNumber *number = [self.dataCache objectForKey:sound.fileName];
        CGFloat duration;
        if (! number) {
            duration = [self.object durationOfSound:sound];
            [self.dataCache setObject:[NSNumber numberWithFloat:duration] forKey:sound.fileName];
        } else {
            duration = [number floatValue];
        }

        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%.02fs", (float)duration];
        detailCell.bottomLeftDetailLabel.textColor = [UIColor textTintColor];
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = [UIColor textTintColor];
        NSUInteger resultSize = [self.object fileSizeOfSound:sound];
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
    if(self.deletionMode){
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
    if (indexPath.row >= [self.object.soundList count]) {
        return;
    }
    [self playSound:imageCell andIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Sound* itemToMove = self.object.soundList[sourceIndexPath.row];
    [self.object.soundList removeObjectAtIndex:sourceIndexPath.row];
    [self.object.soundList insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.object.program saveToDiskWithNotification:YES];
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        NSArray *options = @[kLocalizedCopy, kLocalizedRename];
        CatrobatAlertController *actionSheet = [Util actionSheetWithTitle:kLocalizedEditSound
                                                             delegate:self
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:options
                                                                  tag:kEditSoundActionSheetTag
                                                                 view:self.navigationController.view];
        actionSheet.dataTransferMessage = [DataTransferMessage messageForActionType:kDTMActionEditSound
                                                                        withPayload:@{ kDTPayloadSound : [self.object.soundList objectAtIndex:indexPath.row] }];
    }];
    moreAction.backgroundColor = [UIColor globalTintColor];
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        [self performActionOnConfirmation:@selector(deleteSoundForIndexPath:)
                           canceledAction:nil
                               withObject:indexPath
                                   target:self
                             confirmTitle:kLocalizedDeleteThisSound
                           confirmMessage:kLocalizedThisActionCannotBeUndone];
    }];
    return @[deleteAction, moreAction];
}

#pragma mark - player actions
- (void)playSound:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if (! [gesture.view isKindOfClass:[UIImageView class]]) {
        return;
    }

    UIImageView *imageView = (UIImageView*)gesture.view;
    CGPoint position = [imageView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return;
    }

    UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
    if (indexPath.row >= [self.object.soundList count]) {
        return;
    }
    [self playSound:imageCell andIndexPath:indexPath];
    
    
}

-(void)playSound:(UITableViewCell<CatrobatImageCell>*)imageCell andIndexPath:(NSIndexPath*)indexPath
{
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
                if (isPlaying) {
                    return;
                }
                AudioManager *am = [AudioManager sharedAudioManager];
                BOOL isPlayable = [am playSoundWithFileName:sound.fileName
                                                     andKey:self.object.name
                                                 atFilePath:[NSString stringWithFormat:@"%@%@",
                                                             [self.object projectPath], kProgramSoundsDirName]
                                                   delegate:self];
                if (isPlayable) {
                    return;
                }
                
                // SYNC !! so lock is not lost => busy waiting in PlaySoundTVCQueue
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [Util alertWithText:kLocalizedUnableToPlaySoundDescription];
                    [self stopAllSounds];
                });
            }
        });
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [TableUtil heightForImageCell];
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
- (void)actionSheet:(CatrobatAlertController*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView setEditing:false animated:YES];
    if (actionSheet.tag == kEditSoundsActionSheetTag) {
        BOOL showHideSelected = NO;
        if ([self.object.soundList count]) {
            if (buttonIndex == 1) {
                // Delete Sounds button
                self.deletionMode = YES;
                [self setupEditingToolBar];
                [super changeToEditingMode:actionSheet];
            }  else if (([self.object.soundList count] >= 2)) {
                if (buttonIndex == 2) {
                    self.deletionMode = NO;
                    [super changeToMoveMode:actionSheet];
                } else if (buttonIndex == 3) {
                    showHideSelected = YES;
                }
            } else if (buttonIndex == 2){
                showHideSelected = YES;
            }
        } else if (buttonIndex == 1) {
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
            [self reloadData];
        }
    } else if (actionSheet.tag == kEditSoundActionSheetTag) {
        if (buttonIndex == 1) {
            // Copy sound button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            [self copySoundActionWithSourceSound:(Sound*)payload[kDTPayloadSound]];
        } else if (buttonIndex == 2) {
            // Rename look button
            NSDictionary *payload = (NSDictionary*)actionSheet.dataTransferMessage.payload;
            Sound *sound = (Sound*)payload[kDTPayloadSound];
            [Util askUserForTextAndPerformAction:@selector(renameSoundActionToName:sound:)
                                          target:self
                                    cancelAction:nil
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
        if (buttonIndex == 1) {
                //Recorder
            NSDebug(@"Recorder");
            AVAudioSession *session = [AVAudioSession sharedInstance];
            if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
                [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    if (granted) {
                        // Microphone enabled code
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isAllowed = YES;
                            [self stopAllSounds];
                            SRViewController *soundRecorderViewController;
                            
                            soundRecorderViewController = [self.storyboard instantiateViewControllerWithIdentifier:kSoundRecorderViewControllerIdentifier];
                            soundRecorderViewController.delegate = self;
                            [self showViewController:soundRecorderViewController sender:self];
 
                        });
                        
                    }
                    else {
                        // Microphone disabled code
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *alertControllerCameraRoll = [UIAlertController
                                                                            alertControllerWithTitle:nil
                                                                            message:kLocalizedNoAccesToMicrophoneCheckSettingsDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                            
                            
                            UIAlertAction *cancelAction = [UIAlertAction
                                                           actionWithTitle:kLocalizedCancel
                                                           style:UIAlertActionStyleCancel
                                                           handler:nil];
                            
                            UIAlertAction *settingsAction = [UIAlertAction
                                                             actionWithTitle:kLocalizedSettings
                                                             style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                                             {
                                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                             }];
                            
                            [alertControllerCameraRoll addAction:cancelAction];
                            [alertControllerCameraRoll addAction:settingsAction];
                            [self presentViewController:alertControllerCameraRoll animated:YES completion:nil];
                        });
                    }
                }];
            }
            } else if (buttonIndex == 2) {
            // Select music track
            NSDebug(@"Select music track");
            self.isAllowed = YES;
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (! [delegate.fileManager existPlayableSoundsInDirectory:delegate.fileManager.documentsDirectory]) {
                [Util alertWithTitle:kLocalizedNoImportedSoundsFoundTitle
                             andText:kLocalizedNoImportedSoundsFoundDescription];
                if(self.afterSafeBlock) {
                    self.afterSafeBlock(nil);
                }
                return;
            }
            [self stopAllSounds];
            SoundPickerTableViewController *soundPickerTVC;
            soundPickerTVC = [self.storyboard instantiateViewControllerWithIdentifier:kSoundPickerTableViewControllerIdentifier];
            soundPickerTVC.directory = delegate.fileManager.documentsDirectory;
            UINavigationController *navigationController = [[UINavigationController alloc]
                                                            initWithRootViewController:soundPickerTVC];
            [self presentViewController:navigationController animated:YES completion:^{
                if(self.afterSafeBlock) {
                    self.afterSafeBlock(nil);
                }
            }];
        } else {
            if(self.afterSafeBlock) {
                self.afterSafeBlock(nil);
            }
        }
    }else{
        if(self.afterSafeBlock) {
            self.afterSafeBlock(nil);
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
    [self.tableView setEditing:false animated:YES];
    [Util actionSheetWithTitle:kLocalizedAddSound
                      delegate:self
        destructiveButtonTitle:nil
             otherButtonTitles:@[kLocalizedPocketCodeRecorder, kLocalizedChooseSound]
                           tag:kAddSoundActionSheetTag
                          view:self.navigationController.view];
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

- (void)changeEditingBarButtonState
{
    if (self.object.soundList.count >= 1) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)reloadData
{
    dispatch_async(dispatch_get_main_queue(),^{
        //do something
        [self.tableView reloadData];
        [self changeEditingBarButtonState];
        
    });
}

#pragma mark Sound Delegate

-(void)addSound:(Sound *)sound
{
    if (self.isAllowed) {
        Sound* recording =(Sound*)sound;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, recording.fileName];
        [self addSoundToObjectAction:recording];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSDebug(@"-.-");
        }
        self.isAllowed = NO;

    }
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
    [self reloadData];
}

- (void)showSaveSoundAlert:(Sound *)sound
{
    self.sound = sound;
    [self performActionOnConfirmation:@selector(saveSound)
                       canceledAction:@selector(cancelPaintSave)
                               target:self
                         confirmTitle:kLocalizedSaveToPocketCode
                       confirmMessage:kLocalizedPaintSaveChanges];
}

- (void)saveSound
{
    if (self.sound) {
        [self addSound:self.sound];
    }
    
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
}

- (void)cancelPaintSave
{
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
}

@end
