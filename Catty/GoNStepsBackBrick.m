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

-(id)initWithN:(NSNumber*)steps
{
    self = [super init];
    if (self)
    {
        self.steps = steps;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite goNStepsBack:self.steps];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoNStepsBack (%@)", self.steps];
}


@end
