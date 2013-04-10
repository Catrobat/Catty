//
//  CattyAppDelegate.h
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import <GLKit/GLKit.h>
#import "FileManager.h"

@interface CattyAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FileManager *fileManager;

@end
