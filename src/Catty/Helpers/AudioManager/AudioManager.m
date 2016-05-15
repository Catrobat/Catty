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
                     delegate:(id<AVAudioPlayerDelegate>) delegate
{
    NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
    if (! audioPlayers) {
        audioPlayers = [[NSMutableDictionary alloc] init];
        [self.sounds setObject:audioPlayers forKey:key];
    }
    
    NSString *path =[NSString stringWithFormat:@"%@/%@", filePath, fileName];
    
    CatrobatAudioPlayer *player = [audioPlayers objectForKey:fileName];
    if (! player) {
        player = [[SoundCache sharedSoundCache] cachedSoundForPath:path];
        if (! player){
            player = [[SoundCache sharedSoundCache] loadSoundFromDiskWithPath:path];
            if (! player)
                return NO;
        }
        player.delegate = self;
        [player setKey:fileName];
        [audioPlayers setObject:player forKey:fileName];
    } else {
        self.soundCounter++;
        player.delegate = self;
        [player setKey:[fileName stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)self.soundCounter]]];
        [audioPlayers setObject:player forKey:[fileName stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)self.soundCounter]]];
    }
    //  if ([player isPlaying]) {
    //    [player stop];
    //    [player setCurrentTime:0];
    //  }
    if (delegate)
        player.delegate = delegate;
    
    player.volume = self.current_volume;
    return [player play];
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
            [player stop];
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
            if ([player isPlaying]) {
                [player pause];
            }
            else{
                [audioPlayers removeObjectForKey:player.key];
            }
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

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    CatrobatAudioPlayer *playerToDelete = (CatrobatAudioPlayer *)player;
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        [audioPlayers removeObjectForKey:playerToDelete.key];
    }
}

- (CGFloat)durationOfSoundWithFilePath:(NSString*)filePath
{
    NSError *error;
    AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                                          error:&error];
    return (CGFloat)avAudioPlayer.duration;
}

@end
