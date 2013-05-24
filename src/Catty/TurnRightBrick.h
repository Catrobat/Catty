//
//  TurnRightBrick.h
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Turnrightbrick : Brick

@property (nonatomic, strong) Formula *degrees;

-(id)initWithDegrees:(NSNumber*)degees;
@end
