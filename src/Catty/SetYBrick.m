//
//  SetYBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setybrick.h"

@implementation Setybrick

@synthesize yPosition = _yPosition;

-(id)initWithYPosition:(NSNumber*)yPosition
{
    self = [super init];
    if (self)
    {
        self.yPosition = yPosition;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    
    self.object.position = CGPointMake(self.object.position.x, self.yPosition.floatValue);
    
//    CGPoint position = CGPointMake(self.object.position.x, self.yPosition.floatValue);
//    
//    [self.object glideToPosition:position withDurationInSeconds:0 fromScript:script];
    
    
    //[self.object setYPosition:self.yPosition.floatValue];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetYBrick (y-Pos:%f)", self.yPosition.floatValue];
}


@end
