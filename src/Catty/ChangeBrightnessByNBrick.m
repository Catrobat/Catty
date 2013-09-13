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


@implementation ChangeBrightnessByNBrick

-(SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
        return [SKAction runBlock:^{
            NSDebug(@"Performing: %@", self.description);
            CGFloat brightness_old = (float)[[UIScreen mainScreen] brightness];
            CGFloat brightness_add = (float)[self.brightness interpretDoubleForSprite:self.object];
            if (brightness_add > 1 || brightness_add < 1) {
                brightness_add = brightness_add/100;
            }
            CGFloat brightness_new = brightness_old + brightness_add;
            if (brightness_new  >= 0.0f){
                if (brightness_new <= 1.0f) {
                    [[UIScreen mainScreen] setBrightness: brightness_new];
                }
                else{
                    NSDebug(@"Wrong Brightness in/decrease input: Can't exceed 0 and 1 (or between 0 and 100%)");
                }
            }
            else{
                NSDebug(@"Wrong Brightness in/decrease input: Brightness can only be greater than 0");
            }
            
            
        }];
}
#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeBrightnessByN (%f%%)", [self.brightness interpretDoubleForSprite:self.object]];
}




@end
