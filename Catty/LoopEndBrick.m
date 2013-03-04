//
//  EndLoopBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "loopEndBrick.h"

@implementation LoopEndBrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"EndLoop"];
}

@end
