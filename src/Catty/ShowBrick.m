//
//  ShowBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Showbrick.h"

@implementation Showbrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    [self.object show];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Showbrick"];
}

@end
