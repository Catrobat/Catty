/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

- (BOOL)isTransparentPixelAtPoint:(CGPoint)point inImage:(UIImage*)image
{
    point.x += (image.size.width/2);
    point.y -= (image.size.height/2);
    point.y = -point.y;
    NSInteger pointX = (NSInteger)point.x;
    NSInteger pointY = (NSInteger)point.y;
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((image.size.width  * pointY) + pointX ) * 4; // The image is png
    
    //UInt8 red = data[pixelInfo];         // If you need this info, enable it
    //UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
    //UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
    UInt8 alpha;
    if (pixelInfo >= 0) {
        alpha = data[pixelInfo + 3];
        NSLog(@"Alpha: %i",alpha);
    }else{
        return YES;
    }
    CFRelease(pixelData);
    
    //UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    if (alpha) return NO;
    else return YES;

}

- (BOOL)isTransparentPixel:(UIImage*)image withX:(CGFloat)x andY:(CGFloat)y
{
    x += (image.size.width/2);
    y -= (image.size.height/2);
    y = -y;
    NSInteger pointX = (NSInteger)x;
    NSInteger pointY = (NSInteger)y;
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), CGPointMake(pointX,pointY))) {
        return YES;
    }
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = (NSUInteger)image.size.width;
    NSUInteger height = (NSUInteger)image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGBitmapInfo oldBitmapInfo = CGImageGetBitmapInfo(cgImage);
    CGImageAlphaInfo alphaInfo = oldBitmapInfo & kCGBitmapAlphaInfoMask;
    
    //Since iOS8 it's not allowed anymore to create contexts with unmultiplied Alpha info
    if (alphaInfo == kCGImageAlphaLast) {
        alphaInfo = kCGImageAlphaPremultipliedLast;
    }
    if (alphaInfo == kCGImageAlphaFirst) {
        alphaInfo = kCGImageAlphaPremultipliedFirst;
    }
    
    //reset the bits
    CGBitmapInfo newBitmapInfo = oldBitmapInfo & ~kCGBitmapAlphaInfoMask;
    
    //set the bits to the new alphaInfo
    newBitmapInfo |= alphaInfo;

    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 newBitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);

    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    if (alpha == 0){
        return YES;
    }
    return NO;
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
