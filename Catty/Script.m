//
//  Script.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Script.h"
#import "Brick.h"

@implementation Script

@synthesize bricksArray = _bricksArray;

- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if ([self.bricksArray count] > 0)
    {
        [ret appendString:@"Bricks: \n"];
        for (Brick *brick in self.bricksArray)
        {
            [ret appendFormat:@"\t\t - %@", brick];
        }
    }
    else 
    {
        [ret appendString:@"Bricks array empty!\n"];
    }
    
    return ret;
}

//abstract method (!!!)
- (void)execute
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


@end
