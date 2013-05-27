//
//  SetVolumeToBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Setvolumetobrick : Brick

@property (nonatomic, strong) Formula *volume;

-(id)initWithVolumeInPercent:(NSNumber*)volume;

@end
