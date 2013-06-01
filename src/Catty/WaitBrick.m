//
//  WaitBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Waitbrick.h"
#import "Script.h"
#import "Formula.h"

@implementation Waitbrick

@synthesize timeToWaitInSeconds = _timeToWaitInSeconds;

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    double time = [self.timeToWaitInSeconds interpretDoubleForSprite:self.object];
    
    [NSThread sleepForTimeInterval:time];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"WaitBrick (%f Seconds)", [self.timeToWaitInSeconds interpretDoubleForSprite:self.object]];
}

@end
