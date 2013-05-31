//
//  IfOnEdgeBounceBrick.m
//  Catty
//
//  Created by Mattias Rauter on 31.05.13.
//
//

#import "IfOnEdgeBounceBrick.h"

@implementation Ifonedgebouncebrick

- (void)performFromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object ifOnEdgeBounce];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"IfOnEdgeBounceBrick"];
}

@end
