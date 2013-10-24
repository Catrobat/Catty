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

#import "MenuButtonViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
//#import "ProgramLoadingInfo.h"
#import "Util.h"
#import "ProgramDefines.h"
#import <AVFoundation/AVFoundation.h>

@interface MenuButtonViewController ()

@end

@implementation MenuButtonViewController

@synthesize backButton = _backButton;
@synthesize continueButton = _continueButton;
@synthesize screenshotButton = _screenshotButton;
@synthesize restartButton = _restartButton;
@synthesize axisButton =_axisButton;

@synthesize imageView = _imageView;
@synthesize presenter = _presenter;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(20.0f, 30.0f, 44.0f, 44.0f);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back"] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back_pressed"] forState:UIControlStateHighlighted];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_back_pressed"] forState:UIControlStateSelected];
    [_backButton addTarget:self action:@selector(stopLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.backButton];
    
    self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _continueButton.frame = CGRectMake(20.0f, 100.0f, 44.0f, 44.0f);
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue"] forState:UIControlStateNormal];
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"] forState:UIControlStateHighlighted];
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"] forState:UIControlStateSelected];
    [_continueButton addTarget:self action:@selector(continueLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.continueButton];
    
    [self.view addSubview:self.backButton];
    
    self.screenshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _screenshotButton.frame = CGRectMake(20.0f, 170.0f, 44.0f, 44.0f);
    [_screenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot"] forState:UIControlStateNormal];
    [_screenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"] forState:UIControlStateHighlighted];
    [_screenshotButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"] forState:UIControlStateSelected];
    [_screenshotButton addTarget:self action:@selector(takeScreenshot:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.screenshotButton];
    
    self.restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _restartButton.frame = CGRectMake(20.0f, 240.0f, 44.0f, 44.0f);
    [_restartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart"] forState:UIControlStateNormal];
    [_restartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"] forState:UIControlStateHighlighted];
    [_restartButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"] forState:UIControlStateSelected];
    [_restartButton addTarget:self action:@selector(restartLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.restartButton];
    
    self.axisButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _axisButton.frame = CGRectMake(20.0f, 310.0f, 44.0f, 44.0f);
    [_axisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis"] forState:UIControlStateNormal];
    [_axisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"] forState:UIControlStateHighlighted];
    [_axisButton setBackgroundImage:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"] forState:UIControlStateSelected];
    [_axisButton addTarget:self action:@selector(showHideAxis:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.axisButton];
    
    UIImage *image = [UIImage imageNamed: @"menu_icon"];
    [_imageView setImage:image];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma button functions

- (void)stopLevel:(UIButton *)sender
{
    [self.navigationController setToolbarHidden:NO];
//    [self.navigationController popViewControllerAnimated:YES];
//    [_presenter goback];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.controller.navigationController setToolbarHidden:NO];
    [self.controller.navigationController setNavigationBarHidden:NO];
    
    
}

- (void)continueLevel:(UIButton *)sender
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
    
    
    UIGraphicsBeginImageContextWithOptions(self.presenter.skView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.presenter.skView drawViewHierarchyInRect:self.presenter.skView.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageWriteToSavedPhotosAlbum(snapshotImage, nil, nil, nil);
    
}

@end
