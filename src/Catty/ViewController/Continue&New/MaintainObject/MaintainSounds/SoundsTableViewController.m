/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
#import "SpriteObject.h"
#import "AudioManager.h"
#import "Util.h"
#import "CBFileManager.h"
#import "CBFileManager.h"
#import "RuntimeImageCache.h"
#import "PlaceHolderView.h"
#import "ViewControllerDefines.h"
#import "UIUtil.h"
#import "Pocket_Code-Swift.h"

@interface SoundsTableViewController () <AudioManagerDelegate,AVAudioPlayerDelegate>
@property (nonatomic) BOOL useDetailCells;
@property (atomic, strong) Sound *currentPlayingSong;
@property (atomic, weak) UITableViewCell<CatrobatImageCell> *currentPlayingSongCell;
@property (nonatomic,assign) BOOL isAllowed;
@property (nonatomic,assign) BOOL deletionMode;
@end

@implementation SoundsTableViewController

#pragma mark - initialization
- (void)initNavigationBar
{
    UIBarButtonItem *editButtonItem = [TableUtil editButtonItemWithTarget:self action:@selector(editAction:)];
    self.parentNavigationController.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma mark - events
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *showDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDetailsShowDetailsKey];
    NSNumber *showDetailsSoundsValue = (NSNumber*)[showDetails objectForKey:kUserDetailsShowDetailsSoundsKey];
    self.useDetailCells = [showDetailsSoundsValue boolValue];
    self.navigationController.title = self.title = kLocalizedSounds;
    [self initNavigationBar];
    [self changeEditingBarButtonState];
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
    self.placeHolderView.title = kLocalizedTapPlusToAddSound;
    //[self showPlaceHolder:(! (BOOL)[self.object.soundList count])];
    self.placeHolderView.hidden = (self.object.soundList.count != 0);
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isAllowed = YES;
    
    if(self.showAddSoundActionSheetAtStart) {
        [self addSoundAction:nil];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.currentPlayingSongCell = nil;
    [self stopAllSounds];
}

#pragma mark - start scene
- (void)playSceneAction:(id)sender
{
    [self stopAllSounds];
    [super playSceneAction:sender];
}

