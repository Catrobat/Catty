//
//  ChangeYBy.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeYByNBrick : Brick

#warning @mattias: I've added this property
@property (nonatomic, strong) NSNumber *yMovement;

@property (assign, nonatomic) int y;

-(id)initWithChangeValueForY:(int)y;
@end
