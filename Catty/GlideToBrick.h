//
//  GlideToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface GlideToBrick : Brick

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) int durationInMilliSecs;

-(id)initWithPosition:(GLKVector3)position andDurationInMilliSecs:(int)durationInMilliSecs;

@end
