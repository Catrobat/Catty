/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "ProgramDefines.h"
#import "Program+CustomExtensions.h"
#import "Util.h"
#import "Script.h"
#import "SpriteObject.h"
#import "SpriteManagerDelegate.h"
#import "Brick.h"
#import "AudioManager.h"
#import "ProgramVariablesManager.h"
#import "SensorHandler.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Accelerate/Accelerate.h>
#import "UIColor+CatrobatUIColorExtensions.h"
#import "Util.h"
#import "SaveToProjectActivity.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "LoadingView.h"
#import "UIDefines.h"
#import "FlashHelper.h"
#import "CatrobatLanguageDefines.h"
#import "BaseTableViewController.h"
#import "Pocket_Code-Swift.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "CatrobatAlertController.h"
#import "ActionSheetAlertViewTags.h"
#import "RuntimeImageCache.h"

@interface ScenePresenterViewController() <UIActionSheetDelegate, CatrobatAlertViewDelegate, CBScreenRecordingDelegate>
@property (nonatomic) BOOL menuOpen;
@property (nonatomic) CGPoint firstGestureTouchPoint;
@property (nonatomic) UIImage *snapshotImage;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) SKView *skView;
@property (nonatomic) BOOL restartProgram;
@property (nonatomic, strong) CBScene *scene;
@end

@implementation ScenePresenterViewController

#pragma mark - View Event Handling
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restartProgram = NO;
    [[[self class] sharedLoadingView] removeFromSuperview];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    self.skView.backgroundColor = UIColor.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScene];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    UIApplication.sharedApplication.statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;
    // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.menuOpen = NO;
    [self.view addSubview:self.skView];
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SceneMenuView" owner:self options:nil];
    self.menuView = [subviewArray objectAtIndex:0];
    self.menuView.frame = CGRectMake(self.menuView.frame.origin.x, self.menuView.frame.origin.y, self.menuView.frame.size.width, [Util screenHeight]);
    [self.view insertSubview:self.menuView aboveSubview:self.skView];
    [self setUpMenuButtons];
    [self setUpLabels];
    [self setUpGridView];
    [self checkAspectRatio];
    [[BluetoothService sharedInstance] setScenePresenter:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self continueProgramAction:nil withDuration:kfirstSwipeDuration];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView removeFromSuperview];
    self.navigationController.navigationBar.hidden = self.restartProgram;
    self.navigationController.toolbarHidden = self.restartProgram;
    UIApplication.sharedApplication.statusBarHidden = NO;
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    [[FlashHelper sharedFlashHandler] turnOff]; // always turn off flash light when Scene is stopped

    // reenable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.skView.bounds = self.view.bounds;
}

#pragma mark - Initialization & Setup & Dealloc
#pragma mark Dealloc
- (void)dealloc
{
    [self freeRessources];
}

- (void)freeRessources
{
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[SensorHandler sharedSensorHandler] stopSensors];
    [[ProgramVariablesManager sharedProgramVariablesManager] setVariables:nil];

    // Delete sound rec for loudness sensor
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *soundfile = [documentsPath stringByAppendingPathComponent:@"loudness_handler.m4a"];
    if ([fileMgr removeItemAtPath:soundfile error:&error] != YES)
        NSDebug(@"No Sound file available or unable to delete file: %@", [error localizedDescription]);
}

