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
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "LoopEndBrick.h"


@interface Script()
@property (assign, nonatomic) int currentBrickIndex;
@property (strong, nonatomic) NSMutableArray *startLoopIndexStack;
@property (strong, nonatomic) NSMutableArray *startLoopTimestampStack;
@property (assign, nonatomic) BOOL stop;
@end



@implementation Script

@synthesize brickList = _bricksArray;
@synthesize action = _action;
@synthesize currentBrickIndex = _currentBrickIndex;
@synthesize startLoopIndexStack = _startLoopIndexStack;
@synthesize startLoopTimestampStack = _startLoopTimestampStack;
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
-(NSMutableArray*)startLoopTimestampStack
{
    if (_startLoopTimestampStack == nil)
        _startLoopTimestampStack = [[NSMutableArray alloc]init];

    return _startLoopTimestampStack;
}

-(void)addBrick:(Brick *)brick
{
    [self.brickList addObject:brick];
}

-(void)addBricks:(NSArray *)bricks
{
    [self.brickList addObjectsFromArray:bricks];
}

-(NSArray *)getAllBricks
{
    return [NSArray arrayWithArray:self.brickList];
}


-(void)resetScript
{
    self.currentBrickIndex = -1;
    self.startLoopIndexStack = nil;
    self.startLoopTimestampStack = nil;
}

-(void)stopScript
{
    self.stop = YES;
}

-(void)runScript
{
    //TODO: check loop-condition BEFORE first iteration
            
    [self resetScript];
    if (self.currentBrickIndex < 0)
        self.currentBrickIndex = 0;
    while (!self.stop && self.currentBrickIndex < [self.brickList count]) {
        if (self.currentBrickIndex < 0)
            self.currentBrickIndex = 0;
        Brick *brick = [self.brickList objectAtIndex:self.currentBrickIndex];
        
//        if([sprite.name isEqualToString:@"Spawning"])
//        {          
//            NSLog(@"Brick: %@", [brick description]);
//        }
        
        if ([brick isKindOfClass:[ForeverBrick class]]) {
            
            if (![(ForeverBrick*)brick checkConditionAndDecrementLoopCounter]) {
                // go to end of loop
                int numOfLoops = 1;
                int tmpCounter = self.currentBrickIndex+1;
                while (numOfLoops > 0 && tmpCounter < [self.brickList count]) {
                    brick = [self.brickList objectAtIndex:tmpCounter];
                    if ([brick isKindOfClass:[ForeverBrick class]])
                        numOfLoops += 1;
                    else if ([brick isMemberOfClass:[LoopEndBrick class]])
                        numOfLoops -= 1;
                    tmpCounter += 1;
                }
                self.currentBrickIndex = tmpCounter-1;
            } else {
                [self.startLoopIndexStack addObject:[NSNumber numberWithInt:self.currentBrickIndex]];
                [self.startLoopTimestampStack addObject:[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970]]];
            }
            
        } else if ([brick isMemberOfClass:[LoopEndBrick class]]) {
            
            self.currentBrickIndex = ((NSNumber*)[self.startLoopIndexStack lastObject]).intValue-1;
            [self.startLoopIndexStack removeLastObject];
            
            double startTimeOfLoop = ((NSNumber*)[self.startLoopTimestampStack lastObject]).doubleValue;
            [self.startLoopTimestampStack removeLastObject];
            double timeToWait = 0.02f - ([[NSDate date]timeIntervalSince1970] - startTimeOfLoop); // 20 milliseconds
            NSLog(@"timeToWait (loop): %f", timeToWait);
            if (timeToWait > 0)
                [NSThread sleepForTimeInterval:timeToWait];
            
        } else {
            [brick performFromScript:self];
        }
        
        self.currentBrickIndex += 1;
        

        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!! currentBrickIndex=%d", self.currentBrickIndex);
    }
}

//-(void)glideWithSprite:(Sprite*)sprite toPosition:(GLKVector3)position withinMilliSecs:(int)timeToGlideInMilliSecs
//{
//    [sprite glideToPosition:position withinDurationInMilliSecs:timeToGlideInMilliSecs fromScript:self];
////    [self waitTimeInMilliSecs:timeToGlideInMilliSecs];
//}
//
//-(void)waitTimeInMilliSecs:(float)timeToWaitInMilliSecs
//{
////    NSLog(@"BEFORE wait %f     wait: %f sec", [[NSDate date] timeIntervalSince1970], timeToWaitInMilliSecs/1000.0f);
//    [NSThread sleepForTimeInterval:timeToWaitInMilliSecs/1000.0f];
////    NSLog(@"AFTER wait  %f", [[NSDate date] timeIntervalSince1970]);
//}

#pragma mark - Description
-(NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if ([self.brickList count] > 0)
    {
        [ret appendString:@"Bricks: \r"];
        for (Brick *brick in self.brickList)
        {
            [ret appendFormat:@"%@\r", brick];
        }
    }
    else 
    {
        [ret appendString:@"Bricks array empty!\r"];
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
