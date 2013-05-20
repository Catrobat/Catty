//
//  IfLogicEndBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "Brick.h"

@class Iflogicbeginbrick;
@class Iflogicelsebrick;


@interface Iflogicendbrick : Brick

@property (nonatomic, strong) Iflogicbeginbrick* ifBeginBrick;
@property (nonatomic, strong) Iflogicelsebrick* ifElseBrick;


#warning workaround -- Rename of Properties in New XML..
@property (nonatomic, strong) Iflogicbeginbrick* beginBrick;
@property (nonatomic, strong) Iflogicelsebrick* elseBrick;

@end
