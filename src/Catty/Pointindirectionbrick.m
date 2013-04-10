//
//  Pointtodirection.m
//  Catty
//
//  Created by Christof Stromberger on 10.04.13.
//
//

#import "Pointindirectionbrick.h"

@implementation Pointindirectionbrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object pointInDirection:self.degrees.floatValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PointToDirection"];
}

@end
