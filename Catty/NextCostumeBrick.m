//
//  NextCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "NextCostumeBrick.h"

@implementation NextCostumeBrick

- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite performSelectorOnMainThread:@selector(nextCostume) withObject:nil waitUntilDone:YES];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"NextCostumeBrick"];
}

@end