#pragma mark View Setup
- (void)setUpLabels
{

    NSArray *labelTextArray = [[NSArray alloc] initWithObjects:kLocalizedBack,
                               kLocalizedRestart,
                               kLocalizedContinue,
                               kLocalizedScreenshot,
                               kLocalizedAxes,
                               kLocalizedRecord, nil];
    NSArray* labelArray = [[NSArray alloc] initWithObjects:self.menuBackLabel,self.menuRestartLabel,self.menuContinueLabel, self.menuScreenshotLabel, self.menuAxisLabel,self.menuRecordLabel, nil];
    for (int i = 0; i < [labelTextArray count]; ++i) {
        [self setupLabel:labelTextArray[i]
                 andView:labelArray[i]];
    }
    [self.menuBackLabel addTarget:self action:@selector(stopProgramAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContinueLabel addTarget:self action:@selector(continueProgramAction:withDuration:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuScreenshotLabel addTarget:self action:@selector(takeScreenshotAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuRestartLabel addTarget:self action:@selector(restartProgramAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuAxisLabel addTarget:self action:@selector(showHideAxisAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuRecordLabel addTarget:self action:@selector(recordProgram:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupLabel:(NSString*)name andView:(UIButton*)label
{
    [label setTitle:name forState:UIControlStateNormal];
    label.tintColor = [UIColor navTintColor];
    label.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:(14.0)];
    label.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setUpMenuButtons
{
    [self setupButtonWithButton:self.menuBackButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_back"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_back_pressed"]
                    andSelector:@selector(stopProgramAction:)];
    [self setupButtonWithButton:self.menuContinueButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_continue"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"]
                    andSelector:@selector(continueProgramAction:withDuration:)];
    [self setupButtonWithButton:self.menuScreenshotButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_screenshot"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"]
                    andSelector:@selector(takeScreenshotAction:)];
    [self setupButtonWithButton:self.menuRestartButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_restart"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"]
                    andSelector:@selector(restartProgramAction:)];
    [self setupButtonWithButton:self.menuAxisButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_toggle_axis"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"]
                    andSelector:@selector(showHideAxisAction:)];
    [self setupButtonWithButton:self.menuAspectRatioButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio_pressed"]
                    andSelector:@selector(manageAspectRatioAction:)];
    [self setupButtonWithButton:self.menuRecordButton
                ImageNameNormal:[UIImage imageNamed:@"record"]
        andImageNameHighlighted:[UIImage imageNamed:@"record"]
                    andSelector:@selector(recordProgram:)];
    self.menuRecordButton.hidden = (! self.scene.isScreenRecorderAvailable);
    self.menuRecordLabel.hidden = (! self.scene.isScreenRecorderAvailable);
}

- (void)setupButtonWithButton:(UIButton*)button ImageNameNormal:(UIImage*)stateNormal
      andImageNameHighlighted:(UIImage*)stateHighlighted andSelector:(SEL)myAction
{
    [button setBackgroundImage:stateNormal forState:UIControlStateNormal];
    [button setBackgroundImage:stateHighlighted forState:UIControlStateHighlighted];
    [button setBackgroundImage:stateHighlighted forState:UIControlStateSelected];
    [button addTarget:self action:myAction forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUpGridView
{
    self.gridView.backgroundColor = [UIColor clearColor];
    UIView *xArrow = [[UIView alloc] initWithFrame:CGRectMake(0,[Util screenHeight]/2,[Util screenWidth],1)];
    xArrow.backgroundColor = [UIColor redColor];
    [self.gridView addSubview:xArrow];
    UIView *yArrow = [[UIView alloc] initWithFrame:CGRectMake([Util screenWidth]/2,0,1,[Util screenHeight])];
    yArrow.backgroundColor = [UIColor redColor];
    [self.gridView addSubview:yArrow];
    // nullLabel
    UILabel *nullLabel = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight]/2 + 5, 10, 15)];
    nullLabel.text = @"0";
    nullLabel.textColor = [UIColor redColor];
    [self.gridView addSubview:nullLabel];
    // positveWidth
    UILabel *positiveWidth = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]- 40, [Util screenHeight]/2 + 5, 30, 15)];
    positiveWidth.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenWidth.floatValue/2];
    positiveWidth.textColor = [UIColor redColor];
    [positiveWidth sizeToFit];
    positiveWidth.frame = CGRectMake([Util screenWidth] - positiveWidth.frame.size.width - 5, [Util screenHeight]/2 + 5, positiveWidth.frame.size.width, positiveWidth.frame.size.height);
    [self.gridView addSubview:positiveWidth];
    // negativeWidth
    UILabel *negativeWidth = [[UILabel alloc] initWithFrame:CGRectMake(5, [Util screenHeight]/2 + 5, 40, 15)];
    negativeWidth.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenWidth.floatValue/2];
    negativeWidth.textColor = [UIColor redColor];
    [negativeWidth sizeToFit];
    [self.gridView addSubview:negativeWidth];
    // positveHeight
    UILabel *positiveHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight] - 20, 40, 15)];
    positiveHeight.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenHeight.floatValue/2];
    positiveHeight.textColor = [UIColor redColor];
    [positiveHeight sizeToFit];
    [self.gridView addSubview:positiveHeight];
    // negativeHeight
    UILabel *negativeHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5,5, 40, 15)];
    negativeHeight.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenHeight.floatValue/2];
    negativeHeight.textColor = [UIColor redColor];
    [negativeHeight sizeToFit];
    [self.gridView addSubview:negativeHeight];
    
    [self.view insertSubview:self.gridView aboveSubview:self.skView];
}

