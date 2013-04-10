//
//  Pointtodirection.m
//  Catty
//
//  Created by Christof Stromberger on 10.04.13.
//
//

#import "Pointtodirectionbrick.h"

@implementation Pointtodirectionbrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object pointToDirection:self.degree.floatValue];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PointToDirection"];
}

@end
