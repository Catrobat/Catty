/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "SoundPickerTableViewController.h"
#import "AppDelegate.h"
#import "CatrobatImageCell.h"
#import "Sound.h"
#import "AudioManager.h"
#import "TableUtil.h"
#import "UIDefines.h"
#import "RuntimeImageCache.h"
#import "Util.h"
#import "SharkfoodMuteSwitchDetector.h"

@interface SoundPickerTableViewController () <AudioManagerDelegate,AVAudioPlayerDelegate>
@property (atomic, strong) Sound *currentPlayingSong;
@property (atomic, weak) UITableViewCell<CatrobatImageCell> *currentPlayingSongCell;
@property (nonatomic, strong) NSArray *playableSounds;
@property (nonatomic, strong) SharkfoodMuteSwitchDetector *silentDetector;
@end

@implementation SoundPickerTableViewController

#pragma mark - getters and setters
- (NSArray*)playableSounds
{
    if (! _playableSounds && self.directory) {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _playableSounds = [appDelegate.fileManager playableSoundsInDirectory:self.directory];
    }
    return _playableSounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // automatically stop current playing sound after the user turns
    // on the silent switcher on the iPhone/iPad (device is in silent state)
    self.silentDetector = [SharkfoodMuteSwitchDetector shared];
    // must be weak (!!) since SoundsTableViewController is holding the SharkfoodMuteSwitchDetector
    // instance strongly!
    __weak SoundPickerTableViewController *soundPickerTableViewController = self;
    self.silentDetector.silentNotify = ^(BOOL silent){
        if (silent) {
            [soundPickerTableViewController stopAllSounds];
        }
    };

    [self setupNavigationBar];
    [super showPlaceHolder:NO];
    self.navigationController.toolbarHidden = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.currentPlayingSongCell = nil;
    [self stopAllSounds];
}

#pragma mark - actions
- (void)dismissSoundPickerTVC:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (!self.presentingViewController.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playableSounds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Sound *sound = (Sound*)[self.playableSounds objectAtIndex:indexPath.row];

    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
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
    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        Sound *sound = [self.playableSounds objectAtIndex:indexPath.row];
        if (! sound) {
            return;
        }
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc postNotificationName:kSoundAddedNotification
                           object:nil
                         userInfo:@{ kUserInfoSound : sound}];
    }];
}

#pragma mark - player actions
- (void)playSound:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if ([gesture.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView*)gesture.view;
        CGPoint position = [imageView convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
            if (indexPath.row < [self.playableSounds count]) {
                // acquire lock
                if (self.silentDetector.isMute) {
                    [Util alertWithText:(IS_IPHONE ? kLocalizedDeviceIsInMutedStateIPhoneDescription
                                         : kLocalizedDeviceIsInMutedStateIPadDescription)];
                    return;
                }
                @synchronized(self) {
                    Sound *sound = (Sound*)[self.playableSounds objectAtIndex:indexPath.row];
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
                    
                    dispatch_queue_t queue = dispatch_queue_create("at.tugraz.ist.catrobat.PlaySoundTVCQueue", NULL);
                    dispatch_async(queue, ^{
                        [[AudioManager sharedAudioManager] stopAllSounds];
                        if (! isPlaying) {
                            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                            [[AudioManager sharedAudioManager] playSoundWithFileName:sound.fileName
                                                                              andKey:sound.name
                                                                          atFilePath:appDelegate.fileManager.documentsDirectory
                                                                            delegate:self];
                        }
                    });
                }
            }
        }
    }
}



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

#pragma mark audio delegate methods
-(void)audioItemDidFinishPlaying:(NSNotification *) notification;
{
    if ((! self.currentPlayingSong) || (! self.currentPlayingSongCell)) {
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

#pragma mark audio delegate methods
        - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
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

#pragma mark - helpers
- (void)setupNavigationBar
{
    self.navigationItem.title = self.title = kLocalizedChooseSound;
    UIBarButtonItem *closeButton;
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(dismissSoundPickerTVC:)];
    closeButton.tintColor = [UIColor navTintColor];
    self.navigationItem.rightBarButtonItems = @[closeButton];
}

@end
