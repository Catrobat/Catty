//
//  ChangeYBy.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Changeybynbrick.h"
#import "Formula.h"

@implementation Changeybynbrick

@synthesize yMovement = _yMovement;

- (void)performFromScript:(Script*)script
{
    //NSLog(@"Performing: %@", self.description);
    
    double yMov = [self.yMovement interpretDoubleForSprite:self.object];
    [self.object changeYBy:yMov];
}

#pragma mark - Description
- (NSString*)description
{
    double xMov = [self.yMovement interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"ChangeYBy (%f)", xMov];
}

@end
