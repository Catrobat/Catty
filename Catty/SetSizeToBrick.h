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

@property (assign, nonatomic) float size;

#warning @mattias: I've added this property (because we need it in the XML)
#warning @mattias: Please add the implementation :-S
@property (nonatomic, strong) Sprite *sprite;

-(id)initWithSizeInPercentage:(float)sizeInPercentage;

@end
