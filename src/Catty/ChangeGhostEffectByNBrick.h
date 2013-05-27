//
//  ChangeGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;


@interface Changeghosteffectbynbrick : Brick

@property (nonatomic, strong) Formula *changeGhostEffect;

-(id)initWithValueForGhostEffectChange:(NSNumber*)value;

@end
