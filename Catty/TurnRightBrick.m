//
//  TurnRightBrick.m
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Turnrightbrick.h"

@implementation Turnrightbrick

@synthesize degrees = _degrees;

-(id)initWithDegrees:(NSNumber*)degees
{
    self = [super init];
    if (self)
    {
        self.degrees = degees;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object turnRight:self.degrees.floatValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnRight (%f degrees)", self.degrees.floatValue];
}

@end
