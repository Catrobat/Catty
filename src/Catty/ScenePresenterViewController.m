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

#import "ScenePresenterViewController.h"
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
#import "MenuButtonViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScenePresenterViewController ()


@property (nonatomic, strong) BroadcastWaitHandler *broadcastWaitHandler;

@end

@implementation ScenePresenterViewController
@synthesize program = _program;
@synthesize skView = _skView;
@synthesize menuBtn;
@synthesize menuBackButton = _menuBackButton;
@synthesize menuContinueButton = _menuContinueButton;
@synthesize menuScreenshotButton = _menuScreenshotButton;
@synthesize menuRestartButton =_menuRestartButton;
@synthesize menuAxisButton = _menuAxisButton;

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
    
    
    [self configureScene];
    
//    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    menuBtn.frame = CGRectMake(8.0f, 10.0f, 34.0f, 24.0f);
//    [menuBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [menuBtn addTarget:self action:@selector(goback:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:self.menuBtn];
    
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(8.0f, 10.0f, 34.0f, 24.0f);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.menuBtn];
    
    [self setUpMenuButtons];

    [self setUpMenuFrames];


    //[self.view bringSubviewToFront:self.menuView];
    
    
}

-(void)setUpMenuButtons
{
    self.menuBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_menuBackButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back"] forState:UIControlStateNormal];
    [_menuBackButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back_pressed"] forState:UIControlStateHighlighted];
    [_menuBackButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back_pressed"] forState:UIControlStateSelected];
    [_menuBackButton addTarget:self action:@selector(stopLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.menuBackButton];
    
    self.menuContinueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_menuContinueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue"] forState:UIControlStateNormal];
    [_menuContinueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"] forState:UIControlStateHighlighted];
    [_menuContinueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"] forState:UIControlStateSelected];
    [_menuContinueButton addTarget:self action:@selector(continueLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.menuContinueButton];
    
    
    self.menuScreenshotButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [_menuScreenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot"] forState:UIControlStateNormal];
    [_menuScreenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"] forState:UIControlStateHighlighted];
    [_menuScreenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"] forState:UIControlStateSelected];
    [_menuScreenshotButton addTarget:self action:@selector(takeScreenshot:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.menuScreenshotButton];
    
    self.menuRestartButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [_menuRestartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart"] forState:UIControlStateNormal];
    [_menuRestartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"] forState:UIControlStateHighlighted];
    [_menuRestartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"] forState:UIControlStateSelected];
    [_menuRestartButton addTarget:self action:@selector(restartLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.menuRestartButton];
    
    self.menuAxisButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [_menuAxisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis"] forState:UIControlStateNormal];
    [_menuAxisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"] forState:UIControlStateHighlighted];
    [_menuAxisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"] forState:UIControlStateSelected];
    [_menuAxisButton addTarget:self action:@selector(showHideAxis:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.menuAxisButton];

}

-(void)setUpMenuFrames
{
    self.menuView.frame = CGRectMake(-44, 0, 0, self.menuView.frame.size.height);
    self.menuBackButton.frame = CGRectMake(-44,30, 44, 44);
    self.menuContinueButton.frame = CGRectMake(-44,100,  44, 44);
    self.menuScreenshotButton.frame = CGRectMake(-44,170,  44, 44);
    self.menuRestartButton.frame = CGRectMake(-44,240,  44, 44);
    self.menuAxisButton.frame = CGRectMake(-44,310,  44, 44);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    SKView * view= (SKView*)_skView;
    view.paused=NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void) configureScene
{
    
    SKView * skView =(SKView*)_skView;
    [self.view addSubview:skView];
    //[self.view bringSubviewToFront:skView];
#ifdef DEBUG
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
#endif
    
    //Program* program = [self loadProgram];
    CGSize programSize = CGSizeMake(self.program.header.screenWidth.floatValue, self.program.header.screenHeight.floatValue);
    
    Scene * scene = [[Scene alloc] initWithSize:programSize andProgram:self.program];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [skView presentScene:scene];
    [[ProgramManager sharedProgramManager] setProgram:self.program];
}

/*
 - (Program*)loadProgram
 {
 
 NSDebug(@"Try to load project '%@'", self.programLoadingInfo.visibleName);
 NSDebug(@"Path: %@", self.programLoadingInfo.basePath);
 
 
 NSString *xmlPath = [NSString stringWithFormat:@"%@", self.programLoadingInfo.basePath];
 
 NSDebug(@"XML-Path: %@", xmlPath);
 
 Parser *parser = [[Parser alloc]init];
 Program *program = [parser generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];
 
 if(!program) {
 
 NSString *popuperrormessage = [NSString stringWithFormat:@"Program %@ could not be loaded!",self.programLoadingInfo.visibleName];
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Program"
 message:popuperrormessage
 delegate:self
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 [alert show];
 
 }
 
 
 NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
 
 
 //setting effect
 for (SpriteObject *sprite in program.objectList)
 {
 //sprite.spriteManagerDelegate = self;
 sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
 sprite.projectPath = xmlPath;
 
 // TODO: change!
 for (Script *script in sprite.scriptList) {
 for (Brick *brick in script.brickList) {
 brick.object = sprite;
 }
 }
 }
 return program;
 }
 */

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

-(void)revealMenu:(UIButton*)sender
{

    //// WORKING!!!!!!!!!
    SKView * view= (SKView*)_skView;
    view.paused=YES;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    [UIView animateWithDuration:0.7
                          delay:0.3
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         [self.view bringSubviewToFront:self.menuView];
                         self.menuView.frame = CGRectMake(0, 0, 100, self.menuView.frame.size.height);
                         self.menuBackButton.frame = CGRectMake(20,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                         self.menuContinueButton.frame = CGRectMake(20,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                         self.menuScreenshotButton.frame = CGRectMake(20,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                         self.menuRestartButton.frame = CGRectMake(20,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                         self.menuAxisButton.frame = CGRectMake(20,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                         
                         self.menuBtn.hidden=YES;
                         
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}


-(void)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma button functions

- (void)stopLevel:(UIButton *)sender
{
    [self.navigationController setToolbarHidden:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.controller.navigationController setToolbarHidden:NO];
    [self.controller.navigationController setNavigationBarHidden:NO];
    
    
}

- (void)continueLevel:(UIButton *)sender
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{
                         self.menuView.frame = CGRectMake(0, 0, 0, self.menuView.frame.size.height);
                         self.menuBackButton.frame = CGRectMake(-44,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                         self.menuContinueButton.frame = CGRectMake(-44,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                         self.menuScreenshotButton.frame = CGRectMake(-44,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                         self.menuRestartButton.frame = CGRectMake(-44,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                         self.menuAxisButton.frame = CGRectMake(-44,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                         
                         self.backButton.hidden=NO;
                         self.menuBtn.hidden=NO;
                         
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    SKView * view= (SKView*)_skView;
    view.paused=NO;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
}

-(void)restartLevel:(UIButton*) sender
{
    NSString *popupmessage = [NSString stringWithFormat:@"Soon available"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart"
                                                    message:popupmessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)showHideAxis:(UIButton *)sender
{
    NSString *popupmessage = [NSString stringWithFormat:@"Soon available"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ShowAxis"
                                                    message:popupmessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)takeScreenshot:(UIButton *)sender
{
    //    NSString *popupmessage = [NSString stringWithFormat:@"Soon available"];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Screenshot"
    //                                                    message:popupmessage
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //    [alert show];
    
    //Screenshot function
    
    
    UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(snapshotImage, nil, nil, nil);
    
}


@end

