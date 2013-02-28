//
//  CattyViewController.h
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SpriteManagerDelegate.h"

//debug
#import "Sprite.h"

//defines
#define FRAMES_PER_SECOND 30

@class Project;
@class BaseSprite;

@interface CattyViewController : GLKViewController <GLKViewControllerDelegate, SpriteManagerDelegate>

@property (strong, nonatomic) Project *level; //TODO: Array => data from xml-parser

//debug
@property (nonatomic, strong) BaseSprite *sprite;

@end
