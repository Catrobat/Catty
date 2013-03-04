//
//  HideBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "HideBrick.h"

@implementation HideBrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite hide];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"HideBrick"];
}

@end
