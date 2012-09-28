//
//  NextCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "NextCostumeBrick.h"

@implementation NextCostumeBrick

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite performSelectorOnMainThread:@selector(nextCostume) withObject:nil waitUntilDone:true];

//    [sprite nextCostume];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"NextCostumeBrick"];
}

@end
