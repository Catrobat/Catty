//
//  LoopBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface LoopBrick : Brick

@property (nonatomic, strong) NSArray *bricks;

-(void)addBrick:(Brick*)brick;
-(BOOL)checkConditionAndDecrementLoopCounter;

@end
