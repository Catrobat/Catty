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

#import "TurnLeftBrick.h"
#import "Formula.h"
#import "Util.h"

@implementation TurnLeftBrick

@synthesize degrees = _degrees;


-(SKAction*)actionWithNextAction:(SKAction *)nextAction actionKey:(NSString*)actionKey
{
    return [SKAction runBlock:^{
        double degrees = [self.degrees interpretDoubleForSprite:self.object];
        NSArray *array = [NSArray arrayWithObjects:[SKAction rotateByAngle:[Util degreeToRadians:degrees] duration:0.0f], nextAction, nil];
        [self.object runAction:[SKAction sequence:array] withKey:actionKey];
    }];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnLeft (%f degrees)", [self.degrees interpretDoubleForSprite:self.object]];
}

@end
