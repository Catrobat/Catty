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

#import "ChangeBrightnessByNBrick.h"
#import "Formula.h"
#import "UIImage+CatrobatUIImageExtensions.h"


@implementation ChangeBrightnessByNBrick

-(SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        CGFloat brightness = [self.brightness interpretDoubleForSprite:self.object];
        UIImage* currentUIImage = self.object.currentUIImageLook;
        
        if (brightness > -100.0f && brightness < 100.0f) {
            [currentUIImage setImage:currentUIImage WithBrightness:brightness];
            self.object.currentUIImageLook = currentUIImage;
            self.object.texture = [SKTexture textureWithImage:currentUIImage];
        }
        else{
                NSDebug(@"Wrong Brightness input: Should be greater than -100 and smaler than 100");
            }
        }];
}
#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeBrightnessByN (%f%%)", [self.brightness interpretDoubleForSprite:self.object]];
}


@end
