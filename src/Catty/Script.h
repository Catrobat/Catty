//
//  Script.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "enums.h"

@class Brick;
@class SpriteObject;

@interface Script : NSObject

@property (nonatomic, weak) SpriteObject *object;
@property (nonatomic, strong) NSString *action;
@property (strong, nonatomic) NSMutableArray *brickList;


-(void)addBrick:(Brick*)brick;
-(void)addBricks:(NSArray*)bricks;
-(NSArray*)getAllBricks;

-(NSString*)description;

-(void)resetScript;
-(void)stopScript;

-(void)runScript;

@end
