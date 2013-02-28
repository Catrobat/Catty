//
//  LoopBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
#import "LoopEndBrick.h"

@interface ForeverBrick : Brick

#warning @mattias: I've added this property...
@property (nonatomic, strong) LoopEndBrick *loopEndBrick;

-(BOOL)checkConditionAndDecrementLoopCounter;

@end
