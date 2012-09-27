//
//  RepeatBrick.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "LoopBrick.h"

@interface RepeatBrick : LoopBrick

@property (nonatomic, assign) int numberOfLoops;

-(id)initWithNumberOfLoops:(int)numberOfLoops;

@end
