//
//  ChangeXByBrick.h
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface Changexbynbrick : Brick

@property (nonatomic, strong) NSNumber *xMovement;

-(id)initWithChangeValueForX:(NSNumber*)x;

@end
