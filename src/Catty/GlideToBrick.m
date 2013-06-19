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

#import "Glidetobrick.h"
#import "Script.h"
#import "Formula.h"

@implementation GlideToBrick

@synthesize durationInSeconds = _durationInSeconds;
@synthesize xDestination = _xDestination;
@synthesize yDestination = _yDestination;


#pragma mark - override
-(void)performFromScript:(Script*)script
{
    NSDebug(@" ERROR ERROR ERROR Performing: %@", self.description);

}


-(SKAction*)actionWithNextAction:(SKAction *)nextAction actionKey:(NSString*)actionKey
{
    
    NSDebug(@"Performing: %@", self.description);
    
    [self setNextAction:nextAction];
    
    return [SKAction runBlock:^{
        double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
        double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
        double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
        CGPoint position = CGPointMake(xDestination, yDestination);

        SKAction *glideToAction = [SKAction moveTo:position duration:durationInSeconds];
        NSArray *array = [NSArray arrayWithObjects:glideToAction, self.nextAction, nil];
        [self.object runAction:[SKAction sequence:array] withKey:actionKey];
    }];
}

#pragma mark - Description
- (NSString*)description
{
    
    double xDestination = [self.xDestination interpretDoubleForSprite:self.object];
    double yDestination = [self.yDestination interpretDoubleForSprite:self.object];
    double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.object];
    
    return [NSString stringWithFormat:@"GlideTo (Position: %f/%f; duration: %f s)", xDestination, yDestination, durationInSeconds];
}

@end
