//
//  SpriteManagerDelegate.h
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@protocol SpriteManagerDelegate <NSObject>

-(void)bringToFrontSprite:(Sprite*)sprite;

@end
