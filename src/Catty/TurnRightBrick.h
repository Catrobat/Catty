//
//  TurnRightBrick.h
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface Turnrightbrick : Brick

@property (nonatomic, strong) NSNumber *degrees;

-(id)initWithDegrees:(NSNumber*)degees;
@end
