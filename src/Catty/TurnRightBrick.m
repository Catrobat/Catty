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

#import "Turnrightbrick.h"
#import "Formula.h"
#import "Util.h"

@implementation TurnRightBrick



-(SKAction*)action
{

    return [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        //[self actionBlock];
        NSDebug(@"Performing: %@", self.description);
        float degreebefore =[self.degrees interpretDoubleForSprite:self.object];
        float rad = [Util degreeToRadians:[self.degrees interpretDoubleForSprite:self.object]]/2;
        float newRad = self.object.zRotation - rad ;
        NSLog(@"%f,%f,%f",degreebefore,rad,newRad);

        [self.object setZRotation:newRad];
    }];

}


-(dispatch_block_t)actionBlock
{
    return ^{
        
        NSDebug(@"Performing: %@", self.description);
        double rad = [Util degreeToRadians:[self.degrees interpretDoubleForSprite:self.object]];
        double newRad = self.object.zRotation - rad;
        if (newRad < 0) {
            newRad += 360;
        }
        self.object.zRotation = newRad;
    };
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnRight (%f degrees)", [self.degrees interpretDoubleForSprite:self.object]];
}

@end