#pragma mark - actions
- (void)editAction:(id)sender
{
    id<AlertControllerBuilding> actionSheet = [[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditSounds]
                                               addCancelActionWithTitle:kLocalizedCancel handler:nil];
    
    if (self.object.soundList.count) {
        [actionSheet addDestructiveActionWithTitle:kLocalizedDeleteSounds handler:^{
            self.deletionMode = YES;
            [self setupEditingToolBar];
            [self changeToEditingMode:sender];
        }];
    }
    
    if (self.object.soundList.count >= 2) {
        [actionSheet addDefaultActionWithTitle:kLocalizedMoveSounds handler:^{
            self.deletionMode = NO;
            [self changeToMoveMode:sender];
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
                           forKey:kUserDetailsShowDetailsSoundsKey];
    [defaults setObject:showDetailsMutable forKey:kUserDetailsShowDetailsKey];
    [defaults synchronize];
    [self stopAllSounds];
    [self reloadData];
}

- (void)addSoundToObjectAction:(Sound*)sound
{
    NSMutableArray *soundNames = [NSMutableArray arrayWithCapacity:[self.object.soundList count]];
    for (Sound *currentSound in self.object.soundList) {
        [soundNames addObject:currentSound.name];
    }
    sound.name = [Util uniqueName:sound.name existingNames:soundNames];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    NSString *oldPath = [NSString stringWithFormat:@"%@/%@", fileManager.documentsDirectory, sound.fileName];
    NSData *data = [NSData dataWithContentsOfFile:oldPath];
    NSString *fileExtension = [[sound.fileName componentsSeparatedByString:@"."] lastObject];
    sound.fileName = [NSString stringWithFormat:@"%@%@%@.%@",
                      [[[data md5] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],
                      kResourceFileNameSeparator,
                      sound.name, fileExtension];
    NSString *newPath = [sound pathForScene:self.object.scene];
    if (![self checkIfSoundFolderExists]) {
        [fileManager createDirectory:self.object.scene.soundsPath];
    }
    [fileManager copyExistingFileAtPath:oldPath toPath:newPath overwrite:YES];
    [self.object.soundList addObject:sound];
    NSInteger numberOfRowsInLastSection = [self tableView:self.tableView numberOfRowsInSection:0];
    [self showPlaceHolder:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numberOfRowsInLastSection - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //Error on save?
    [self.object.scene.project saveToDiskWithNotification:YES];
    
    if(self.afterSafeBlock) {
        self.afterSafeBlock(sound);
    }
}


-(BOOL)checkIfSoundFolderExists{
    CBFileManager* manager = [CBFileManager sharedManager];
    if ([manager directoryExists:self.object.scene.soundsPath]) {
        return YES;
    }
    return NO;
    
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
        [self exitEditingMode];
        return;
    }
    self.deletionMode = NO;
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
    [self exitEditingMode];
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
    static NSString *playIconName = @"play.circle";
    static NSString *stopIconName = @"stop.circle";

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

    imageCell.iconImageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;

    imageCell.titleLabel.text = sound.name;
    imageCell.iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSound:)];
    tapped.numberOfTapsRequired = 1;
    [imageCell.iconImageView addGestureRecognizer:tapped];

    if (self.useDetailCells && [cell isKindOfClass:[DarkBlueGradientImageDetailCell class]]) {
        DarkBlueGradientImageDetailCell *detailCell = (DarkBlueGradientImageDetailCell*)imageCell;
        detailCell.topLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.topLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedLength];
        detailCell.topRightDetailLabel.textColor = UIColor.textTint;

        NSNumber *number = [self.dataCache objectForKey:sound.fileName];
        CGFloat duration;
        if (! number) {
            duration = [self.object durationOfSound:sound];
            [self.dataCache setObject:[NSNumber numberWithFloat:duration] forKey:sound.fileName];
        } else {
            duration = [number floatValue];
        }

        detailCell.topRightDetailLabel.text = [NSString stringWithFormat:@"%.02fs", (float)duration];
        detailCell.bottomLeftDetailLabel.textColor = UIColor.textTint;
        detailCell.bottomLeftDetailLabel.text = [NSString stringWithFormat:@"%@:", kLocalizedSize];
        detailCell.bottomRightDetailLabel.textColor = UIColor.textTint;
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
    if (!self.deletionMode) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        if (indexPath.row >= [self.object.soundList count]) {
            return;
        }
        [self playSound:imageCell andIndexPath:indexPath];

    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Sound* itemToMove = self.object.soundList[sourceIndexPath.row];
    [self.object.soundList removeObjectAtIndex:sourceIndexPath.row];
    [self.object.soundList insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.object.scene.project saveToDiskWithNotification:NO];
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView*)tableView
                editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewRowAction *moreAction = [UIUtil tableViewMoreRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // More button was pressed
        [[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedEditSound]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedCopy handler:^{
             [self copySoundActionWithSourceSound:[self.object.soundList objectAtIndex:indexPath.row]];
         }]
         addDefaultActionWithTitle:kLocalizedRename handler:^{
             Sound *sound = [self.object.soundList objectAtIndex:indexPath.row];
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
                         invalidInputAlertMessage:kLocalizedInvalidSoundNameDescription];
         }] build]
         viewWillDisappear:^{
              [self.tableView setEditing:false animated:YES];
         }]
         showWithController:self];
    }];
    moreAction.backgroundColor = UIColor.globalTint;
    UITableViewRowAction *deleteAction = [UIUtil tableViewDeleteRowActionWithHandler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // Delete button was pressed
        [[[[[AlertControllerBuilder alertWithTitle:kLocalizedDeleteThisSound message:kLocalizedThisActionCannotBeUndone]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedYes handler:^{
             [self deleteSoundForIndexPath:indexPath];
         }] build]
         showWithController:self];
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
        Sound *sound = (Sound*)[self.object.soundList objectAtIndex:indexPath.row];
        BOOL isPlaying = sound.isPlaying;
        if (self.currentPlayingSong && self.currentPlayingSongCell) {
            self.currentPlayingSong.playing = NO;
            self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"play.circle"];
        }
        self.currentPlayingSong = sound;
        self.currentPlayingSongCell = imageCell;
        self.currentPlayingSong.playing = (! isPlaying);
        self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"play.circle"];
        if (! isPlaying)
            imageCell.iconImageView.image = [UIImage imageNamed:@"stop.circle"];
        
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
                                                 atFilePath:self.object.scene.soundsPath
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

-(void)audioItemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:notification.object];
    if ((! self.currentPlayingSong) || (! self.currentPlayingSongCell)) {
        return;
    }
    
    @synchronized(self) {
        Sound *currentPlayingSong = self.currentPlayingSong;
        UITableViewCell<CatrobatImageCell> *currentPlayingSongCell = self.currentPlayingSongCell;
        self.currentPlayingSong.playing = NO;
        self.currentPlayingSong = nil;
        self.currentPlayingSongCell = nil;
        
        static NSString *playIconName = @"play.circle";
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
        
        static NSString *playIconName = @"play.circle";
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

- (void)changeToMoveMode:(id)sender
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDone
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(exitEditingMode)];
    self.parentNavigationController.navigationItem.hidesBackButton = YES;
    self.parentNavigationController.navigationItem.rightBarButtonItem = cancelButton;
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.parentNavigationController.navigationController.toolbar.userInteractionEnabled = NO;
    self.editing = YES;
}

