//
//  ChangeGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeGhostEffectByNBrick : Brick

@property (nonatomic, strong) NSNumber *changeGhostEffect;

-(id)initWithValueForGhostEffectChange:(NSNumber*)value;

@end
