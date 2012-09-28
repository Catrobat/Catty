//
//  SetGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetGhostEffectBrick : Brick

@property (assign, nonatomic) float transparency;

-(id)initWithTransparencyInPercent:(float)transparency;

@end
