//
//  BroadcastBrick.m
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "BroadcastBrick.h"

@implementation BroadcastBrick

@synthesize broadcastMessage = _message;

-(id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self)
    {
        self.broadcastMessage = message;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite broadcast:self.broadcastMessage];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Broadcast (Msg: %@)", self.broadcastMessage];
}

@end
