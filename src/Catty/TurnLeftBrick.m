//
//  TurnLeftBrick.m
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Turnleftbrick.h"
#import "Formula.h"

@implementation Turnleftbrick

@synthesize degrees = _degrees;

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    double degrees = [self.degrees interpretDoubleForSprite:self.object];
    
    [self.object turnLeft:degrees];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnLeft (%f degrees)", [self.degrees interpretDoubleForSprite:self.object]];
}

@end
