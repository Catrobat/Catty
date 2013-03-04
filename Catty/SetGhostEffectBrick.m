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


-(id)initWithTransparencyInPercent:(NSNumber*)transparency;
{
    self = [super init];
    if (self) {
        self.transparency = transparency;
    }
    return self;
}

- (void)performFromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite setTransparency:self.transparency.floatValue];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetGhostEffect (%f%%)", self.transparency.floatValue];
}

@end
