//
//  SetXBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setxbrick.h"

@implementation Setxbrick

@synthesize xPosition = _xPosition;

-(id)initWithXPosition:(NSNumber*)xPosition
{
    self = [super init];
    if (self)
    {
        self.xPosition = xPosition;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object setXPosition:self.xPosition.floatValue];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetXBrick (x-Pos:%f)", self.xPosition.floatValue];
}

@end
