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

#import "PointInDirectionBrick.h"
#import "Formula.h"
#import "Util.h"
#import "Scene.h"

@implementation PointInDirectionBrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    float deg = [self.degrees interpretDoubleForSprite:self.object];
    
    [self.object pointInDirection:deg];
}


-(SKAction*)action
{
    
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        float degrees = [self.degrees interpretDoubleForSprite:self.object];
        degrees = [((Scene*)self.object.scene) convertDegreesToScene:degrees];
        float rad = [Util degreeToRadians:degrees];
        self.object.zRotation = rad;
    }];
}


#pragma mark - Description
- (NSString*)description
{
    float deg = [self.degrees interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"PointInDirection: %f", deg];
}


@end
