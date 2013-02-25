//
//  SetGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetGhostEffectBrick.h"

@implementation SetGhostEffectBrick

@synthesize transparency = _transparency;


-(id)initWithTransparencyInPercent:(float)transparency;
{
    self = [super init];
    if (self) {
        self.transparency = transparency;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite setTransparency:self.transparency];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetGhostEffect (%f%%)", self.transparency];
}

@end
