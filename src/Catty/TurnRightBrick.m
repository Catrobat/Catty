//
//  TurnRightBrick.m
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Turnrightbrick.h"
#import "Formula.h"

@implementation Turnrightbrick

@synthesize degrees = _degrees;


- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    double degrees = [self.degrees interpretDoubleForSprite:self.object];
    
    [self.object turnRight:degrees];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnRight (%f degrees)", [self.degrees interpretDoubleForSprite:self.object]];
}

@end
