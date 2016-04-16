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

#import <Foundation/Foundation.h>
#import "CatrobatAudioPlayer.h"

@interface SoundCache : NSObject <NSCacheDelegate>

@property (nonatomic, strong, readonly) dispatch_queue_t soundCacheQueue; // readonly access for subclasses

+ (instancetype)sharedSoundCache;

- (CatrobatAudioPlayer*)cachedSoundForName:(NSString*)name;

- (CatrobatAudioPlayer*)cachedSoundForPath:(NSString*)path;

- (void)addSound:(CatrobatAudioPlayer*)image withName:(NSString*)name;

- (void)replaceSound:(CatrobatAudioPlayer*)image withName:(NSString*)name;

- (void)loadSoundFromDiskWithPath:(NSString*)path
                     onCompletion:(void(^)(CatrobatAudioPlayer *playerItem, NSString* path))completion;

- (CatrobatAudioPlayer *)loadSoundFromDiskWithPath:(NSString*)path;

- (void)clearSoundCache;

@end
