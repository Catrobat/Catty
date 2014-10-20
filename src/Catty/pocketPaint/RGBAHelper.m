/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "RGBAHelper.h"

@implementation RGBAHelper

+ (UIColor*)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy
{
  // First get the image into your data buffer
  CGImageRef imageRef = [image CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
  
  // Now your rawData contains the image data in the RGBA8888 pixel format.
  NSInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
  CGFloat redValue   = (rawData[byteIndex]     * 1.0) / 255.0;
  CGFloat greenValue = (rawData[byteIndex + 1] * 1.0) / 255.0;
  CGFloat blueValue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
  CGFloat alphaValue = (rawData[byteIndex + 3] * 1.0) / 255.0;
  
  UIColor *acolor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alphaValue];
  
  free(rawData);
  
  return acolor;
}

+ (UIImage*)setRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy andColor:(UIColor*)color
{
  //TEST1
  //  int width = image.size.width;
  //	int height = image.size.height;
  //
  //  CGFloat r,g,b,a;
  //  [color getRed:&r green:&g blue:&b alpha:&a];
  //
  //	// Create a bitmap
  //	unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
  //  NSUInteger bytesPerPixel = 4;
  //  NSUInteger bytesPerRow = bytesPerPixel * width;
  //  NSInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
  //  bitmap[byteIndex] = (unsigned char)r*255.0f;
  //	bitmap[byteIndex+1] = (unsigned char)g*255.0f;
  //  bitmap[byteIndex+2] = (unsigned char)b*255.0f;
  //  bitmap[byteIndex+3] = (unsigned char)a*255.0f;
  //
  //	// Create a UIImage using the bitmap
  //	UIImage *imageCopy = [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:width withHeight:height];
  //
  //	// Display the image copy on the GUI
  //
  //	// Cleanup
  //	free(bitmap);
  //  //  CGRect imageRect = CGRectMake(0, 0, image.size.width,image.size.height);
  //  //
  //  //  UIGraphicsBeginImageContext(image.size);
  //  //  CGContextRef context = UIGraphicsGetCurrentContext();
  //  //
  //  //  //Save current status of graphics context
  //  //  CGContextSaveGState(context);
  //  //  CGContextDrawImage(context, imageRect, image.CGImage);
  //  //
  //  //  CGContextSetFillColorWithColor(context, color.CGColor);
  //  //  CGContextFillRect(context, CGRectMake(xx,yy,1,1));
  //  //
  //  //  //    Then just save it to UIImage again:
  //  //
  //  //  CGContextRestoreGState(context);
  //  //  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  
  
  //TEST2
  CGFloat r,g,b,a;
  [color getRed:&r green:&g blue:&b alpha:&a];
  CGImageRef imageRef = [image CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);
  //  // Now your rawData contains the image data in the RGBA8888 pixel format.
  NSInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
  rawData[byteIndex] = r;
  rawData[byteIndex + 1] = g;
  rawData[byteIndex + 2] = b;
  rawData[byteIndex + 3] = a;
  //
  //
  //  CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
  //                                                            rawData,
  //                                                            width*height*4,
  //                                                            NULL);
  //
  //
  //  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  //  CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
  //  CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
  //  CGImageRef newImageRef = CGImageCreate(width,
  //                                      height,
  //                                      bitsPerComponent,
  //                                      32,
  //                                      bytesPerRow,colorSpaceRef,
  //                                      bitmapInfo,
  //                                      provider,NULL,NO,renderingIntent);
  //
  //  CGColorSpaceRelease(colorSpaceRef);
  //
  //
  //  UIImage *returnImage = [UIImage imageWithCGImage:newImageRef];
  //  CGImageRelease(newImageRef);
  //  CGDataProviderRelease(provider);
  
  
  //
  
  
  size_t bufferLength = width * height * 4;
  CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData, bufferLength, NULL);
  //  size_t bitsPerComponent = 8;
  //  size_t bitsPerPixel = 32;
  //  size_t bytesPerRow = 4 * width;
  
  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  if(colorSpaceRef == NULL) {
    NSLog(@"Error allocating color space");
    CGDataProviderRelease(provider);
    return nil;
  }
  
  CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
  CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
  
  CGImageRef iref = CGImageCreate(width,
                                  height,
                                  bitsPerComponent,
                                  32,
                                  bytesPerRow,
                                  colorSpaceRef,
                                  bitmapInfo,
                                  provider,   // data provider
                                  NULL,       // decode
                                  YES,            // should interpolate
                                  renderingIntent);
  
  uint32_t* pixels = (uint32_t*)malloc(bufferLength);
  
  if(pixels == NULL) {
    NSLog(@"Error: Memory not allocated for bitmap");
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    return nil;
  }
  
  CGContextRef newcontext = CGBitmapContextCreate(pixels,
                                                  width,
                                                  height,
                                                  bitsPerComponent,
                                                  bytesPerRow,
                                                  colorSpaceRef,
                                                  bitmapInfo);
  
  if(newcontext == NULL) {
    NSLog(@"Error context not created");
    free(pixels);
  }
  
  UIImage *newImage = nil;
  if(newcontext) {
    
    CGContextDrawImage(newcontext, CGRectMake(0.0f, 0.0f, width, height), iref);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(newcontext);
    
    // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
      float scale = [[UIScreen mainScreen] scale];
      newImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    } else {
      newImage = [UIImage imageWithCGImage:imageRef];
    }
    
    CGImageRelease(imageRef);
    CGContextRelease(newcontext);
  }
  
  CGColorSpaceRelease(colorSpaceRef);
  CGImageRelease(iref);
  CGDataProviderRelease(provider);
  
//  if(pixels) {
//    free(pixels);
//  }
  return newImage;
}

+ (UIImage*)resizeImage:(UIImage*)image withWidth:(int)width withHeight:(int)height
{
  CGSize newSize = CGSizeMake(width, height);
  float widthRatio = newSize.width/image.size.width;
  float heightRatio = newSize.height/image.size.height;
  
  if(widthRatio > heightRatio)
  {
    newSize=CGSizeMake(image.size.width*heightRatio,image.size.height*heightRatio);
  }
  else
  {
    newSize=CGSizeMake(image.size.width*widthRatio,image.size.height*widthRatio);
  }
  
  
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

@end
