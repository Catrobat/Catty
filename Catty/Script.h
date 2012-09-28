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
@class Sprite;

@interface Script : NSObject

@property (nonatomic, assign) TouchAction action;


-(void)addBrick:(Brick*)brick;
-(void)addBricks:(NSArray*)bricks;
-(NSArray*)getAllBricks;

-(NSString*)description;

-(void)resetScript;
-(void)stopScript;

-(void)runScriptForSprite:(Sprite*)sprite;

-(void)glideWithSprite:(Sprite*)sprite toPosition:(GLKVector3)position withinMilliSecs:(int)timeToGlideInMilliSecs;
-(void)waitTimeInMilliSecs:(float)timeToWaitInMilliSecs;

@end
