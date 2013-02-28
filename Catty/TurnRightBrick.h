//
//  TurnRightBrick.h
//  Catty
//
//  Created by Mattias Rauter on 06.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface TurnRightBrick : Brick

#warning @Mattias: Changed from float to NSNumber*
@property (nonatomic, strong) NSNumber *degrees;
-(id)initWithDegrees:(NSNumber*)degees;
@end
