/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "RuntimeImageCache.h"
#import "CBFileManager.h"

@interface RuntimeImageCache()

@end

@implementation RuntimeImageCache

+ (instancetype)sharedImageCache {
    return [super sharedImageCache];
}

- (UIImage*)cachedImageForName:(NSString*)imageName
{
    return [super getImageWithName:imageName];
}

- (UIImage*)cachedImageForPath:(NSString*)path
{
    return [super getImageWithName:path];
}

- (UIImage*)cachedImageForPath:(NSString*)path andSize:(CGSize)size
{
    return [super getImageWithName:[self keyForPath:path andSize:size]];
}

- (void)loadImageWithName:(NSString*)imageName
             onCompletion:(void(^)(UIImage *image))completion
{
    dispatch_async(self.imageCacheQueue, ^{
        UIImage *image = [UIImage imageNamed:imageName];
        [super addImage:image withName:imageName];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}
- (void)loadImageFromDiskWithPath:(NSString*)path
{
    dispatch_async(self.imageCacheQueue, ^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [super addImage:image withName:path];
    });

}

- (void)loadImageFromDiskWithPath:(NSString*)path
                     onCompletion:(void(^)(UIImage *image, NSString* path))completion
{
    dispatch_async(self.imageCacheQueue, ^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [super addImage:image withName:path];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(image,path);
        });
    });
}

- (void)loadImageFromDiskWithPath:(NSString*)imagePath
                          andSize:(CGSize)size
                     onCompletion:(void(^)(UIImage *image, NSString* path))completion
{
    dispatch_async(self.imageCacheQueue, ^{
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

        CGSize imageSize = CGSizeMake(size.width, size.height);
        if (image.size.height > image.size.width)
            imageSize.width = (image.size.width * size.width) / image.size.height;
        else
            imageSize.height = (image.size.height * size.height) / image.size.width;

        UIGraphicsBeginImageContext(imageSize);
        UIImage *resizedImage = [image copy];
        [resizedImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [super addImage:resizedImage withName:[self keyForPath:imagePath andSize:size]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(resizedImage, imagePath);
        });
    });
}

- (void)clearImageCache
{
    [super clearImageCache];
}

- (NSString*)keyForPath:(NSString*)path andSize:(CGSize)size
{
    return [[NSString alloc] initWithFormat:@"%@_%.3f_%.3f", path, size.height, size.width];
}

@end
