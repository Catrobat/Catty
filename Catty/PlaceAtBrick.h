//
//  PlaceAtBrick.h
//  Catty
//
//  Created by Mattias Rauter on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface PlaceAtBrick : Brick

@property (nonatomic, strong) NSNumber *xPosition;
@property (nonatomic, strong) NSNumber *yPosition;

-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition;

@end
