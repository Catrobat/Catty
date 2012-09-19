//
//  SetYBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetYBrick.h"

@implementation SetYBrick

@synthesize yPosition = _yPosition;

-(id)initWithYPosition:(float)yPosition
{
    self = [super init];
    if (self)
    {
        self.yPosition = yPosition;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite setYPosition:self.yPosition];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetYBrick (y-Pos:%f)", self.yPosition];
}


@end
