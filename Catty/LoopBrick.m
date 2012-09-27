//
//  LoopBrick.m
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "LoopBrick.h"

@implementation LoopBrick

@synthesize bricks = _bricks;

-(NSArray *)bricks
{
    if (_bricks == nil)
        _bricks = [[NSArray alloc]init];
    return _bricks;
}

-(void)addBrick:(Brick *)brick
{
    self.bricks = [self.bricks arrayByAddingObject:brick];
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
//    
//    if ([self checkCondition])
//        [sprite addLoopBricks:[self.bricks arrayByAddingObject:self]];
}

-(BOOL)checkConditionAndDecrementLoopCounter
{
    return YES;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ForeverLoop with %d bricks", [self.bricks count]];
}



@end
