//
//  PlaceAtBrick.h
//  Catty
//
//  Created by Mattias Rauter on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface PlaceAtBrick : Brick

@property (nonatomic, assign) GLKVector3 position;

-(id)initWithPosition:(GLKVector3)position;

@end