- (void)checkAspectRatio
{
    if (self.program.header.screenWidth.floatValue == [Util screenWidth] && self.program.header.screenHeight.floatValue == [Util screenHeight]) {
        self.menuAspectRatioButton.hidden = YES;
    }
}

- (void)setupScene
{
    if (! self.scene) {
        [[ProgramVariablesManager sharedProgramVariablesManager] setVariables:self.program.variables];
        
        CBScene *scene = [SetupScene setupSceneForProgram:self.program];
        [scene initializeScreenRecording];
        scene.name = self.program.header.programName;
        scene.screenRecordingDelegate = self;
        if ([self.program.header.screenMode isEqualToString: kCatrobatHeaderScreenModeMaximize]) {
            scene.scaleMode = SKSceneScaleModeFill;
        } else if ([self.program.header.screenMode isEqualToString: kCatrobatHeaderScreenModeStretch]){
            scene.scaleMode = SKSceneScaleModeAspectFit;
        } else {
            scene.scaleMode = SKSceneScaleModeFill;
        }
        self.skView.paused = NO;
        [self.skView presentScene:scene];
        self.scene = scene;
    }
}

-(void)resaveLooks
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        for (SpriteObject *object in self.program.objectList) {
            for (Look *look in object.lookList) {
                [[RuntimeImageCache sharedImageCache] loadImageFromDiskWithPath:look.fileName];
            }
        }
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

# pragma mark - Touch Event Handling

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.menuOpen) {
        NSDebug(@"touch on scene not allowed, because menu is open");
        return;
    }
    NSDebug(@"touch on scene allowed");
    for (UITouch *touch in touches) {
        NSDebug(@"StartTouchinScenePresenter");
        [self.scene touchedWithTouch:touch];
    }
}


#pragma mark - Game Event Handling
- (void)pauseAction
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AudioManager sharedAudioManager] pauseAllSounds];
    [[FlashHelper sharedFlashHandler] pause];
    [[BluetoothService sharedInstance] pauseBluetoothDevice];
    [self.scene pauseScheduler];
}

- (void)resumeAction
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AudioManager sharedAudioManager] resumeAllSounds];
    [[BluetoothService sharedInstance] continueBluetoothDevice];
    if ([FlashHelper sharedFlashHandler].wasTurnedOn == FlashON) {
        [[FlashHelper sharedFlashHandler] resume];
    }
    [self.scene resumeScheduler];
}

- (void)continueProgramAction:(UIButton*)sender withDuration:(CGFloat)duration
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if ([FlashHelper sharedFlashHandler].wasTurnedOn == FlashON) {
        [[FlashHelper sharedFlashHandler] resume];
    }
    [self.scene resumeScheduler];
    [[BluetoothService sharedInstance] continueBluetoothDevice];
    CGFloat animateDuration = 0.0f;
    animateDuration = (duration > 0.0001f && duration < 1.0f)? duration : 0.35f;
    
    [UIView animateWithDuration:animateDuration
                          delay:0.0f
                        options: UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{[self continueAnimation];}
                     completion:^(BOOL finished){
                         self.menuOpen = NO;
                         if (animateDuration == duration) {
                             [self takeAutomaticScreenshot];
                         }
                         
                     }];
    self.skView.paused = NO;
    
    if (duration != kDontResumeSounds) {
        [[AudioManager sharedAudioManager] resumeAllSounds];
    }
}

