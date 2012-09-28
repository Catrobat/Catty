//
//  ChangeGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeGhostEffectBrick : Brick

@property (assign, nonatomic) float increase;

-(id)initWithIncrease:(float)increase;

@end
