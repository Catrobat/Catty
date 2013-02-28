//
//  GoNStepsBackBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface GoNStepsBackBrick : Brick

#warning @mattias: changed int to NSNumber and "n" to "steps"
@property (assign, nonatomic) NSNumber *steps;

-(id)initWithN:(NSNumber*)steps;

@end
