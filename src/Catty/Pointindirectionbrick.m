//
//  Pointtodirection.m
//  Catty
//
//  Created by Christof Stromberger on 10.04.13.
//
//

#import "Pointindirectionbrick.h"
#import "Formula.h"

@implementation Pointindirectionbrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    float deg = [self.degrees interpretDoubleForSprite:self.object];
    
    [self.object pointInDirection:deg];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PointInDirection"];
}

@end
