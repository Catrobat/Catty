//
//  CattyViewController.h
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

//debug
#import "Sprite.h"


@class Level;

@interface CattyViewController : GLKViewController <GLKViewControllerDelegate>

@property (strong, nonatomic) Level *level; //TODO: Array => data from xml-parser

//debug
@property (nonatomic, strong) Sprite *sprite;

@end
