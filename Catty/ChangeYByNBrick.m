//
//  ChangeYBy.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeYByNBrick.h"

@implementation ChangeYByNBrick

@synthesize y = _y;

-(id)initWithChangeValueForY:(int)y
{
    self = [super init];
    if (self)
    {
        self.y = y;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite changeYBy:self.y];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeYBy (%d)", self.y];
}

@end
