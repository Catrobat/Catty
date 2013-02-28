//
//  ChangeGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeGhostEffectByNBrick : Brick

#warning @mattias: I've added this property
@property (nonatomic, strong) NSNumber *changeGhostEffect;


@property (assign, nonatomic) float increase;

-(id)initWithIncrease:(float)increase;

@end