- (void)stopProgramAction:(UIButton*)sender
{
    CBScene *previousScene = self.scene;
    if (previousScene.isScreenRecording) {
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateHighlighted];
        [self.menuView setNeedsDisplay];
        [previousScene stopScreenRecording];
        return;
    }
    [self.loadingView show];
    self.menuView.userInteractionEnabled = NO;
    previousScene.userInteractionEnabled = NO;
    [previousScene stopProgram];
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[FlashHelper sharedFlashHandler] reset];
    previousScene.userInteractionEnabled = YES;
    [self.loadingView hide];
    [self.parentViewController.navigationController setToolbarHidden:NO];
    [self.parentViewController.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [[BluetoothService sharedInstance] setScenePresenter:nil];
    [[BluetoothService sharedInstance] resetBluetoothDevice];
}

-(void)connectionLost
{
    [self.loadingView show];
    self.menuView.userInteractionEnabled = NO;
    CBScene *previousScene = self.scene;
    previousScene.userInteractionEnabled = NO;
    [previousScene stopProgram];
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[FlashHelper sharedFlashHandler] reset];
    previousScene.userInteractionEnabled = YES;
    [self.loadingView hide];
    [Util alertWithText:@"Lost Bluetooth Connection" delegate:self tag:kLostBluetoothConnectionTag];
}

- (void)restartProgramAction:(UIButton*)sender
{
    [self.loadingView show];
    self.menuView.userInteractionEnabled = NO;
    CBScene *previousScene = self.scene;
    previousScene.userInteractionEnabled = NO;
    [previousScene stopProgram];
    [[FlashHelper sharedFlashHandler] reset];

    [self freeRessources];
    NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
    [controllers removeLastObject];
    UIViewController *previousVC = (UIViewController*)controllers.lastObject; // previous object
    if ([previousVC respondsToSelector:@selector(playSceneAction:animated:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [((BaseTableViewController*)previousVC) playSceneAction:sender animated:NO];
        });
    } else {
        assert("PLEASE IMPLEMENT playSceneAction:animated method IN UIVIEWCONTROLLER THAT SEGUED TO SCENEPRESENTERVIEWCONTROLLER!!");
    }
    self.menuView.userInteractionEnabled = YES;
    previousScene.userInteractionEnabled = YES;
    [self.loadingView hide];

    UIView *loadingView = [[self class] sharedLoadingView];
    [self.parentViewController.view addSubview:loadingView];
    [self.parentViewController.view bringSubviewToFront:loadingView];
    self.restartProgram = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

+ (UIView*)sharedLoadingView
{
    static UIView *loadingView = nil;
    if (loadingView == nil) {
        loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UILabel *label = [[UILabel alloc] initWithFrame:loadingView.frame];
        label.font = [UIFont systemFontOfSize:36];
        label.text = [NSString stringWithFormat:@"%@...", kLocalizedLoading];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [loadingView addSubview:label];
        loadingView.backgroundColor = [UIColor backgroundColor];
        loadingView.alpha = 1.0;
    }
    return loadingView;
}

#pragma mark User Event Handling
- (void)backButtonAction:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHideAxisAction:(UIButton*)sender
{
    if (self.gridView.hidden == NO) {
        self.gridView.hidden = YES;
    } else {
        self.gridView.hidden = NO;
    }
}

- (void)recordProgram:(UIButton*)sender
{
    if (! self.scene.isScreenRecorderAvailable) {
        return;
    }

    if (self.scene.isScreenRecording) {
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateHighlighted];
        [self.scene stopScreenRecording];
        [self setupLabel:kLocalizedRecord
                 andView:self.menuRecordLabel];
        [self.menuView setNeedsDisplay];
    }
    else {
        [self.scene startScreenRecording];
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.menuRecordButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateHighlighted];
        [self setupLabel:kLocalizedStop
                 andView:self.menuRecordLabel];
        [self.menuView setNeedsDisplay];
        [self continueProgramAction:nil withDuration:0];
    }
}

