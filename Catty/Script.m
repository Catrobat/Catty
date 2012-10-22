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
@property (assign, nonatomic) BOOL stop;
@end



@implementation Script

@synthesize bricksArray = _bricksArray;
@synthesize action = _action;
@synthesize currentBrickIndex = _currentBrickIndex;
@synthesize startLoopIndexStack = _startLoopIndexStack;
@synthesize stop = _stop;

- (id)init
{
    if (self = [super init])
    {
        self.action = kTouchActionTap;
        self.currentBrickIndex = 0;
        self.stop = NO;
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


-(void)resetScript
{
    self.currentBrickIndex = -1;
    self.startLoopIndexStack = nil;
}

-(void)stopScript
{
    self.stop = YES;
}

-(void)runScriptForSprite:(Sprite *)sprite
{
    //TODO: check loop-condition BEFORE first iteration
    
    NSLog(@"run script for sprite: %@", sprite.name);        
        
    [self resetScript];
    if (self.currentBrickIndex < 0)
        self.currentBrickIndex = 0;
    while (!self.stop && self.currentBrickIndex < [self.bricksArray count]) {
        if (self.currentBrickIndex < 0)
            self.currentBrickIndex = 0;
        Brick *brick = [self.bricksArray objectAtIndex:self.currentBrickIndex];
        
        if([sprite.name isEqualToString:@"Spawning"])
        {          
            NSLog(@"Brick: %@", [brick description]);
        }
        
        if ([brick isKindOfClass:[LoopBrick class]]) {
            [self.startLoopIndexStack addObject:[NSNumber numberWithInt:self.currentBrickIndex]];
            
            if (![(LoopBrick*)brick checkConditionAndDecrementLoopCounter]) {
                // go to end of loop
                int numOfLoops = 1;
                int tmpCounter = self.currentBrickIndex+1;
                while (numOfLoops > 0 && tmpCounter < [self.bricksArray count]) {
                    brick = [self.bricksArray objectAtIndex:tmpCounter];
                    if ([brick isKindOfClass:[LoopBrick class]])
                        numOfLoops += 1;
                    else if ([brick isMemberOfClass:[EndLoopBrick class]])
                        numOfLoops -= 1;
                    tmpCounter += 1;
                }
                self.currentBrickIndex = tmpCounter-1;
            }
            
        } else if ([brick isMemberOfClass:[EndLoopBrick class]]) {
            
            self.currentBrickIndex = ((NSNumber*)[self.startLoopIndexStack lastObject]).intValue-1;
            [self.startLoopIndexStack removeLastObject];
            
        } else {
            [brick performOnSprite:sprite fromScript:self];
        }
        
        self.currentBrickIndex += 1;
        

        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!! currentBrickIndex=%d", self.currentBrickIndex);
    }
}

-(void)glideWithSprite:(Sprite*)sprite toPosition:(GLKVector3)position withinMilliSecs:(int)timeToGlideInMilliSecs
{
    [sprite glideToPosition:position withinDurationInMilliSecs:timeToGlideInMilliSecs fromScript:self];
    [self waitTimeInMilliSecs:timeToGlideInMilliSecs];
}

-(void)waitTimeInMilliSecs:(float)timeToWaitInMilliSecs
{
//    NSLog(@"BEFORE wait %f     wait: %f sec", [[NSDate date] timeIntervalSince1970], timeToWaitInMilliSecs/1000.0f);
    [NSThread sleepForTimeInterval:timeToWaitInMilliSecs/1000.0f];
//    NSLog(@"AFTER wait  %f", [[NSDate date] timeIntervalSince1970]);
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
