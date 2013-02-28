//
//  SetGhostEffectBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/28/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetGhostEffectBrick : Brick

#warning @Mattias: Changed from float to NSNumber
@property (nonatomic, strong) NSNumber *transparency;

-(id)initWithTransparencyInPercent:(NSNumber*)transparency;

@end
