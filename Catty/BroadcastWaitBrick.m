//
//  BroadcastWaitBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "BroadcastWaitBrick.h"

@implementation BroadcastWaitBrick

-(id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self)
    {
        self.message = message;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite broadcastAndWait:self.message];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"BroadcastWait (Msg: %@)", self.message];
}

@end

