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

#import "ImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"

#define kOneWeekImageCacheAge 60 * 60 * 24 * 7;
#define kImageCacheDirectory @"at.tugraz.ist.catrobat.ImageCache"
#define kImageCacheQueue "at.tugraz.ist.catrobat.ImageCache"


@interface ImageCache()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSString* imageCachePath;
@property (readwrite, strong, nonatomic) __attribute__((NSObject)) dispatch_queue_t imageCacheQueue;

@end

@implementation ImageCache



static ImageCache *sharedImageCache = nil;


+ (ImageCache *) sharedImageCache {
    
    @synchronized(self) {
        if (sharedImageCache == nil) {
            sharedImageCache = [[ImageCache alloc] init];
        }
    }
    return sharedImageCache;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.delegate = self;
        self.imageCacheQueue = dispatch_queue_create(kImageCacheQueue, DISPATCH_QUEUE_SERIAL);
        [self subscribeToAppEvents];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.imageCachePath = [paths[0] stringByAppendingPathComponent:kImageCacheDirectory];
    }
    
    return self;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
    abort();
}


-(UIImage*) getImageWithName:(NSString*)imageName;
{
    UIImage* image = [self.imageCache objectForKey:imageName];
    if(!image) {
        image = [self readImageFromDiskWithName:imageName];
        [self addImage:image withName:imageName];
    }
    return image;
}

-(void)addImage:(UIImage *)image withName:(NSString *)imageName
{
    if(![self.imageCache objectForKey:imageName] && image && imageName) {
        [self.imageCache setObject:image forKey:imageName];
        [self storeImageToDisk:image withName:imageName];
    }
}


-(void)subscribeToAppEvents {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearImageCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeCachedImagesFromDisk)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}


-(void)removeOldCachedImagesFromDisk {
    
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    
    NSURL *imageCacheUrl = [NSURL fileURLWithPath:self.imageCachePath isDirectory:YES];
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:imageCacheUrl
                                                                      includingPropertiesForKeys:@[NSURLContentAccessDateKey]
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    errorHandler:nil];
    
    NSURL *fileURL;
    while (fileURL = [directoryEnumerator nextObject])
    {
        NSInteger maxCacheAge = kOneWeekImageCacheAge;
        NSDate *maxAge = [NSDate dateWithTimeIntervalSinceNow:maxCacheAge];
        NSDate *fileLastAccessDate;
        [fileURL getResourceValue:&fileLastAccessDate forKey:NSURLContentAccessDateKey error:nil];
        
        if ([maxAge compare:fileLastAccessDate] == NSOrderedDescending) // Delete all files with access date older then cacheDate(defined elsewhere)
            [urlsToDelete addObject:fileURL];
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
}


-(void)clearImageCache {
    [self.imageCache removeAllObjects];
}


-(void)storeImageToDisk:(UIImage*)image withName:(NSString*)imageName{
    
    dispatch_async(self.imageCacheQueue, ^ {
        
        [self createCacheDirectoryIfNotExists];
        
        NSString* path = [[NSString alloc] initWithFormat:@"%@/%@.png", self.imageCachePath, [imageName sha1]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:path]) {
            
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
            NSError* error = nil;
            
            //NSDebug(@"Cache directory (%@): %@", self.imageCachePath, [fileManager contentsOfDirectoryAtPath:self.imageCachePath error:&error]);
            
            if(error) {
                NSLog(@"Error writing to image Cache Directory: %@", error);
            }
        }
    });
    
}


-(UIImage*)readImageFromDiskWithName:(NSString*)imageName {
    
    NSString* path = [[NSString alloc] initWithFormat:@"%@/%@.png", self.imageCachePath, [imageName sha1]];
    NSError *err = nil;
    NSData *data = [NSData dataWithContentsOfFile:path
                                        options:NSDataReadingUncached
                                          error:&err];
    
    return [UIImage imageWithData:data];

}


-(void)createCacheDirectoryIfNotExists {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.imageCachePath])
    {
        [fileManager createDirectoryAtPath:self.imageCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}



@end
