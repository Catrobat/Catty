//
//  ChangeSizeByNBrick.m
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeSizeByNBrick.h"

@implementation ChangeSizeByNBrick

@synthesize size = _sizeInPercentage;

-(id)initWithSizeChangeRate:(float)sizeInPercentage
{
    self = [super init];
    if (self)
    {
        self.size = sizeInPercentage;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite changeSizeByN:self.size];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeSizeByN (%f%%)", self.size];
}

@end
