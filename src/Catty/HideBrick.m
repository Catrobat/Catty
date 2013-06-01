//
//  HideBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Hidebrick.h"

@implementation Hidebrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    [self.object hide];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Hidebrick"];
}

@end
