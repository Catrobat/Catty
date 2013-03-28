//
//  GlideToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface Glidetobrick : Brick


#warning Changed this from durationInMilliSeconds to durationInSeconds... maybe we have to change the implementation as well ;-)
@property (nonatomic, strong) NSNumber *durationInSeconds;

@property (nonatomic, strong) NSNumber *xDestination;
@property (nonatomic, strong) NSNumber *yDestination;

-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition andDurationInMilliSecs:(NSNumber*)durationInMilliSecs;

@end
