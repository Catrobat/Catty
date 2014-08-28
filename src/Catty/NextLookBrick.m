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

#import "Nextlookbrick.h"
#import "Look.h"
#import "ProgramDefines.h"
#import "UIImage+CatrobatUIImageExtensions.h"

@implementation NextLookBrick

- (NSString*)brickTitle
{
    return ([self.object isBackground] ? kLocalizedNextBackground : kLocalizedNextLook);
}

- (SKAction*)action
{

    return [SKAction runBlock:[self actionBlock]];
}

-(dispatch_block_t)actionBlock
{
return ^{
    NSDebug(@"Performing: %@", self.description);
    Look* look = [self.object nextLook];
    UIImage* image = [UIImage imageWithContentsOfFile:[self pathForLook:look]];
    SKTexture* texture= nil;
    if ([self.object isBackground]) {
        texture = [SKTexture textureWithImage:image];
        self.object.currentUIImageLook = image;
    }
    else{
        //            CGRect newRect = [image cropRectForImage:image];
        //            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
        //            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        texture = [SKTexture textureWithImage:image];
        self.object.currentUIImageLook = image;
    }
    self.object.currentUIImageLook = image;
    self.object.currentLookBrightness = 0;
    double xScale = self.object.xScale;
    double yScale = self.object.yScale;
    self.object.xScale = 1.0;
    self.object.yScale = 1.0;
    self.object.size = texture.size;
    self.object.texture = texture;
    self.object.currentLook = look;
    if(xScale != 1.0) {
        self.object.xScale = (CGFloat)xScale;
    }
    if(yScale != 1.0) {
        self.object.yScale = (CGFloat)yScale;
    }
    };
}


-(NSString*)pathForLook:(Look*)look
{
  return [NSString stringWithFormat:@"%@%@/%@", [self.object projectPath], kProgramImagesDirName, look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Nextlookbrick"];
}

@end
