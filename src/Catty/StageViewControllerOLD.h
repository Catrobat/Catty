//
//  StageViewController.h
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SpriteManagerDelegate.h"
#import "SpriteManagerDelegate.h"

//defines
#define FRAMES_PER_SECOND 30


@class Level;
@class LevelLoadingInfo;

@interface StageViewControllerOLD s: GLKViewController <GLKViewControllerDelegate, SpriteManagerDelegate>

@property (strong, nonatomic) LevelLoadingInfo *levelLoadingInfo;
- (IBAction)backButtonPressed:(UIButton *)sender;

@end
