//
//  SetCostumeBrick.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"
#import "Look.h"
#import "SpriteObject.h"

@interface Setlookbrick : Brick

//@property (nonatomic, strong) NSNumber *indexOfCostumeInArray;

#warning @mattias: I've added these new properties (they are in the XML)
#warning @mattias: Don't forget the implementation... :-P
@property (nonatomic, strong) Look *look;

@end
