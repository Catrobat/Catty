//
//  RepeatBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Repeatbrick.h"
#import "Formula.h"

@interface Repeatbrick()
@property int loopsLeft;
@end

@implementation Repeatbrick

@synthesize timesToRepeat = _timesToRepeat;
@synthesize loopsLeft = _loopsLeft;




-(BOOL)checkConditionAndDecrementLoopCounter
{
    if(!self.loopsLeft) {
        self.loopsLeft = [self.timesToRepeat interpretIntegerForSprite:self.object];
    }
    self.loopsLeft -= 1;
    BOOL returnValue = (self.loopsLeft >= 0);
    if (!returnValue) {
        self.loopsLeft = [self.timesToRepeat interpretIntegerForSprite:self.object];
    }
    return returnValue;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations (%d iterations left)", [self.timesToRepeat interpretIntegerForSprite:self.object], self.loopsLeft];
}

@end
