//
//  ChangeVolumeByBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface Changevolumebybrick : Brick

@property (nonatomic, nonatomic) float percent;

-(id)initWithValueInPercent:(float)percent;

@end
