//
//  SetYBrick.h
//  Catty
//
//  Created by Mattias Rauter on 17.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface SetYBrick : Brick

#warning @Mattias: Changed from float to NSNumber
@property (nonatomic, strong) NSNumber *yPosition;

-(id)initWithYPosition:(NSNumber*)yPosition;

@end
