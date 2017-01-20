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

#import "ImageCache.h"

#define kImageCacheQueue "at.tugraz.ist.catrobat.ImageCache"
#define kImageCacheNumberOfSubclasses 2

@interface ImageCache()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong, readwrite) dispatch_queue_t imageCacheQueue;

@end

@implementation ImageCache

static NSMutableDictionary *sharedImageCaches = nil;

// singletone for subclasses solved via multitone approach in base class
+ (instancetype)sharedImageCache
{
    @synchronized(self) {
        Class class = [self class];
        id singletoneObject = nil;
        NSString *key = NSStringFromClass(class);
        if (sharedImageCaches == nil) {
            sharedImageCaches = [NSMutableDictionary dictionaryWithCapacity:kImageCacheNumberOfSubclasses];
        } else {
            singletoneObject = sharedImageCaches[key];
            if (singletoneObject) {
                return singletoneObject;
            }
        }
        singletoneObject = [[class alloc] init];
        sharedImageCaches[key] = singletoneObject;
        return singletoneObject;
    }
}

- (NSCache*)imageCache
{
    if (! _imageCache) {
        _imageCache = [[NSCache alloc] init];
        _imageCache.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearImageCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return _imageCache;
}

- (dispatch_queue_t)imageCacheQueue
{
    if (! _imageCacheQueue) {
        _imageCacheQueue = dispatch_queue_create(kImageCacheQueue, DISPATCH_QUEUE_CONCURRENT);
    }
    return _imageCacheQueue;
}

- (void)dealloc
{
    // Should never be called, but just here for clarity really.
    abort();
}

- (UIImage*)getImageWithName:(NSString*)imageName
{
    return [self.imageCache objectForKey:imageName];
}

- (void)addImage:(UIImage*)image withName:(NSString*)imageName
{
    if ([self.imageCache objectForKey:imageName] || (! image) || (! imageName)) {
        return;
    }
    [self.imageCache setObject:image forKey:imageName];
}

- (void)replaceImage:(UIImage*)image withName:(NSString*)imageName
{
    if ([self.imageCache objectForKey:imageName] && (image) && (imageName)) {
        [self.imageCache removeObjectForKey:imageName];
        [self.imageCache setObject:image forKey:imageName];
    }
    
}

- (void)clearImageCache
{
    [self.imageCache removeAllObjects];
}

@end
