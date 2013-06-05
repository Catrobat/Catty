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


#import "Setxbrick.h"
#import "Formula.h"
#import "Logger.h"

@implementation Setxbrick

@synthesize xPosition = _xPosition;

-(id)initWithXPosition:(NSNumber*)xPosition
{
    abort();
#warning do not use any more -- NSNumber changed to Formula
    self = [super init];
    if (self)
    {
        self.xPosition = xPosition;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{

    
    NSDebug(@"Performing: %@", self.description);
    double xPosition = [self.xPosition interpretDoubleForSprite:self.object];

    self.object.position = CGPointMake(xPosition, self.object.position.y);
    
//    CGPoint position = CGPointMake(self.xPosition.floatValue, self.object.position.y);
//    
//    [self.object glideToPosition:position withDurationInSeconds:0 fromScript:script];

    
    //[self.object setXPosition:self.xPosition.floatValue];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetXBrick (x-Pos:%f)", [self.xPosition interpretDoubleForSprite:self.object]];
}

@end
