//
//  IfLogicBeginBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "Brick.h"

@class Formula;
@class Ifelsebrick;
@class Ifendbrick;

@interface Iflogicbeginbrick : Brick

@property (nonatomic, strong) Formula* ifCondition;

@property (nonatomic, strong) Ifelsebrick* ifElseBrick;
@property (nonatomic, strong) Ifendbrick* ifEndBrick;
@end
