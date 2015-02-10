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

#import "ClearGraphicEffectBrick.h"
#import "Look.h"
#import "Formula.h"
#import "Script.h"

@implementation ClearGraphicEffectBrick

- (NSString*)brickTitle
{
    return kLocalizedClearGraphicEffect;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        Look* look = [self.script.object currentLook];
        UIImage *image = [UIImage imageWithContentsOfFile:[self pathForLook:look]];
        SKTexture *texture = [SKTexture textureWithImage:image];
        self.script.object.currentUIImageLook = image;
        self.script.object.currentLookBrightness = 0;
        self.script.object.alpha = 1.0f;
        double xScale = self.script.object.xScale;
        double yScale = self.script.object.yScale;
        self.script.object.xScale = 1.0;
        self.script.object.yScale = 1.0;
        self.script.object.size = texture.size;
        self.script.object.texture = texture;
        self.script.object.currentLook = look;
        if(xScale != 1.0) {
            self.script.object.xScale = (CGFloat)xScale;
        }
        if(yScale != 1.0) {
            self.script.object.yScale = (CGFloat)yScale;
        }
        
    };
}

- (NSString*)pathForLook:(Look*)look
{
    return [NSString stringWithFormat:@"%@images/%@", [self.script.object projectPath], look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ClearGraphicEffect"];
}

@end
