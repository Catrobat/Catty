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

#pragma mark - Custom getter and setter
- (NSMutableArray*)bricksArray
{
    if (_bricksArray == nil)
        _bricksArray = [[NSMutableArray alloc] init];
    
    return _bricksArray;
}

#pragma mark - Description
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
- (void)executeForSprite:(Sprite*)sprite
{
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];
    
    //chris: I think startscript and whenscript classes are not really necessary?! why did we create them?!
    for (Brick *brick in self.bricksArray)
    {
        [brick performOnSprite:sprite];
    }
}


@end
