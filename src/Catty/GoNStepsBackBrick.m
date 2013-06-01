//
//  GoNStepsBackBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Gonstepsbackbrick.h"
#import "Formula.h"

@implementation Gonstepsbackbrick

@synthesize steps = _steps;

-(id)initWithNumberOfSteps:(NSNumber*)steps
{
    abort();
#warning do not use -- changed from NSNumber to Formula
    self = [super init];
    if (self)
    {
        self.steps = steps;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    int steps = [self.steps interpretIntegerForSprite:self.object];
    
    [self.object goNStepsBack:steps];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoNStepsBack (%d)", [self.steps interpretIntegerForSprite:self.object]];
}


@end
