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

#import "UIImage+CatrobatUIImageExtensions.h"
#import "ImageCache.h"


#define kImageDownloadQueue "at.tugraz.ist.catrobat.ImageDownloadQueue"

@interface UIImage()

@property (readwrite, strong, nonatomic) dispatch_queue_t imageCacheQueue;

@end


@implementation UIImage (CatrobatUIImageExtensions)



+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*) imageWithContentsOfURL:(NSURL *)imageURL
                   placeholderImage:(UIImage *)placeholderImage
                       onCompletion:(void (^)(UIImage *image))completion;
{
    return [self imageWithContentsOfURL:imageURL placeholderImage:placeholderImage errorImage:placeholderImage onCompletion:completion];
}

+ (UIImage*) imageWithContentsOfURL:(NSURL *)imageURL
                   placeholderImage:(UIImage *)placeholderImage
                         errorImage:(UIImage*)errorImage
                       onCompletion:(void (^)(UIImage *image))completion;
{
    UIImage* image = [[ImageCache sharedImageCache] getImageWithName:[imageURL absoluteString]];
    
    if(image)
        return image;
    
    dispatch_queue_t imageQueue = dispatch_queue_create(kImageDownloadQueue, NULL);
    dispatch_async(imageQueue, ^{
        
        UIImage* image = [[ImageCache sharedImageCache] getImageWithName:[imageURL absoluteString]];
        
        if(!image) {
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            image =[[UIImage alloc] initWithData:imageData];
        }
        
        if(!image && !errorImage) {
            image = placeholderImage;
        }
        if(!image && errorImage) {
            image = errorImage;
        }
        [[ImageCache sharedImageCache] addImage:image withName:[imageURL absoluteString] persist:YES];
        
        completion(image);
        
    });
    
    return placeholderImage;
    
}



- (UIImage*) setImage:(UIImage*) image WithBrightness:(CGFloat)brightnessFactor {
    
    if ( brightnessFactor == 0 ) {
        return image;
    }
    
    CGImageRef imgRef = image.CGImage;
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    

    uint8_t* rawData = malloc(totalBytes);
    

    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);

    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
    }

    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);

    image = [UIImage imageWithCGImage:newImg];
    CGImageRelease(newImg);
    return image;
}


@end
