//
//  RepeatBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RepeatBrick.h"

@implementation RepeatBrick

@synthesize numberOfLoops = _numberOfLoops;

-(id)initWithNumberOfLoops:(int)numberOfLoops
{
    self = [super init];
    if (self)
    {
        self.numberOfLoops = numberOfLoops;
    }
    return self;
}

-(BOOL)checkConditionAndDecrementLoopCounter
{
    self.numberOfLoops -= 1;
    return (self.numberOfLoops > 0);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d bricks and %d iterations", [self.bricks count], self.numberOfLoops];
}

@end
