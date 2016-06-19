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

#import "UIImage+CatrobatUIImageExtensions.h"
#import "DownloadImageCache.h"
#import "RGBAHelper.h"
#import "ImageHelper.h"
#import <CoreImage/CoreImage.h>

#define kImageDownloadQueue "at.tugraz.ist.catrobat.ImageDownloadQueue"

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

+ (UIImage*)imageWithContentsOfURL:(NSURL*)imageURL
                  placeholderImage:(UIImage*)placeholderImage
                        errorImage:(UIImage*)errorImage
                      onCompletion:(void (^)(UIImage *image))completion
{
    UIImage *image = [[DownloadImageCache sharedImageCache] getImageWithName:[imageURL absoluteString]];

    if(image)
        return image;

    dispatch_queue_t imageQueue = dispatch_queue_create(kImageDownloadQueue, NULL);
    dispatch_async(imageQueue, ^{

        UIImage* img = [[DownloadImageCache sharedImageCache] getImageWithName:[imageURL absoluteString]];

        if(!img) {
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            img =[[UIImage alloc] initWithData:imageData];
        }

        if(!img && !errorImage) {
            img = placeholderImage;
        }
        if(!img && errorImage) {
            img = errorImage;
        }
        [[DownloadImageCache sharedImageCache] addImage:img withName:[imageURL absoluteString]];

        completion(img);

    });

    return placeholderImage;
}

+ (UIImage*)setImage:(UIImage*)uiImage WithBrightness:(CGFloat)brightness {
  
  CIImage* image = uiImage.CIImage;
  
  CIContext *context = [CIContext contextWithOptions:nil];

  CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                      keysAndValues:kCIInputImageKey, image, @"inputBrightness",
            [NSNumber numberWithFloat:(float)brightness], nil];
  CIImage *outputImage = [filter valueForKey:@"outputImage"];
  
  CGImageRef cgimg =
  [context createCGImage:outputImage fromRect:[outputImage extent]];
  
  UIImage *newImage = [UIImage imageWithCGImage:cgimg];

  CGImageRelease(cgimg);
  
  return newImage;
}

- (CGRect)cropRectForImage:(UIImage*)image {
    
    CGImageRef cgImage = image.CGImage;
    CGContextRef context = [self newARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return CGRectZero;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    //Filter through data and look for non-transparent pixels.
    NSInteger lowX = width;
    NSInteger lowY = height;
    NSInteger highX = 0;
    NSInteger highY = 0;
    if (data != NULL) {
        for (NSInteger y=0; y<height; y++) {
            for (NSInteger x=0; x<width; x++) {
                NSInteger pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
                if (data[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                    if (x < lowX) lowX = x;
                    if (x > highX) highX = x;
                    if (y < lowY) lowY = y;
                    if (y > highY) highY = y;
                }
            }
        }
        free(data);
    } else {
        return CGRectZero;
    }
    
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}

- (CGContextRef)newARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    NSInteger bitmapByteCount;
    NSInteger bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return NULL;
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    if (context == NULL) free (bitmapData);

    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

- (BOOL)isTransparentPixelAtScenePoint:(CGPoint)scenePoint
{
    CGPoint imagePoint = CGPointMake(scenePoint.x, scenePoint.y);
    imagePoint.x += (self.size.width/2);
    imagePoint.y -= (self.size.height/2);
    imagePoint.y = -imagePoint.y;
    
    return [self isTransparentPixelAtPoint:imagePoint];
}

- (BOOL)isTransparentPixelAtPoint:(CGPoint)imagePoint
{
    CGPoint point = CGPointMake((NSInteger)imagePoint.x, (NSInteger)imagePoint.y);
    
    if (! CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return YES;
    }
    
    CGImageRef cgImage = self.CGImage;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    size_t bytesPerPixel = CGImageGetBitsPerPixel(cgImage) / 8;
    UInt8 alphaIndex = 0;
    
    switch(alphaInfo) {
        case kCGImageAlphaNone:
            return NO;
        case kCGImageAlphaNoneSkipFirst:
            return NO;
        case kCGImageAlphaNoneSkipLast:
            return NO;
        case kCGImageAlphaOnly:
            return YES;
        case kCGImageAlphaLast:
            alphaIndex = bytesPerPixel - 1;
            break;
        case kCGImageAlphaPremultipliedLast:
            alphaIndex = bytesPerPixel - 1;
            break;
        case kCGImageAlphaFirst:
            alphaIndex = 0;
            break;
        case kCGImageAlphaPremultipliedFirst:
            alphaIndex = 0;
            break;
    }
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((self.size.width  * point.y) + point.x) * bytesPerPixel;
    UInt8 alpha = data[pixelInfo + alphaIndex];
    
    CFRelease(pixelData);
    return alpha == 0;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

+ (UIImage*)changeImage:(UIImage*)image toColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}




@end
