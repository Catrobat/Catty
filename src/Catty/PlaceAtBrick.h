//
//  PlaceAtBrick.h
//  Catty
//
//  Created by Mattias Rauter on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Placeatbrick : Brick

@property (nonatomic, strong) Formula *xPosition;
@property (nonatomic, strong) Formula *yPosition;

-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition;

@end
