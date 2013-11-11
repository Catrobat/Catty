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

#import "Setlookbrick.h"
#import "SpriteObject.h"
#import "ProgramDefines.h"
#import <SpriteKit/SpriteKit.h>

@implementation SetLookBrick


-(SKAction*)action
{
    UIImage* image = [UIImage imageWithContentsOfFile:[self pathForLook]];
    
    CGRect newRect = [self cropRectForImage:image];
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    SKTexture* texture = [SKTexture textureWithImage:newImage];
    self.object.currentUIImageLook = newImage;

    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        double xScale = self.object.xScale;
        double yScale = self.object.yScale;
        self.object.xScale = 1.0;
        self.object.yScale = 1.0;
        self.object.size = texture.size;
        self.object.texture = texture;
        self.object.currentLook = self.look;
        if(xScale != 1.0) {
            self.object.xScale = xScale;
        }
        if(yScale != 1.0) {
            self.object.yScale = yScale;
        }
    }];
}

- (CGRect)cropRectForImage:(UIImage *)image {
    
    CGImageRef cgImage = image.CGImage;
    CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
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

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
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
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

-(NSString*)pathForLook
{
  return [NSString stringWithFormat:@"%@%@/%@", [self.object projectPath], kProgramImagesDirName, self.look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
  return [NSString stringWithFormat:@"SetLookBrick (Look: %@)", self.look.name];
}

@end
