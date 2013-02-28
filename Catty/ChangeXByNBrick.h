//
//  ChangeXByBrick.h
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface ChangeXByNBrick : Brick

@property (assign, nonatomic) int x;

#warning @mattias: added....
@property (nonatomic, strong) NSNumber *xMovement;

-(id)initWithChangeValueForX:(int)x;

@end
