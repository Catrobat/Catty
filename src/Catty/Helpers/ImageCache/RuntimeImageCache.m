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

#import "RuntimeImageCache.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "AppDelegate.h"

@interface RuntimeImageCache()

@end

@implementation RuntimeImageCache

- (UIImage*)cachedImageForName:(NSString*)imageName
{
    return [super getImageWithName:imageName];
}

- (UIImage*)cachedImageForPath:(NSString*)path
{
    return [super getImageWithName:path];
}

- (void)loadImageWithName:(NSString*)imageName
             onCompletion:(void(^)(UIImage *image))completion
{
    dispatch_async(self.imageCacheQueue, ^{
        UIImage *image = [UIImage imageNamed:imageName];
        [super addImage:image withName:imageName];

        // run completion handling block on main queue
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

        // run completion handling block on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(image,path);
        });
    });
}

- (void)loadThumbnailImageFromDiskWithThumbnailPath:(NSString*)thumbnailPath
                                          imagePath:(NSString*)imagePath
                                 thumbnailFrameSize:(CGSize)thumbnailFrameSize
                                       onCompletion:(void(^)(UIImage *image, NSString* path))completion
{
    dispatch_async(self.imageCacheQueue, ^{
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([appDelegate.fileManager fileExists:thumbnailPath]) {
            [self loadImageFromDiskWithPath:thumbnailPath
                               onCompletion:completion];
            return;
        }

        // create thumbnail
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

        // generate thumbnail image (retina)
        CGSize thumbnailImageSize = CGSizeMake(thumbnailFrameSize.width, thumbnailFrameSize.height);
        // determine right aspect ratio
        if (image.size.height > image.size.width)
            thumbnailImageSize.width = (image.size.width*thumbnailImageSize.width)/image.size.height;
        else
            thumbnailImageSize.height = (image.size.height*thumbnailImageSize.height)/image.size.width;

        UIGraphicsBeginImageContext(thumbnailImageSize);
        UIImage *thumbnailImage = [image copy];
        [thumbnailImage drawInRect:CGRectMake(0, 0, thumbnailImageSize.width, thumbnailImageSize.height)];
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [UIImagePNGRepresentation(thumbnailImage) writeToFile:thumbnailPath atomically:YES];
        [super addImage:thumbnailImage withName:thumbnailPath];

        // run completion handling block on main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(thumbnailImage,nil);
        });
    });
}

- (void)overwriteThumbnailImageFromDiskWithThumbnailPath:(NSString*)thumbnailPath image:(UIImage*)image thumbnailFrameSize:(CGSize)thumbnailFrameSize
{
        // generate thumbnail image (retina)
    CGSize thumbnailImageSize = CGSizeMake(thumbnailFrameSize.width, thumbnailFrameSize.height);
        // determine right aspect ratio
    if (image.size.height > image.size.width)
        thumbnailImageSize.width = (image.size.width*thumbnailImageSize.width)/image.size.height;
    else
        thumbnailImageSize.height = (image.size.height*thumbnailImageSize.height)/image.size.width;
    
    UIGraphicsBeginImageContext(thumbnailImageSize);
    UIImage *thumbnailImage = [image copy];
    [thumbnailImage drawInRect:CGRectMake(0, 0, thumbnailImageSize.width, thumbnailImageSize.height)];
    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [UIImagePNGRepresentation(thumbnailImage) writeToFile:thumbnailPath atomically:YES];
    [self clearImageCache];
}


- (void)clearImageCache
{
    [super clearImageCache];
}

@end
