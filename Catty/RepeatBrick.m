//
//  RepeatBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RepeatBrick.h"

@interface RepeatBrick()
@property (strong, nonatomic) NSNumber *loopsLeft;
@end

@implementation RepeatBrick

@synthesize timesToRepeat = _numberOfLoops;
@synthesize loopsLeft = _loopsLeft;

-(id)initWithNumberOfLoops:(NSNumber*)numberOfLoops
{
    self = [super init];
    if (self)
    {
        self.timesToRepeat = numberOfLoops;
        self.loopsLeft = numberOfLoops;
    }
    return self;
}

-(BOOL)checkConditionAndDecrementLoopCounter
{
    self.loopsLeft = [NSNumber numberWithInt:self.loopsLeft.intValue-1];
    BOOL returnValue = (self.loopsLeft.intValue >= 0);
    if (!returnValue) {
        self.loopsLeft = self.timesToRepeat;
    }
    return returnValue;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations (%d iterations left)", self.timesToRepeat.intValue, self.loopsLeft.intValue];
}

@end
