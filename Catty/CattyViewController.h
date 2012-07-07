//
//  CattyViewController.h
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class Level;

@interface CattyViewController : GLKViewController

@property (strong, nonatomic) Level *level; //TODO: Array => data from xml-parser

@end
