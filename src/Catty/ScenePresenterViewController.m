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
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>
#import "UIColor+CatrobatUIColorExtensions.h"

@interface ScenePresenterViewController (){
    BOOL menuOpen;
}


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
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    
    
    [self setUpMenuButtons];

    [self setUpMenuFrames];

    //[self.view bringSubviewToFront:self.skView];

    [self.view bringSubviewToFront:self.menuView];
    
    
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
    self.menuView.frame = CGRectMake(0, 0, 0, self.menuView.frame.size.height);
    self.menuBackButton.frame = CGRectMake(-80,30, 44, 44);
    self.menuContinueButton.frame = CGRectMake(-80,100,  44, 44);
    self.menuScreenshotButton.frame = CGRectMake(-80,170,  44, 44);
    self.menuRestartButton.frame = CGRectMake(-80,240,  44, 44);
    self.menuAxisButton.frame = CGRectMake(-80,310,  44, 44);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    menuOpen=NO;
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
//    UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
//    [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:NO];
//    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    snapshotImage =[self applyBlurOnImage:snapshotImage withRadius:0.5];
//    
//    CGRect bounds = [self.menuView bounds];
//    [[UIColor darkBlueColor] set];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClipToMask(context, bounds, [snapshotImage CGImage]);
//    CGContextFillRect(context, bounds);
    UIColor *background = [UIColor darkBlueColor];//[[UIColor alloc] initWithPatternImage:snapshotImage];
    
    self.menuView.backgroundColor = background;
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
                         menuOpen = YES;
                         
                     }];
    
}

//- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur withRadius:(CGFloat)blurRadius
//{
//    if ((blurRadius < 0.0f) || (blurRadius > 1.0f))
//    {
//        blurRadius = 0.5f;
//    }
//    int boxSize = (int)(blurRadius * 100);
//    boxSize -= (boxSize % 2) + 1;
//    CGImageRef rawImage = imageToBlur.CGImage;
//    vImage_Buffer inBuffer;
//    vImage_Buffer outBuffer;
//    vImage_Error error;
//    void *pixelBuffer;
//    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//    inBuffer.width = CGImageGetWidth(rawImage);
//    inBuffer.height = CGImageGetHeight(rawImage);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
//    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
//    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(rawImage);
//    outBuffer.height = CGImageGetHeight(rawImage);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    if (error)
//    {
//        NSLog(@"error from convolution %ld", error);
//    }
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(imageToBlur.CGImage));
//    CGImageRef imageRef = CGBitmapContextCreateImage (ctx); UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//    //clean up
//    CGContextRelease(ctx);
//    CGColorSpaceRelease(colorSpace);
//    free(pixelBuffer);
//    CFRelease(inBitmapData);
//    CGImageRelease(imageRef);
//    return returnImage;
//}




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
                         self.menuBackButton.frame = CGRectMake(-80,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                         self.menuContinueButton.frame = CGRectMake(-80,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                         self.menuScreenshotButton.frame = CGRectMake(-80,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                         self.menuRestartButton.frame = CGRectMake(-80,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                         self.menuAxisButton.frame = CGRectMake(-80,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                         
                         self.backButton.hidden=NO;
                         self.menuBtn.hidden=NO;
                         
                     }
                     completion:^(BOOL finished){
                         menuOpen = NO;
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
                                                   delegate:self.menuView
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)showHideAxis:(UIButton *)sender
{
    NSString *popupmessage = [NSString stringWithFormat:@"Soon available"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ShowAxis"
                                                    message:popupmessage
                                                   delegate:self.menuView
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)takeScreenshot:(UIButton *)sender
{
    NSString *popupmessage = [NSString stringWithFormat:@"Saved in PhotoLibrary - should be changed to exact folder of the level!"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Screenshot"
                                                    message:popupmessage
                                                   delegate:self.menuView
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    //Screenshot function
    
    
    UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(snapshotImage, nil, nil, nil);
    
}

#pragma PanGestureHandler

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    // transform the three views by the amount of the x translation
    
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0; // I'm just doing horizontal scrolling

    
    if (gesture.state == UIGestureRecognizerStateBegan||
        gesture.state == UIGestureRecognizerStateChanged) {
        if (translate.x > 0.0 && translate.x < 100 && menuOpen == NO)
        {
            // moving right
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.view bringSubviewToFront:self.menuView];
                                 UIColor *background = [UIColor darkBlueColor];//[[UIColor alloc] initWithPatternImage:snapshotImage];
                                 self.menuView.backgroundColor = background;
                                 
                                 //pause Scene
                                 SKView * view= (SKView*)_skView;
                                 view.paused=YES;
                                 //[[AVAudioSession sharedInstance] setActive:NO error:nil];
                                 
                                 
                                 self.menuView.frame = CGRectMake(0, 0, translate.x, self.menuView.frame.size.height);
                                 self.menuBackButton.frame = CGRectMake(translate.x-80,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                                 self.menuContinueButton.frame = CGRectMake(translate.x-80,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                                 self.menuScreenshotButton.frame = CGRectMake(translate.x-80,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                                 self.menuRestartButton.frame = CGRectMake(translate.x-80,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                                 self.menuAxisButton.frame = CGRectMake(translate.x-80,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                                 self.menuBtn.hidden=YES;
                                 
                             }
                             completion:^(BOOL finished) {
                                 //menuOpen = YES;
                             }];
        }
    
        else if (translate.x < 0.0 && translate.x > -100 && menuOpen == YES)
        {
            // moving left
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.menuView.frame = CGRectMake(0, 0, 100+translate.x, self.menuView.frame.size.height);
                                 self.menuBackButton.frame = CGRectMake(20+translate.x,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                                 self.menuContinueButton.frame = CGRectMake(20+translate.x,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                                 self.menuScreenshotButton.frame = CGRectMake(20+translate.x,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                                 self.menuRestartButton.frame = CGRectMake(20+translate.x,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                                 self.menuAxisButton.frame = CGRectMake(20+translate.x,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                                 self.menuBtn.hidden=NO;
                             }
                             completion:^(BOOL finished) {
                                 SKView * view= (SKView*)_skView;
                                 view.paused=NO;
                                 //menuOpen = NO;
                             }];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed)
    {

        if (translate.x > 0.0 && menuOpen == NO)
        {
            // moving right
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.view bringSubviewToFront:self.menuView];
                                 UIColor *background = [UIColor darkBlueColor];//[[UIColor alloc] initWithPatternImage:snapshotImage];
                                 self.menuView.backgroundColor = background;
                                 
                                 //pause Scene
                                 SKView * view= (SKView*)_skView;
                                 view.paused=YES;
                                 //[[AVAudioSession sharedInstance] setActive:NO error:nil];
                                 
                                 
                                 self.menuView.frame = CGRectMake(0, 0, 100, self.menuView.frame.size.height);
                                 self.menuBackButton.frame = CGRectMake(20,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                                 self.menuContinueButton.frame = CGRectMake(20,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                                 self.menuScreenshotButton.frame = CGRectMake(20,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                                 self.menuRestartButton.frame = CGRectMake(20,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                                 self.menuAxisButton.frame = CGRectMake(20,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                                 self.menuBtn.hidden=YES;
                             }
                             completion:^(BOOL finished) {
                                 menuOpen = YES;
                             }];
        }
        else if (translate.x < 0.0  && menuOpen == YES)
        {
            // moving left
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.menuView.frame = CGRectMake(0, 0, 0, self.menuView.frame.size.height);
                                 self.menuBackButton.frame = CGRectMake(-44,self.menuBackButton.frame.origin.y, self.menuBackButton.frame.size.width, self.menuBackButton.frame.size.height);
                                 self.menuContinueButton.frame = CGRectMake(-44,self.menuContinueButton.frame.origin.y, self.menuContinueButton.frame.size.width, self.menuContinueButton.frame.size.height);
                                 self.menuScreenshotButton.frame = CGRectMake(-44,self.menuScreenshotButton.frame.origin.y, self.menuScreenshotButton.frame.size.width, self.menuScreenshotButton.frame.size.height);
                                 self.menuRestartButton.frame = CGRectMake(-44,self.menuRestartButton.frame.origin.y, self.menuRestartButton.frame.size.width, self.menuRestartButton.frame.size.height);
                                 self.menuAxisButton.frame = CGRectMake(-44,self.menuAxisButton.frame.origin.y, self.menuAxisButton.frame.size.width, self.menuAxisButton.frame.size.height);
                                 self.menuBtn.hidden=NO;
                             }
                             completion:^(BOOL finished) {
                                 SKView * view= (SKView*)_skView;
                                 view.paused=NO;
                                 menuOpen= NO;
                             }];
        }

    }
}



@end

