//
//  SetSizeToBrick.h
//  Catty
//
//  Created by Mattias Rauter on 26.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
#import "SpriteObject.h"

@interface Setsizetobrick : Brick

@property (nonatomic, strong) NSNumber *size;

-(id)initWithSizeInPercentage:(NSNumber*)sizeInPercentage;

@end
