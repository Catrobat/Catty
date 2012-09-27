//
//  ChangeYBy.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeYByBrick : Brick

@property (assign, nonatomic) float y;

-(id)initWithChangeValueForY:(float)y;
@end
