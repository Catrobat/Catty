//
//  SetVolumeToBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetVolumeToBrick : Brick

#warning @Mattias: Changed from float to NSNumber*
@property (nonatomic, strong) NSNumber *volume;

-(id)initWithVolumeInPercent:(NSNumber*)volume;

@end
