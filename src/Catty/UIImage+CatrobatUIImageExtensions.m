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
#import <CoreImage/CoreImage.h>


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



+ (UIImage*) setImage:(UIImage*)uiImage WithBrightness:(CGFloat)brightness {
  
  CIImage* image = uiImage.CIImage;
  
  CIContext *context = [CIContext contextWithOptions:nil];

  CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                      keysAndValues:kCIInputImageKey, image, @"inputBrightness",
            [NSNumber numberWithFloat:brightness], nil];
  CIImage *outputImage = [filter valueForKey:@"outputImage"];
  
  CGImageRef cgimg =
  [context createCGImage:outputImage fromRect:[outputImage extent]];
  
  UIImage *newImage = [UIImage imageWithCGImage:cgimg];

  CGImageRelease(cgimg);
  
  return newImage;
}

- (CGRect)cropRectForImage:(UIImage *)image {
    
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
    int lowX = width;
    int lowY = height;
    int highX = 0;
    int highY = 0;
    if (data != NULL) {
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                int pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
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
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
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
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);

    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

-(BOOL)isTransparentPixel:(UIImage*)image withX:(CGFloat)x andY:(CGFloat)y
{

    x += (image.size.width/2);
    y += (image.size.height/2);
    CGImageRef cgImage = image.CGImage;
    CGContextRef context = [self newARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return NO;
    
    
    size_t width =CGBitmapContextGetHeight(context);
    size_t height = CGBitmapContextGetWidth(context);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);

    CGContextRelease(context);
    if (data != NULL) {
        int pixelIndex = (int)(width*y + x)*4;
        NSDebug(@"alpha:%d",(int)data[pixelIndex]);
                if ((int)data[pixelIndex] == 0) {
                    free(data);
                    return YES;
                }else{
                    free(data);
                    return NO;
                }
        free(data);
    }
    
    return NO;
    
   }


@end
