//
//  Script.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Script.h"
#import "Brick.h"
#import "Sprite.h"
#import "LoopBrick.h"
#import "RepeatBrick.h"
#import "EndLoopBrick.h"

@interface Script()
@property (strong, nonatomic) NSMutableArray *bricksArray;
@property (assign, nonatomic) int currentBrickIndex;
@property (strong, nonatomic) NSMutableArray *startLoopIndexStack;
@end



@implementation Script

@synthesize bricksArray = _bricksArray;
@synthesize action = _action;
@synthesize currentBrickIndex = _currentBrickIndex;
@synthesize startLoopIndexStack = _startLoopIndexStack;


- (id)init
{
    if (self = [super init])
    {
        self.action = kTouchActionTap;
        self.currentBrickIndex = 0;
    }
    return self;
}

#pragma mark - Custom getter and setter
-(NSMutableArray*)bricksArray
{
    if (_bricksArray == nil)
        _bricksArray = [[NSMutableArray alloc] init];
    
    return _bricksArray;
}
-(NSMutableArray*)startLoopIndexStack
{
    if (_startLoopIndexStack == nil)
        _startLoopIndexStack = [[NSMutableArray alloc] init];
    
    return _startLoopIndexStack;
}

-(void)addBrick:(Brick *)brick
{
    [self.bricksArray addObject:brick];
}

-(void)addBricks:(NSArray *)bricks
{
    [self.bricksArray addObjectsFromArray:bricks];
}

-(NSArray *)getAllBricks
{
    return [NSArray arrayWithArray:self.bricksArray];
}

-(BOOL)performNextBrickOnSprite:(Sprite*)sprite
{
    if (self.currentBrickIndex >= [self.bricksArray count])
        return true;
    
    Brick *nextBrick = (Brick*)[self.bricksArray objectAtIndex:self.currentBrickIndex];
    
    if ([nextBrick isKindOfClass:[LoopBrick class]]) {
        [self.startLoopIndexStack addObject:[NSNumber numberWithInt:self.currentBrickIndex]];
    } else if ([nextBrick isMemberOfClass:[EndLoopBrick class]]) {
        int indexOfLastStartLoop = ((NSNumber*)[self.startLoopIndexStack lastObject]).intValue;
        LoopBrick *loopBrick = [self.bricksArray objectAtIndex:indexOfLastStartLoop];
        if ([loopBrick checkConditionAndDecrementLoopCounter])
            self.currentBrickIndex = indexOfLastStartLoop;
    } else {
        [nextBrick performOnSprite:sprite fromScript:self];
    }
    
    self.currentBrickIndex += 1;
    
    return (self.currentBrickIndex >= [self.bricksArray count]);
}

-(void)resetScript
{
    self.currentBrickIndex = 0;
    self.startLoopIndexStack = nil;
}

#pragma mark - Description
-(NSString*)description
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

////abstract method (!!!)
//-(void)executeForSprite:(Sprite*)sprite
//{
////    @throw [NSException exceptionWithName:NSInternalInconsistencyException
////                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
////                                 userInfo:nil];
//    
//    //chris: I think startscript and whenscript classes are not really necessary?! why did we create them?!
//    //mattias: we created them to separate scripts, cuz we did not have two membervariables in sprite-class (just ONE "script"-array)
//    //         now we have two arrays and we don't need them anymore...I'll change this later ;)
//    for (Brick *brick in self.bricksArray)
//    {
//        [brick performOnSprite:sprite];
//    }
//}


@end
