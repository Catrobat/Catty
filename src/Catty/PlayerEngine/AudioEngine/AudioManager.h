/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundsTableViewController.h"

//@protocol AVAudioPlayerDelegate;

@protocol AudioManagerDelegate <NSObject>

-(void)audioItemDidFinishPlaying:(NSNotification *) notification;

@end

@interface AudioManager : NSObject <AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioRecorder* recorder;
@property(nonatomic, strong) NSTimer* loudnessTimer;
@property(nonatomic, strong) NSNumber* loudnessInDecibels;

+ (instancetype)sharedAudioManager;

- (BOOL)playSoundWithFileName:(NSString*)fileName
                       andKey:(NSString*)key
                   atFilePath:(NSString*)filePath
                     delegate:(id<AudioManagerDelegate>) delegate;
- (BOOL)playSoundWithFileName:(NSString*)fileName andKey:(NSString*)key atFilePath:(NSString*)filePath;

- (void)setVolumeToPercent:(CGFloat)volume forKey:(NSString*)key;
- (void)changeVolumeByPercent:(CGFloat)volume forKey:(NSString*)key;
- (void)stopAllSounds;
- (void)pauseAllSounds;
- (void)resumeAllSounds;
- (void)pauseSpeechSynth;
- (void)resumeSpeechSynth;
- (void)stopSpeechSynth;
- (CGFloat)durationOfSoundWithFilePath:(NSString*)filePath;
- (AVSpeechSynthesizer*)getSpeechSynth;

@end
