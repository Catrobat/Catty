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


#import "Setbrightnessbrick.h"
#import "Formula.h"
#import "Look.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import <CoreImage/CoreImage.h>

@implementation SetBrightnessBrick


-(SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        CGFloat brightness = [self.brightness interpretDoubleForSprite:self.object];
        Look* look = [self.object currentLook];
        UIImage* lookImage = [UIImage imageWithContentsOfFile:[self pathForLook:look]];
      
        CIImage* image = lookImage.CIImage;
      
        CIContext *context = [CIContext contextWithOptions:nil];
      
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                    keysAndValues:kCIInputImageKey, image, @"inputBrightness",
                          [NSNumber numberWithFloat:brightness], nil];
        CIImage *outputImage = [filter valueForKey:@"outputImage"];
      
        CGImageRef cgimg =
        [context createCGImage:outputImage fromRect:[outputImage extent]];

        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        //lookImage = [UIImage setImage:lookImage WithBrightness:(brightness)];
        self.object.currentUIImageLook = newImage;
        self.object.texture = [SKTexture textureWithImage:newImage];
        CGImageRelease(cgimg);
  
        }];
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
