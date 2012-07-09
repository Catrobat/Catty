//
//  StartScript.m
//  Catty
//
//  Created by Mattias Rauter on 18.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "StartScript.h"
#import "Brick.h"

@implementation StartScript

- (void)execute
{
    for (Brick *brick in self.bricksArray)
    {
        [brick perform];
    }
}

@end
