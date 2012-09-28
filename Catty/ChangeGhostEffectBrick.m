//
//  ChangeGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeGhostEffectBrick.h"

@implementation ChangeGhostEffectBrick

@synthesize increase= _increase;


-(id)initWithIncrease:(float)increase;
{
    self = [super init];
    if (self)
    {
        self.increase = increase;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite setTransparency:self.increase];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeGhostEffect by (%f)", self.increase];
}

@end
