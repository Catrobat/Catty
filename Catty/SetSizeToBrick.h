//
//  SetSizeToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
#import "Sprite.h"

@interface SetSizeToBrick : Brick

@property (assign, nonatomic) NSNumber *size;

-(id)initWithSizeInPercentage:(NSNumber*)sizeInPercentage;

@end
