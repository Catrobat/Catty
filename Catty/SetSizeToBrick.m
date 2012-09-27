//
//  SetSizeToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetSizeToBrick.h"

@implementation SetSizeToBrick

@synthesize sizeInPercentage = _sizeInPercentage;


-(id)initWithSizeInPercentage:(float)sizeInPercentage
{
    self = [super init];
    if (self)
    {
        self.sizeInPercentage = sizeInPercentage;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite setSizeToPercentage:self.sizeInPercentage];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetSizeTo (%f%%)", self.sizeInPercentage];
}

@end
