//
//  SetXBrick.h
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Setxbrick : Brick

@property (nonatomic, strong) Formula *xPosition;

-(id)initWithXPosition:(NSNumber*)xPosition;

@end
