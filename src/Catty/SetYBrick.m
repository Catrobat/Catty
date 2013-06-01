//
//  SetYBrick.m
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setybrick.h"
#import "Formula.h"

@implementation Setybrick

@synthesize yPosition = _yPosition;

-(id)initWithYPosition:(NSNumber*)yPosition
{
    abort();
#warning do not use -- NSNumber changed to Formula
    self = [super init];
    if (self)
    {
        self.yPosition = yPosition;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    float yPosition = [self.yPosition interpretDoubleForSprite:self.object];
    
    self.object.position = CGPointMake(self.object.position.x, yPosition);
    
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
    return [NSString stringWithFormat:@"SetYBrick (y-Pos:%f)", [self.yPosition interpretDoubleForSprite:self.object]];
}


@end
