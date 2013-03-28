//
//  NextCostumeBrick.m
//  Catty
//
//  Created by Mattias Rauter on 16.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Nextlookbrick.h"

@implementation Nextlookbrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object performSelectorOnMainThread:@selector(nextCostume) withObject:nil waitUntilDone:YES];

//    [sprite nextCostume];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Nextlookbrick"];
}

@end
