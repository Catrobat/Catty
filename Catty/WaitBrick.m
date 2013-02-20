//
//  WaitBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "WaitBrick.h"
#import "Script.h"

@implementation WaitBrick

@synthesize timeToWaitInMilliseconds = _timeToWaitInMilliseconds;

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [NSThread sleepForTimeInterval:self.timeToWaitInMilliseconds.floatValue/1000.0f];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"WaitBrick (%d Milliseconds)", self.timeToWaitInMilliseconds.intValue];
}

@end
