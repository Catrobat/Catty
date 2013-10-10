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

@interface AudioManager()

@property (nonatomic, strong) NSMutableDictionary* sounds;

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
    
    return self;
}


- (NSMutableDictionary*)sounds
{
    if(!_sounds) {
        _sounds = [[NSMutableDictionary alloc] init];
    }
    return _sounds;
}

- (void)playSoundWithFileName:(NSString*)fileName andKey:(NSString*)key atFilePath:(NSString*)filePath
{
    NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
    if(!audioPlayers) {
        audioPlayers = [[NSMutableDictionary alloc] init];
        [self.sounds setObject:audioPlayers forKey:key];
    }

    AVAudioPlayer* player = [audioPlayers objectForKey:fileName];
    if (! player) {
        NSURL* path = [NSURL fileURLWithPath:[self pathForSound:fileName atFilePath:filePath]];
        NSError* error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:&error];
        NSLogError(error);
        [audioPlayers setObject:player forKey:fileName];
    }
    if ([player isPlaying]) {
        [player stop];
        [player setCurrentTime:0];
    }
    [player play];
}

- (void)setVolumeToPercent:(CGFloat)volume forKey:(NSString*)key
{
    volume /=100;
    NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
    for (AVAudioPlayer* player in [audioPlayers allValues]) {
        player.volume = volume;
    }
    
}

-(void)changeVolumeByPercent:(CGFloat)volume forKey:(NSString*)key
{
    volume/=100;
    NSMutableDictionary* audioPlayers = [self.sounds objectForKey:key];
    for(AVAudioPlayer* player in [audioPlayers allValues]) {
        player.volume += volume;
    }
    
}

-(void)stopAllSounds
{
    for(NSMutableDictionary* audioPlayers in [self.sounds allValues]) {
        for(AVAudioPlayer* player in [audioPlayers allValues]) {
            [player stop];
        }
        [audioPlayers removeAllObjects];
    }
    [self.sounds removeAllObjects];
    self.sounds = nil;
    sharedAudioManager = nil;
}


-(NSString*)pathForSound:(NSString*)fileName atFilePath:(NSString*)filePath
{
    return [NSString stringWithFormat:@"%@sounds/%@", filePath, fileName];
}

@end
