//
//  ChangeGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeGhostEffectByNBrick.h"

@implementation ChangeGhostEffectByNBrick

@synthesize changeGhostEffect = _changeGhostEffect;


-(id)initWithValueForGhostEffectChange:(NSNumber*)value;
{
    self = [super init];
    if (self)
    {
        self.changeGhostEffect = value;
    }
    return self;
}

- (void)performFromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite changeTransparencyBy:self.changeGhostEffect];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeGhostEffect by (%f)", self.changeGhostEffect.floatValue];
}

@end
