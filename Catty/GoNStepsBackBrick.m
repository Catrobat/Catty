//
//  GoNStepsBackBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GoNStepsBackBrick.h"

@implementation GoNStepsBackBrick

@synthesize steps = _steps;

-(id)initWithNumberOfSteps:(NSNumber*)steps
{
    self = [super init];
    if (self)
    {
        self.steps = steps;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite goNStepsBack:self.steps.intValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoNStepsBack (%@)", self.steps];
}


@end