- (void)changeToEditingMode:(id)sender
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(exitEditingMode)];
    self.parentNavigationController.navigationItem.hidesBackButton = YES;
    self.parentNavigationController.navigationItem.rightBarButtonItem = cancelButton;
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.editing = YES;
}

- (void)exitEditingMode
{
    [super exitEditingMode];
    self.deletionMode = NO;
    self.parentNavigationController.navigationItem.hidesBackButton = NO;
    [self initNavigationBar];
    self.parentNavigationController.navigationController.toolbar.userInteractionEnabled = YES;
    [self.tableView setEditing:NO animated:YES];
    [self setupToolBar];
    self.editing = NO;
}

#pragma mark - Helper Methods

- (void)stopAllSounds
{
    [[AudioManager sharedAudioManager] stopAllSounds];
    if (self.currentPlayingSongCell) {
        self.currentPlayingSongCell.iconImageView.image = [UIImage imageNamed:@"play.circle"];
    }
    self.currentPlayingSong.playing = NO;
    self.currentPlayingSong = nil;
    self.currentPlayingSongCell = nil;
}

- (void)addSoundAction:(id)sender
{
    [self.tableView setEditing:false animated:YES];
    
    [[[[[[[AlertControllerBuilder actionSheetWithTitle:kLocalizedAddSound]
     addCancelActionWithTitle:kLocalizedCancel handler:^{
         SAFE_BLOCK_CALL(self.afterSafeBlock, nil);
     }]
     addDefaultActionWithTitle:kLocalizedPocketCodeRecorder handler:^{
         NSDebug(@"Recorder");
         AVAudioSession *session = [AVAudioSession sharedInstance];
         if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
             [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                 if (granted) {
                     // Microphone enabled code
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.isAllowed = YES;
                         [self stopAllSounds];
                         SoundRecorderViewController *soundRecorderViewController;
                         
                         soundRecorderViewController = [self.storyboard instantiateViewControllerWithIdentifier:kSoundRecorderViewControllerIdentifier];
                         soundRecorderViewController.delegate = self;
                         [self showViewController:soundRecorderViewController sender:self];
                         
                     });
                 } else {
                     // Microphone disabled code
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self suggestToOpenSettingsAppWithMessage:kLocalizedNoAccesToMicrophoneCheckSettingsDescription];
                     });
                 }
             }];
         }
     }]
     addDefaultActionWithTitle:kLocalizedMediaLibrary handler:^{
         self.isAllowed = YES;
         dispatch_async(dispatch_get_main_queue(), ^{
             [self showSoundsMediaLibrary];
         });
     }]
    addDefaultActionWithTitle:kLocalizedSelectFile handler:^{
        self.isAllowed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSoundsSelectFile];
        });
    }]
     build]
     showWithController:self];
}

- (void)suggestToOpenSettingsAppWithMessage:(NSString *)message {
    [[[[[AlertControllerBuilder alertWithTitle:nil message:message]
     addCancelActionWithTitle:kLocalizedCancel handler:nil]
     addDefaultActionWithTitle:kLocalizedSettings handler:^{
         NSDebug(@"Settings Action");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
     }]
     build]
     showWithController:self];
}

- (void)setupToolBar
{
    [super setupToolBar];

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addSoundAction:)];
    UIBarButtonItem *play = [[PlayButton alloc] initWithTarget:self
                                                        action:@selector(playSceneAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: flex, add, flex, flex, play, flex, nil];
    self.parentNavigationController.toolbarItems = self.toolbarItems;
}

- (void)setupEditingToolBar
{
    [super setupEditingToolBar];

    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDelete
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(confirmDeleteSelectedSoundsAction:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:self.selectAllRowsButtonItem, flex, deleteButton, nil];
    self.parentNavigationController.toolbarItems = self.toolbarItems;
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
        [self.tableView reloadData];
        [self changeEditingBarButtonState];
    });
}

#pragma mark Sound Delegate

-(void)addSound:(Sound *)sound
{
    if (self.isAllowed) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [CBFileManager sharedManager].documentsDirectory, sound.fileName];
        [self addSoundToObjectAction:sound];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        self.isAllowed = NO;
    }
    
    if (self.afterSafeBlock) {
        self.afterSafeBlock(nil);
    }
    
    [self reloadData];
}

@end
