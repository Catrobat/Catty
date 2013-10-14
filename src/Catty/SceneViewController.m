/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "SceneViewController.h"
#import "Scene.h"
//#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "ProgramDefines.h"
#import "Program.h"
#import "Util.h"
#import "Script.h"
#import "SpriteObject.h"
#import "SpriteManagerDelegate.h"
#import "Brick.h"
#import "BroadcastWaitHandler.h"
#import "AudioManager.h"
#import "ProgramManager.h"
#import "SensorHandler.h"
#import "SlidingViewController.h"
#import "MenuViewController.h"
#import "ScenePresenterViewController.h"

@interface SceneViewController ()

@property (nonatomic, strong) BroadcastWaitHandler *broadcastWaitHandler;

@end

@implementation SceneViewController
@synthesize program = _program;
@synthesize skView = _skView;

# pragma getters and setters
- (BroadcastWaitHandler*)broadcastWaitHandler
{
  // lazy instantiation
  if (! _broadcastWaitHandler) {
    _broadcastWaitHandler = [[BroadcastWaitHandler alloc] init];
  }
  return _broadcastWaitHandler;
}

- (void)setProgram:(Program *)program
{
  // setting effect
  for (SpriteObject *sprite in program.objectList)
  {
    //sprite.spriteManagerDelegate = self;
    sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
    //sprite.projectPath = xmlPath;

    // TODO: change!
    for (Script *script in sprite.scriptList) {
      for (Brick *brick in script.brickList) {
        brick.object = sprite;
      }
    }
  }
  _program = program;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    ScenePresenterViewController* presenter = [self.storyboard instantiateViewControllerWithIdentifier:@"Scene"];
    presenter.hidesBottomBarWhenPushed = YES;
    
    [presenter setProgram:_program];
    self.topViewController = presenter;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}



-(void)dealloc
{
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[SensorHandler sharedSensorHandler] stopSensors];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}




@end
