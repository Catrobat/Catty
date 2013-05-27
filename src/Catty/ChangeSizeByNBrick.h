//
//  ChangeSizeByNBrick.h
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Changesizebynbrick : Brick

@property (nonatomic, strong) Formula *size;

-(id)initWithSizeChangeRate:(NSNumber*)sizeInPercentage;

@end
