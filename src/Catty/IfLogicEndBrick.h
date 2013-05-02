//
//  IfLogicEndBrick.h
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "Brick.h"

@class Beginbrick;
@class Elsebrick;

@interface Iflogicendbrick : Brick

@property (nonatomic, strong) Beginbrick* beginBrick;
@property (nonatomic, strong) Elsebrick* elseBrick;

@end