- (void)manageAspectRatioAction:(UIButton *)sender
{
    self.scene.scaleMode = self.scene.scaleMode == SKSceneScaleModeAspectFit ? SKSceneScaleModeFill : SKSceneScaleModeAspectFit;
    self.program.header.screenMode = [self.program.header.screenMode isEqualToString:kCatrobatHeaderScreenModeStretch] ? kCatrobatHeaderScreenModeMaximize :kCatrobatHeaderScreenModeStretch;
    [self.skView setNeedsLayout];
    self.menuOpen = YES;
    // pause Scene
    SKView *view = self.skView;
    view.paused = YES;
    [[AudioManager sharedAudioManager] pauseAllSounds];
}

- (void)takeScreenshotAction:(UIButton*)sender
{
    // Screenshot function
    UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:NO];
    self.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self showSaveScreenshotActionSheet];
    
}

-(void)takeAutomaticScreenshot
{
    NSArray *fallbackPaths = @[[[NSString alloc] initWithFormat:@"%@/small_screenshot.png", [self.program projectPath]],
                               [[NSString alloc] initWithFormat:@"%@/screenshot.png",[self.program projectPath]],
                               [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", [self.program projectPath]],
                               [[NSString alloc] initWithFormat:@"%@/automatic_screenshot.png", [self.program projectPath]]];
    BOOL fileExists = NO;
    for (NSString *fallbackPath in fallbackPaths) {
        NSString *fileName = [fallbackPath lastPathComponent];
        fileExists= [[NSFileManager defaultManager] fileExistsAtPath:fileName];
        if(fileExists){
            break;
        }
    }
    if (!fileExists) {
        NSLog(@"AutoScreenshot");
        UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
        [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:NO];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/automatic_screenshot.png",[self.program projectPath]];
            NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
            [data writeToFile:pngFilePath atomically:YES];
            
            ///Save small Screenshot too??
            NSString *pngFilePathSmall = [NSString stringWithFormat:@"%@/small_screenshot.png",[self.program projectPath]];
            UIGraphicsBeginImageContext( CGSizeMake(160, 160) );
            [image drawInRect:CGRectMake(0,0,160,160)];
            UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *dataSmall = [NSData dataWithData:UIImagePNGRepresentation(newImage)];
            [dataSmall writeToFile:pngFilePathSmall atomically:YES];
        });

    }
    
}

#pragma mark - Action Sheet & Alert View Handling
- (void)showSaveScreenshotActionSheet
{
    UIImage *imageToShare = self.snapshotImage;
    NSString *path = [self.program projectPath];
    NSArray *itemsToShare = @[imageToShare];

    SaveToProjectActivity *saveToProjectActivity = [[SaveToProjectActivity alloc] initWithImagePath:path];
    NSArray *activities = @[saveToProjectActivity];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:activities];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToFacebook,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypeMail]; //or whichever you don't need
    __weak ScenePresenterViewController *weakself = self;
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        SKView *view = weakself.skView;
        view.paused=YES;
    }];
    [self presentViewController:activityVC animated:YES completion:^(){
        SKView *view = weakself.skView;
        view.paused=YES;
    }];
}


