//
//  ChangeXByBrick.m
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Changexbynbrick.h"
#import "Formula.h"
#import "Logger.h"

@implementation Changexbynbrick

@synthesize xMovement = _xMovement;


- (void)performFromScript:(Script*)script
{
    //NSLog(@"Performing: %@", self.description);
    
    [[Logger instance] logAtLevel:debug withFormat:@"test" arguments:@"hallo"];
    
    double xMov = [self.xMovement interpretDoubleForSprite:self.object];
    [self.object changeXBy:xMov];
}

#pragma mark - Description
- (NSString*)description
{
    double xMov = [self.xMovement interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"ChangeXBy (%f)", xMov];
}

@end
