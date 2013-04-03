//
//  ChangeXByBrick.m
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Changexbynbrick.h"

@implementation Changexbynbrick

@synthesize xMovement = _xMovement;

-(id)initWithChangeValueForX:(NSNumber*)x
{
    self = [super init];
    if (self)
    {
        self.xMovement = x;
    }
    return self;
}

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object changeXBy:self.xMovement.intValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeXBy (%d)", self.xMovement.intValue];
}

@end
