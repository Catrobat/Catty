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

#import "Setybrick.h"
#import "Formula.h"

@implementation Setybrick

@synthesize yPosition = _yPosition;

-(id)initWithYPosition:(NSNumber*)yPosition
{
    abort();
#warning do not use -- NSNumber changed to Formula
    self = [super init];
    if (self)
    {
        self.yPosition = yPosition;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    float yPosition = [self.yPosition interpretDoubleForSprite:self.object];
    
    self.object.position = CGPointMake(self.object.position.x, yPosition);
    
//    CGPoint position = CGPointMake(self.object.position.x, self.yPosition.floatValue);
//    
//    [self.object glideToPosition:position withDurationInSeconds:0 fromScript:script];
    
    
    //[self.object setYPosition:self.yPosition.floatValue];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetYBrick (y-Pos:%f)", [self.yPosition interpretDoubleForSprite:self.object]];
}


@end
