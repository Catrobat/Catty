/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "SoundCache.h"

#define kSoundCacheQueue "at.tugraz.ist.catrobat.SoundCache"
#define kSoundCacheNumberOfSubclasses 2

@interface SoundCache()

@property (nonatomic, strong) NSCache *soundCache;
@property (nonatomic, strong, readwrite) dispatch_queue_t soundCacheQueue;

@end

@implementation SoundCache

static NSMutableDictionary *sharedSoundCaches = nil;

// singletone for subclasses solved via multitone approach in base class
+ (instancetype)sharedSoundCache
{
    @synchronized(self) {
        Class class = [self class];
        id singletoneObject = nil;
        NSString *key = NSStringFromClass(class);
        if (sharedSoundCaches == nil) {
            sharedSoundCaches = [NSMutableDictionary dictionaryWithCapacity:kSoundCacheNumberOfSubclasses];
        } else {
            singletoneObject = sharedSoundCaches[key];
            if (singletoneObject) {
                return singletoneObject;
            }
        }
        singletoneObject = [[class alloc] init];
        sharedSoundCaches[key] = singletoneObject;
        return singletoneObject;
    }
}

- (NSCache*)soundCache
{
    if (! _soundCache) {
        _soundCache = [[NSCache alloc] init];
        _soundCache.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearSoundCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return _soundCache;
}

- (dispatch_queue_t)imageCacheQueue
{
    if (! _soundCacheQueue) {
        _soundCacheQueue = dispatch_queue_create(kSoundCacheQueue, DISPATCH_QUEUE_CONCURRENT);
    }
    return _soundCacheQueue;
}

- (void)dealloc
{
    // Should never be called, but just here for clarity really.
    abort();
}

- (CatrobatAudioPlayer*)getSoundWithName:(NSString*)name
{
    return [self.soundCache objectForKey:name];
}

- (void)addSound:(CatrobatAudioPlayer*)playerItem withName:(NSString*)name
{
    if ([self.soundCache objectForKey:name] || (! playerItem) || (! name)) {
        return;
    }
    [self.soundCache setObject:playerItem forKey:name];
}

- (void)replaceSound:(CatrobatAudioPlayer*)playerItem withName:(NSString*)name
{
    if ([self.soundCache objectForKey:name] && (playerItem) && (name)) {
        [self.soundCache removeObjectForKey:name];
        [self.soundCache setObject:playerItem forKey:name];
    }
    
}

- (void)loadSoundFromDiskWithPath:(NSString*)path
                     onCompletion:(void(^)(CatrobatAudioPlayer *playerItem, NSString* path))completion
{
    dispatch_async(self.soundCacheQueue, ^{
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        CatrobatAudioPlayer *playerItem = [[CatrobatAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [self addSound:playerItem withName:path];
        
        // run completion handling block on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(playerItem,path);
        });
    });
}

- (CatrobatAudioPlayer *)loadSoundFromDiskWithPath:(NSString*)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    CatrobatAudioPlayer *playerItem = [[CatrobatAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self addSound:playerItem withName:path];
    return playerItem;
}

- (void)clearSoundCache
{
    [self.soundCache removeAllObjects];
}

- (CatrobatAudioPlayer*)cachedSoundForName:(NSString*)name
{
    return [self getSoundWithName:name];
}

- (CatrobatAudioPlayer*)cachedSoundForPath:(NSString*)path
{
    return [self getSoundWithName:path];
}

@end
