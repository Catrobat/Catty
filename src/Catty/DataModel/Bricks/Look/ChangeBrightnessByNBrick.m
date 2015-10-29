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

#import "ChangeBrightnessByNBrick.h"
#import "Formula.h"
#import "Look.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation ChangeBrightnessByNBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.changeBrightness;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.changeBrightness = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.changeBrightness = [[Formula alloc] initWithInteger:25];
}

- (NSString*)brickTitle
{
    return kLocalizedChangeBrightnessByN;
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
        
        CGFloat brightness = (CGFloat)[self.changeBrightness interpretDoubleForSprite:self.script.object] / 100.0f;
        brightness += self.script.object.spriteNode.currentLookBrightness;
        if (brightness > 2) {
            brightness = 1;
        }
        else if (brightness < 0){
            brightness = -1;
        }
        
        Look* look = [self.script.object.spriteNode currentLook];
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
        self.script.object.spriteNode.currentUIImageLook = newImage;
        self.script.object.spriteNode.texture = [SKTexture textureWithImage:newImage];
        self.script.object.spriteNode.currentLookBrightness = brightness;
        CGFloat xScale = self.script.object.spriteNode.xScale;
        CGFloat yScale = self.script.object.spriteNode.yScale;
        self.script.object.spriteNode.xScale = 1.0;
        self.script.object.spriteNode.yScale = 1.0;
        self.script.object.spriteNode.size = self.script.object.spriteNode.texture.size;
        self.script.object.spriteNode.texture = self.script.object.spriteNode.texture;
        if(xScale != 1.0) {
            self.script.object.spriteNode.xScale = xScale;
        }
        if(yScale != 1.0) {
            self.script.object.spriteNode.yScale = yScale;
        }
        
        // 4
        CGImageRelease(cgimg);
        
           };
}



#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeBrightnessByN (%f%%)", [self.changeBrightness interpretDoubleForSprite:self.script.object]];
}

- (NSString*)pathForLook:(Look*)look
{
    return [NSString stringWithFormat:@"%@images/%@", [self.script.object projectPath], look.fileName];
}

@end
