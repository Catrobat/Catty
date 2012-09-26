//
//  SetSizeToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetSizeToBrick : Brick

@property (assign, nonatomic) float sizeInPercentage;

-(id)initWithSizeInPercentage:(float)sizeInPercentage;

@end
