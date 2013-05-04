//
//  IfLogicElseBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "Brick.h"

@class Iflogicbeginbrick;
@class Iflogicendbrick;

@interface Iflogicelsebrick : Brick

@property (nonatomic, strong) Iflogicbeginbrick* ifBeginBrick;
@property (nonatomic, strong) Iflogicendbrick* ifEndBrick;


@end
