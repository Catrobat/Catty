//
//  ChangeSizeByNBrick.h
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeSizeByNBrick : Brick

#warning @Mattias: Change from float to NSNumber*
@property (nonatomic, strong) NSNumber *size;

-(id)initWithSizeChangeRate:(NSNumber*)sizeInPercentage;

@end
