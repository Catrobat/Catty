//
//  GoNStepsBackBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GoNStepsBackBrick.h"

@implementation GoNStepsBackBrick

@synthesize n = _n;

-(id)initWithN:(int)n
{
    self = [super init];
    if (self)
    {
        self.n = n;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite goNStepsBack:self.n];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoNStepsBack (%d)", self.n];
}


@end
