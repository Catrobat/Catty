//
//  SetGhostEffectBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setghosteffectbrick.h"

@implementation Setghosteffectbrick

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
    
    [self.object setTransparencyInPercent:self.transparency.floatValue];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetGhostEffect (%f%%)", self.transparency.floatValue];
}

@end
