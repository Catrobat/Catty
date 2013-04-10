//
//  ChangeYBy.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Changeybynbrick.h"

@implementation Changeybynbrick

@synthesize yMovement = _yMovement;

-(id)initWithChangeValueForY:(NSNumber*)y
{
    self = [super init];
    if (self)
    {
        self.yMovement = y;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object changeYBy:self.yMovement.floatValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeYBy (%f)", self.yMovement.floatValue];
}

@end
