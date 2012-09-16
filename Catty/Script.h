//
//  Script.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Brick;
@class Sprite;

@interface Script : NSObject


-(void)addBrick:(Brick*)brick;
-(void)addBricks:(NSArray*)bricks;
-(NSArray*)getAllBricks;

-(NSString*)description;
-(void)executeForSprite:(Sprite*)sprite;

@end
