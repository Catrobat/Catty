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
@class Iflogicendbrick;
@class Iflogicelsebrick;


@interface Iflogicbeginbrick : Brick

@property (nonatomic, strong) Formula* ifCondition;

#warning weak?!
@property (nonatomic, weak) Iflogicelsebrick* ifElseBrick;
@property (nonatomic, weak) Iflogicendbrick* ifEndBrick;

-(BOOL)checkCondition;

@end
