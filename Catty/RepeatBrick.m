//
//  RepeatBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RepeatBrick.h"

@interface RepeatBrick()
@property (assign, nonatomic) int loopsLeft;
@end

@implementation RepeatBrick

@synthesize numberOfLoops = _numberOfLoops;
@synthesize loopsLeft = _loopsLeft;

-(id)initWithNumberOfLoops:(int)numberOfLoops
{
    self = [super init];
    if (self)
    {
        self.numberOfLoops = numberOfLoops;
        self.loopsLeft = numberOfLoops;
    }
    return self;
}

-(BOOL)checkConditionAndDecrementLoopCounter
{
    self.loopsLeft -= 1;
    BOOL returnValue = (self.loopsLeft > 0);
    if (!returnValue) {
        self.loopsLeft = self.numberOfLoops;
    }
    return returnValue;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations (%d iterations left)", self.numberOfLoops, self.loopsLeft];
}

@end
