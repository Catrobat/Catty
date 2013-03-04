//
//  ChangeYBy.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeYByNBrick.h"

@implementation ChangeYByNBrick

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
    
    [self.sprite changeYBy:self.yMovement.intValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeYBy (%d)", self.yMovement.intValue];
}

@end
