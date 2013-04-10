//
//  ChangeYBy.h
//  Catty
//
//  Created by Mattias Rauter on 27.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface Changeybynbrick : Brick

@property (nonatomic, strong) NSNumber *yMovement;


-(id)initWithChangeValueForY:(NSNumber*)y;
@end
