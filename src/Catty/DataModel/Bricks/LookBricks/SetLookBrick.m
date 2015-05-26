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

#import "SetLookBrick.h"
#import "SpriteObject.h"
#import "ProgramDefines.h"
#import <SpriteKit/SpriteKit.h>
#import "UIImage+CatrobatUIImageExtensions.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation SetLookBrick

- (NSString*)brickTitle
{
    return ([self.script.object isBackground] ? kLocalizedSetBackground : kLocalizedSetLook);
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    UIImage* image = [UIImage imageWithContentsOfFile:[self pathForLook]];
    SKTexture* texture = nil;
    if ([self.script.object isBackground]) {
        texture = [SKTexture textureWithImage:image];
        self.script.object.spriteNode.currentUIImageLook = image;
    } else {
        //        CGRect newRect = [image cropRectForImage:image];
        //        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
        //        UIImage *newImage = [UIImage imageWithCGImage:imageRef];
        //        CGImageRelease(imageRef);
        texture = [SKTexture textureWithImage:image];
        self.script.object.spriteNode.currentUIImageLook = image;
    }
    self.script.object.spriteNode.currentLookBrightness = 0;
    return ^{
        NSDebug(@"Performing: %@", self.description);
        if(image && texture) {
            double xScale = self.script.object.spriteNode.xScale;
            double yScale = self.script.object.spriteNode.yScale;
            self.script.object.spriteNode.xScale = 1.0;
            self.script.object.spriteNode.yScale = 1.0;
            self.script.object.spriteNode.size = texture.size;
            self.script.object.spriteNode.texture = texture;
            self.script.object.spriteNode.currentLook = self.look;
            if(xScale != 1.0) {
                self.script.object.spriteNode.xScale = (CGFloat)xScale;
            }
            if(yScale != 1.0) {
                self.script.object.spriteNode.yScale = (CGFloat)yScale;
            }
        }
    };
}

- (NSString*)pathForLook
{
    return [NSString stringWithFormat:@"%@%@/%@", [self.script.object projectPath], kProgramImagesDirName, self.look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetLookBrick (Look: %@)", self.look.name];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if([self.look isEqualToLook:((SetLookBrick*)brick).look])
        return YES;
    return NO;
}

- (Look *)lookForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.look;
}

- (void)setLook:(Look *)look forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(look)
        self.look = look;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    if(spriteObject) {
        NSArray *looks = spriteObject.lookList;
        if([looks count] > 0)
            self.look = [looks objectAtIndex:0];
        else
            self.look = nil;
    }
}

@end