#pragma mark - Pan Gesture Handler
- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    self.menuRecordButton.hidden = (! self.scene.isScreenRecorderAvailable);
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0;
    CGFloat velocityX = [gesture velocityInView:gesture.view].x;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.firstGestureTouchPoint = [gesture locationInView:gesture.view];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (translate.x > 0.0 && translate.x < kWidthSlideMenu && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handlePositvePan:translate];}
                             completion:nil];
        } else if (translate.x < 0.0 && translate.x > -kWidthSlideMenu && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleNegativePan:translate];}
                             completion:nil];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed) {
        if (translate.x > (kWidthSlideMenu/4) && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledPositive:translate];}
                             completion:^(BOOL finished) {
                                 self.menuOpen = YES;
                                 // pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 [self pauseAction];
                                 if (translate.x < (kWidthSlideMenu) && velocityX > 300) {
//                                     [self bounceAnimation];
                                 }
                                 
                             }];
        } else if(translate.x > 0.0 && translate.x <(kWidthSlideMenu/4) && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledNegative:translate];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused = NO;
                                 self.menuOpen = NO;
                                 [self resumeAction];
                             }];
        } else if (translate.x < (-kWidthSlideMenu/4)  && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledNegative:translate];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused = NO;
                                 self.menuOpen = NO;
                                 [self resumeAction];
                             }];
        } else if (translate.x > (-kWidthSlideMenu/4) && translate.x < 0.0   && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledPositive:translate];}
                             completion:^(BOOL finished) {
                                 self.menuOpen = YES;
                                 // pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 [self pauseAction];
                                 if (translate.x > -(kWidthSlideMenu) && velocityX < -100) {
//                                     [self bounceAnimation];
                                 }
//                                 [self.scene stopScreenRecording];
                             }];
        }
    }
}


- (void)handlePositvePan:(CGPoint)translate
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuView.frame = CGRectMake(-kWidthSlideMenu+translate.x-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=YES;
}

- (void)handleNegativePan:(CGPoint)translate
{
    self.menuView.frame = CGRectMake(translate.x-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=NO;
}

- (void)handleCancelledPositive:(CGPoint)translate
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuView.frame = CGRectMake(-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=YES;
}

- (void)handleCancelledNegative:(CGPoint)translate
{
    self.menuView.frame = CGRectMake(-kWidthSlideMenu-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=NO;
}

#pragma mark - Animation Handling
- (void)bounceAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [animation setFromValue:[NSNumber numberWithFloat:kWidthSlideMenu/2]];
    [animation setToValue:[NSNumber numberWithFloat:(kWidthSlideMenu/2)+(kBounceEffect/2)]];
    [animation setDuration:.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5f :1.8f :1 :1]];
    [self.menuView.layer addAnimation:animation forKey:@"somekey"];
}

- (void)revealAnimation
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuView.frame = CGRectMake(-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=YES;
}

- (void)continueAnimation
{
    self.menuView.frame = CGRectMake(-kWidthSlideMenu-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
}

#pragma mark - Getters & Setters
- (UIView*)gridView
{
    // lazy instantiation
    if (! _gridView) {
        _gridView = [[UIView alloc]initWithFrame:self.view.bounds];
        _gridView.hidden = YES;
    }
    return _gridView;
}

- (LoadingView*)loadingView
{
    // lazy instantiation
    if (! _loadingView) {
        _loadingView = [LoadingView new];
        [self.view addSubview:_loadingView];
        [self.view bringSubviewToFront:_loadingView];
        _loadingView.backgroundColor = [UIColor whiteColor];
        _loadingView.alpha = 1.0;
    }
    return _loadingView;
}

- (SKView*)skView
{
    if (!_skView) {
        _skView = [[SKView alloc] initWithFrame:self.view.bounds];
#if DEBUG == 1
        _skView.showsFPS = YES;
        _skView.showsNodeCount = YES;
        _skView.showsDrawCount = YES;
#endif
    }
    _skView.paused = NO;
    return _skView;
}

#pragma mark - Helpers
- (UIImage*)brightnessBackground:(UIImage*)startImage {
    CGImageRef image = startImage.CGImage;
    CIImage *ciImage =[ CIImage imageWithCGImage:image];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                  keysAndValues:kCIInputImageKey, ciImage, @"inputBrightness",
                        @(-0.5), nil];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *output = [UIImage imageWithCGImage:cgimg];
    CFRelease(cgimg);
    return output;
}

- (void)alertView:(CatrobatAlertController*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kLostBluetoothConnectionTag) {
        [self.parentViewController.navigationController setToolbarHidden:NO];
        [self.parentViewController.navigationController setNavigationBarHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - CBScreenRecordingDelegate
- (void)showMenuRecordButton {
    self.menuRecordButton.hidden = NO;
}

- (void)hideMenuRecordButton {
    self.menuRecordButton.hidden = YES;
}

@end
