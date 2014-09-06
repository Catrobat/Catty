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


#import "Setbrightnessbrick.h"
#import "Formula.h"
#import "Look.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SetBrightnessBrick

- (NSString*)brickTitle
{
    return kLocalizedSetBrightness;
}

- (SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    return [SKAction runBlock:[self actionBlock]];

}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        double brightness = [self.brightness interpretDoubleForSprite:self.object]/100;
        if (brightness > 2) {
            brightness = 1.0f;
        }
        else if (brightness < 0){
            brightness = -1.0f;
        }
        else{
            brightness -= 1.0f;
        }
        Look* look = [self.object currentLook];
        UIImage* lookImage = [UIImage imageWithContentsOfFile:[self pathForLook:look]];
        
        CGImageRef image = lookImage.CGImage;
        CIImage *ciImage =[ CIImage imageWithCGImage:image];
        /////
        CIContext *context = [CIContext contextWithOptions:nil];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                      keysAndValues:kCIInputImageKey, ciImage, @"inputBrightness",
                            @(brightness), nil];
        CIImage *outputImage = [filter outputImage];
        
        // 2
        CGImageRef cgimg =
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        // 3
        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        self.object.currentUIImageLook = newImage;
        self.object.texture = [SKTexture textureWithImage:newImage];
        self.object.currentLookBrightness = (CGFloat)brightness;
        double xScale = self.object.xScale;
        double yScale = self.object.yScale;
        self.object.xScale = 1.0;
        self.object.yScale = 1.0;
        self.object.size = self.object.texture.size;
        self.object.texture = self.object.texture;
        if(xScale != 1.0) {
            self.object.xScale = (CGFloat)xScale;
        }
        if(yScale != 1.0) {
            self.object.yScale = (CGFloat)yScale;
        }
        
        // 4
        CGImageRelease(cgimg);
        
    };
}

-(NSString*)pathForLook:(Look*)look
{
  return [NSString stringWithFormat:@"%@images/%@", [self.object projectPath], look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
  return [NSString stringWithFormat:@"Set Brightness to: %f%%)", [self.brightness interpretDoubleForSprite:self.object]];
}

@end
