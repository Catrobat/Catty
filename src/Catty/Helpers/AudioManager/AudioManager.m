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


#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CatrobatAudioPlayer.h"
#import "CatrobatPlayerItem.h"
#import "SoundCache.h"

@interface AudioManager()

@property (nonatomic) NSInteger soundCounter;

@property (nonatomic, strong) NSMutableDictionary* sounds;
@property (nonatomic) float current_volume;

@end

@implementation AudioManager

+ (instancetype)sharedAudioManager
{
    static AudioManager *_sharedCattyAudioManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedCattyAudioManager = [AudioManager new]; });
    return _sharedCattyAudioManager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    self.soundCounter=0;
    self.current_volume = 1;
    return self;
}


- (NSMutableDictionary*)sounds
{
    if(!_sounds) {
        _sounds = [[NSMutableDictionary alloc] init];
    }
    return _sounds;
}

- (BOOL)playSoundWithFileName:(NSString*)fileName
                       andKey:(NSString*)key
                   atFilePath:(NSString*)filePath
                     delegate:(SoundsTableViewController*) delegate
{
    NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
    if (! audioPlayers) {
        audioPlayers = [[NSMutableDictionary alloc] init];
        [self.sounds setObject:audioPlayers forKey:key];
    }
    NSString *path =[NSString stringWithFormat:@"%@/%@", filePath, fileName];
    //for 1 and 3 method
//    CatrobatPlayerItem *item = [[SoundCache sharedSoundCache] cachedSoundForPath:path];
    //3.method
//    if (!item) {
//        [[SoundCache sharedSoundCache] loadSoundFromDiskWithPath:path onCompletion:^(CatrobatPlayerItem *loadeditem, NSString* path) {
//            [self triggerPlaySoundItem:loadeditem withPlayers:audioPlayers fileName:fileName andDelegate:delegate];
//        }];
//
//    }else{
//        [self triggerPlaySoundItem:item withPlayers:audioPlayers fileName:fileName andDelegate:delegate];
//    }
    
    // 1.method
//    if (!item) {
//        item = [[SoundCache sharedSoundCache] loadSoundFromDiskWithPath:path];
//    }
    
    //2.method
    CatrobatPlayerItem *item = [[CatrobatPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    
    
    // for 1 and 2 method
    if(!item) return NO;
    [self triggerPlaySoundItem:item withPlayers:audioPlayers fileName:fileName andDelegate:delegate];
    //////
    
    return YES;
}

-(void)triggerPlaySoundItem:(CatrobatPlayerItem*)playerItem withPlayers:(NSMutableDictionary*)audioPlayers fileName:(NSString*)fileName andDelegate:(id)delegate
{
    CatrobatAudioPlayer *player = [audioPlayers objectForKey:fileName];
    playerItem = (CatrobatPlayerItem*)[playerItem copyWithZone:nil];
    if (! player) {
        player = [[CatrobatAudioPlayer alloc] initWithPlayerItem:playerItem];
        playerItem.key = fileName;
        [player setKey:fileName];
        [audioPlayers setObject:player forKey:fileName];
    } else {
        self.soundCounter++;
        player = [[CatrobatAudioPlayer alloc] initWithPlayerItem:playerItem];
        playerItem.key = [fileName stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)self.soundCounter]];
        [player setKey:playerItem.key];
        [audioPlayers setObject:player forKey:playerItem.key];
    }
    
    if (delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(audioItemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioItemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
    
    player.volume = self.current_volume;
    [player play];
}

- (BOOL)playSoundWithFileName:(NSString*)fileName
                       andKey:(NSString*)key
                   atFilePath:(NSString*)filePath
{
    return [self playSoundWithFileName:fileName andKey:key atFilePath:filePath delegate:nil];
}

- (void)setVolumeToPercent:(CGFloat)volume forKey:(NSString*)key
{
    self.current_volume = volume/100;
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
            player.volume = self.current_volume;
        }
    }

}

- (void)changeVolumeByPercent:(CGFloat)volume forKey:(NSString*)key
{
    self.current_volume += volume/100;
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
            player.volume = self.current_volume;
        }
    }
    
}

- (void)stopAllSounds
{
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
            [player pause];
        }
        [audioPlayers removeAllObjects];
    }

    [self.sounds removeAllObjects];
    self.sounds = nil;
}

- (void)pauseAllSounds
{
  for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
    for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
        [player pause];
    }
  }

}

- (void)resumeAllSounds
{
  for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
    for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
      [player play];
    }
  }

}

-(void)audioItemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:notification.object];
    if ([notification.object isKindOfClass:[CatrobatPlayerItem class]]) {
        CatrobatPlayerItem *item = (CatrobatPlayerItem*)notification.object;
        for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
            [audioPlayers removeObjectForKey:item.key];
        }
    }
    
}

//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//  CatrobatAudioPlayer *playerToDelete = (CatrobatAudioPlayer *)player;
//  for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
//    [audioPlayers removeObjectForKey:playerToDelete.key];
//  }
//}

- (CGFloat)durationOfSoundWithFilePath:(NSString*)filePath
{
    NSError *error;
    AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                                          error:&error];
    return (CGFloat)avAudioPlayer.duration;
}

@end
