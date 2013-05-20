//
//  IfLogicElseBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "IfLogicElseBrick.h"

@implementation Iflogicelsebrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Logic Else Brick"];
}

@end
