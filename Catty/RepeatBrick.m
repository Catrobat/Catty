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

@synthesize timesToRepeat = _numberOfLoops;
@synthesize loopsLeft = _loopsLeft;

#warning: changed this from int to nsnumber
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
    self.loopsLeft -= 1;
    BOOL returnValue = (self.loopsLeft >= 0);
    if (!returnValue) {
        self.loopsLeft = self.timesToRepeat;
    }
    return returnValue;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations (%d iterations left)", self.timesToRepeat, self.loopsLeft];
}

@end
