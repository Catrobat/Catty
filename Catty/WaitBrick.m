//
//  WaitBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Waitbrick.h"
#import "Script.h"

@implementation Waitbrick

@synthesize timeToWaitInSeconds = _timeToWaitInSeconds;

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [NSThread sleepForTimeInterval:self.timeToWaitInSeconds.floatValue/1000.0f];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"WaitBrick (%d Milliseconds)", self.timeToWaitInSeconds.intValue];
}

@end
