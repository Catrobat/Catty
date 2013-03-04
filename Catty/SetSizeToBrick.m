//
//  SetSizeToBrick.m
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetSizeToBrick.h"

@implementation SetSizeToBrick

@synthesize size = _sizeInPercentage;


-(id)initWithSizeInPercentage:(NSNumber*)sizeInPercentage
{
    self = [super init];
    if (self)
    {
        self.size = sizeInPercentage;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite setSizeToPercentage:[self.size floatValue]];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetSizeTo (%f%%)", self.size.floatValue];
}

@end
