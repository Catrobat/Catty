//
//  SPStatsDisplay.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPSprite.h"

@interface SPStatsDisplay : SPSprite

@property (nonatomic) int framesPerSecond;
@property (nonatomic) int numDrawCalls;

@end
