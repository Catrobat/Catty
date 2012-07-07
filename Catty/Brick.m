//
//  Brick.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Brick.h"

@implementation Brick

@synthesize sprite = _sprite;

- (NSString*)description
{
    return [[NSString alloc] initWithString:self.sprite.description];
}

@end
