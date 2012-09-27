//
//  SetVolumeToBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetVolumeToBrick : Brick

@property (nonatomic, nonatomic) float volume;

-(id)initWithVolumeInPercent:(float)volume;

@end
