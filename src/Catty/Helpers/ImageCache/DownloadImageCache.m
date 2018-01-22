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

#import "DownloadImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "AppDelegate.h"

#define kOneWeekImageCacheAge 60 * 60 * 24 * 7;
#define kImageCacheDirectory @"at.tugraz.ist.catrobat.ImageCache"

@interface DownloadImageCache()

@property (nonatomic, strong, readwrite) NSString *imageCacheDirectory;

@end

@implementation DownloadImageCache

- (id)init
{
    self = [super init];
    if (self) {
        [self subscribeToAppEvents];
    }
    return self;
}

- (NSString*)imageCacheDirectory
{
    if (! _imageCacheDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _imageCacheDirectory = [paths[0] stringByAppendingPathComponent:kImageCacheDirectory];
    }
    return _imageCacheDirectory;
}

- (UIImage*)getImageWithName:(NSString*)imageName
{
    UIImage *image = [super getImageWithName:imageName];
    if (! image) {
        image = [self readImageFromDiskWithName:imageName];
        [self addImage:image withName:imageName];
    }
    return image;
}

- (void)addImage:(UIImage *)image withName:(NSString *)imageName
{
    if ((! image) || (! imageName)) {
        return;
    }
    [super addImage:image withName:imageName];
    [self storeImageToDisk:image withName:imageName];
}

- (void)subscribeToAppEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeCachedImagesFromDisk)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)removeCachedImagesFromDisk
{
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];

    NSURL *imageCacheUrl = [NSURL fileURLWithPath:self.imageCacheDirectory isDirectory:YES];
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

    for (NSURL *URL in urlsToDelete) {
        [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
    }
}

- (void)storeImageToDisk:(UIImage*)image withName:(NSString*)imageName
{
    dispatch_async(self.imageCacheQueue, ^ {
        [self createCacheDirectoryIfNotExists];
        NSString *path = [[NSString alloc] initWithFormat:@"%@/%@.png", self.imageCacheDirectory, [imageName sha1]];

        FileManager *fileManager = [FileManager sharedManager];
        if (! [fileManager fileExists:path]) {
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        }
    });
}

- (UIImage*)readImageFromDiskWithName:(NSString*)imageName
{
    NSString* path = [[NSString alloc] initWithFormat:@"%@/%@.png", self.imageCacheDirectory, [imageName sha1]];
    NSError *err = nil;
    NSData *data = [NSData dataWithContentsOfFile:path
                                        options:NSDataReadingUncached
                                          error:&err];
    return [UIImage imageWithData:data];
}

- (void)createCacheDirectoryIfNotExists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (! [fileManager fileExistsAtPath:self.imageCacheDirectory]) {
        [fileManager createDirectoryAtPath:self.imageCacheDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
}

@end
