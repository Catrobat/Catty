//
//  WhenScript.m
//  Catty
//
//  Created by Mattias Rauter on 18.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "WhenScript.h"
#import "Brick.h"

@implementation WhenScript

@synthesize action = _action;

- (void)execute
{
    for (Brick *brick in self.bricksArray)
    {
        [brick perform];
    }
}

@end
