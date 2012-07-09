//
//  Brick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@implementation Brick

@synthesize sprite = _sprite;

- (NSString*)description
{
    return [[NSString alloc] initWithString:self.sprite.description];
}

//abstract method (!!!)
- (void)perform
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
