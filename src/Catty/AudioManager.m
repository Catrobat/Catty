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


#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CatrobatAudioPlayer.h"

@interface AudioManager()

@property (nonatomic) NSInteger soundCounter;

@property (nonatomic, strong) NSMutableDictionary* sounds;
@property (nonatomic) float current_volume;

@end

@implementation AudioManager

static AudioManager* sharedAudioManager = nil;


+ (AudioManager *) sharedAudioManager {
    
    @synchronized(self) {
        if (sharedAudioManager == nil) {
            sharedAudioManager = [[AudioManager alloc] init];
        }
    }
    
    return sharedAudioManager;
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

- (void)playSoundWithFileName:(NSString*)fileName
                       andKey:(NSString*)key
                   atFilePath:(NSString*)filePath
                     Delegate:(id<AVAudioPlayerDelegate>) delegate
{
  NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
  if (! audioPlayers) {
    audioPlayers = [[NSMutableDictionary alloc] init];
    [self.sounds setObject:audioPlayers forKey:key];
  }
  
  CatrobatAudioPlayer* player = [audioPlayers objectForKey:fileName];
  if (! player) {
    NSURL* path = [NSURL fileURLWithPath:[self pathForSound:fileName atFilePath:filePath]];
    NSError* error = nil;
    player =[[CatrobatAudioPlayer alloc] initWithContentsOfURL:path error:&error];
    NSLogError(error);
    [player setKey:fileName];
    [audioPlayers setObject:player forKey:fileName];
  }else{
      self.soundCounter++;
      NSURL* path = [NSURL fileURLWithPath:[self pathForSound:fileName atFilePath:filePath]];
      NSError* error = nil;
      player = [[CatrobatAudioPlayer alloc] initWithContentsOfURL:path error:&error];
      NSLogError(error);
      [player setKey:[fileName stringByAppendingString:[NSString stringWithFormat:@"%d",self.soundCounter]]];
      [audioPlayers setObject:player forKey:[fileName stringByAppendingString:[NSString stringWithFormat:@"%d",self.soundCounter]]];
  }
//  if ([player isPlaying]) {
//    [player stop];
//    [player setCurrentTime:0];
//  }
    if (delegate)
        player.delegate = delegate;

    player.volume = self.current_volume;
    [player play];
}

- (void)playSoundWithFileName:(NSString*)fileName
                       andKey:(NSString*)key
                   atFilePath:(NSString*)filePath
{
  [self playSoundWithFileName:fileName andKey:key atFilePath:filePath Delegate:nil];
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

-(void)changeVolumeByPercent:(CGFloat)volume forKey:(NSString*)key
{
    self.current_volume += volume/100;
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
            player.volume = self.current_volume;
        }
    }
    
}

-(void)stopAllSounds
{
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
            [player stop];
        }
        [audioPlayers removeAllObjects];
    }
    [self.sounds removeAllObjects];
    self.sounds = nil;
    sharedAudioManager = nil;
}

-(void)pauseAllSounds
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

-(void)resumeAllSounds
{
  for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
    for(CatrobatAudioPlayer* player in [audioPlayers allValues]) {
      [player play];
    }
  }

}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  CatrobatAudioPlayer *playerToDelete = (CatrobatAudioPlayer *)player;
  for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
    [audioPlayers removeObjectForKey:playerToDelete.key];
  }
}


-(NSString*)pathForSound:(NSString*)fileName atFilePath:(NSString*)filePath
{
    return [NSString stringWithFormat:@"%@sounds/%@", filePath, fileName];
}

@end
