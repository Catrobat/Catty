//
//  GlideToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 16.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Glidetobrick : Brick



#warning Changed this from durationInMilliSeconds to durationInSeconds... maybe we have to change the implementation as well ;-)
@property (nonatomic, strong) Formula *durationInSeconds;

@property (nonatomic, strong) Formula *xDestination;
@property (nonatomic, strong) Formula *yDestination;

-(id)initWithXPosition:(NSNumber*)xPosition yPosition:(NSNumber*)yPosition andDurationInSeconds:(NSNumber*)durationInMilliSecs;

@end
