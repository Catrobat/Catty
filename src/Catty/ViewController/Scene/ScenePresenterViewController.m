/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "ProgramDefines.h"
#import "Program+CustomExtensions.h"
#import "Util.h"
#import "Script.h"
#import "SpriteObject.h"
#import "SpriteManagerDelegate.h"
#import "Brick.h"
#import "BroadcastWaitHandler.h"
#import "AudioManager.h"
#import "ProgramManager.h"
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

#define kWidthSlideMenu 150
#define kBounceEffect 5
#define kPlaceOfButtons 17
#define kSlidingStartArea 40
#define kIphone4ScreenHeight 480.0f
#define kContinueButtonSize 85
#define kContinueOffset 15
#define kMenuButtonSize 44
#define kMenuIPhone4GapSize 30
#define KMenuIPhone5GapSize 35
#define kMenuIPhone4ContinueGapSize 40
#define kMenuIPhone5ContinueGapSize 45
#define kMenuLabelWidth 50
#define kMenuLabelHeight 20
#define kPlaceofLabels (kPlaceOfButtons-29)
#define kPlaceofContinueLabel (kPlaceOfButtons)
#define kDontResumeSounds 4
#define kfirstSwipeDuration 0.8f

@interface ScenePresenterViewController ()<UIActionSheetDelegate>

@property (nonatomic) BOOL menuOpen;
@property (nonatomic, strong) BroadcastWaitHandler *broadcastWaitHandler;
@property (nonatomic) CGPoint firstGestureTouchPoint;
@property (nonatomic) UIImage *snapshotImage;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) Program *program;
@property (nonatomic, strong) SKView *skView;
@property (nonatomic) dispatch_queue_t restartProgramQueue;

@end

@implementation ScenePresenterViewController

- (id)initWithProgram:(Program *)program
{
    if (self = [super init]) {
        for (SpriteObject *sprite in program.objectList) {
            //        sprite.spriteManagerDelegate = self;
            sprite.broadcastWaitDelegate = self.broadcastWaitHandler;

            // NOTE: if there are still some runNextAction tasks in a queue
            // then these actions must not be executed because the Scene is not available any more.
            // This problem caused the app to crash sometimes in the past.
            // Now these lines fix this issue.
            for (Script *script in sprite.scriptList) {
                script.allowRunNextAction = YES;
            }
        }
        _program = program;
    }
    return self;
}

#pragma mark - ViewController Delegates
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];

    /// MenuImageBackground
    UIImage *menuBackgroundImage = [UIImage imageNamed:@"stage_dialog_background_middle_1"];
    UIImage *newBackgroundImage;

    if ([Util screenHeight] == kIphone4ScreenHeight) {
        CGSize size = CGSizeMake(kWidthSlideMenu+kBounceEffect, kIphone4ScreenHeight);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [menuBackgroundImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        CGSize size = CGSizeMake(kWidthSlideMenu+kBounceEffect, [Util screenHeight]);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [menuBackgroundImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    self.skView.backgroundColor = UIColor.backgroundColor;
    self.menuView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kWidthSlideMenu + kBounceEffect, CGRectGetHeight(UIScreen.mainScreen.bounds))];
    self.menuView.backgroundColor = [[UIColor alloc] initWithPatternImage:newBackgroundImage];

    // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureScene];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    UIApplication.sharedApplication.statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.menuOpen = NO;
    [self.view addSubview:self.skView];
    [self.view insertSubview:self.menuView aboveSubview:self.skView];
    [self setUpMenuButtons];
    [self setUpMenuFrames];
    [self setUpLabels];
    [self setUpGridView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self continueProgram:nil withDuration:kfirstSwipeDuration];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setToolbarHidden:NO animated:NO];
    UIApplication.sharedApplication.statusBarHidden = NO;
    UIApplication.sharedApplication.idleTimerDisabled = NO;

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

#pragma mark getters and setters
- (dispatch_queue_t)restartProgramQueue
{
    // lazy instantiation
    if (! _restartProgramQueue) {
        _restartProgramQueue = dispatch_queue_create("org.catrobat.restartProgram", 0);
    }
    return _restartProgramQueue;
}

- (BroadcastWaitHandler*)broadcastWaitHandler
{
    // lazy instantiation
    if (! _broadcastWaitHandler) {
        _broadcastWaitHandler = [[BroadcastWaitHandler alloc] init];
    }
    return _broadcastWaitHandler;
}

- (UIView*)gridView
{
    // lazy instantiation
    if (! _gridView) {
        _gridView = [[UIView alloc]initWithFrame:self.view.bounds];
        _gridView.hidden = YES;
    }
    return _gridView;
}

- (SKView*)skView
{
    if (!_skView) {
        _skView = [[SKView alloc] initWithFrame:self.view.bounds];
#ifdef DEBUG
        _skView.showsFPS = YES;
        _skView.showsNodeCount = YES;
        _skView.showsDrawCount = YES;
#endif
    }
    _skView.paused = NO;
    return _skView;
}

- (UIImage*)brightnessBackground:(UIImage*)startImage
{
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

- (void)setUpLabels
{
    if ([Util screenHeight]==kIphone4ScreenHeight) {
        UILabel* label     =[[UILabel alloc] initWithFrame:
                             CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)-(kContinueButtonSize/2)-(kMenuIPhone4GapSize)-kMenuIPhone4ContinueGapSize-(kMenuButtonSize)-10, 100, kMenuButtonSize)];
        self.menuBackLabel = label;
        label              =[[UILabel alloc] initWithFrame:
                             CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)-(kContinueButtonSize/2)-kMenuIPhone4ContinueGapSize-10,100, kMenuButtonSize)];
        self.menuRestartLabel = label;
        label     = [[UILabel alloc] initWithFrame:
                     CGRectMake(kPlaceofContinueLabel+kContinueOffset,(kIphone4ScreenHeight/2)+(kContinueButtonSize/2)-10,  kContinueButtonSize, kMenuButtonSize)];
        self.menuContinueLabel = label;
        label    = [[UILabel alloc] initWithFrame:
                    CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)+(kContinueButtonSize/2)+kMenuIPhone4ContinueGapSize+kMenuButtonSize-10,  100, kMenuButtonSize)];
        self.menuScreenshotLabel = label;
        label         = [[UILabel alloc] initWithFrame:
                         CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)+(kContinueButtonSize/2)+(kMenuIPhone4GapSize)+kMenuIPhone4ContinueGapSize+(2*kMenuButtonSize)-10,  100, kMenuButtonSize)];
        self.menuAxisLabel  = label;
    } else {
            UILabel* label      = [[UILabel alloc] initWithFrame:
                                   CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)-(kContinueButtonSize/2)-(KMenuIPhone5GapSize)-kMenuIPhone5ContinueGapSize-(kMenuButtonSize)-10, 100, kMenuButtonSize)];
            self.menuBackLabel  = label;
            label               =[[UILabel alloc] initWithFrame:
                                  CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)-(kContinueButtonSize/2)-kMenuIPhone5ContinueGapSize-10,100, kMenuButtonSize)];
            self.menuRestartLabel = label;
            label               = [[UILabel alloc] initWithFrame:
                                   CGRectMake(kPlaceofContinueLabel+kContinueOffset,([Util screenHeight]/2)+(kContinueButtonSize/2)-10,  kContinueButtonSize, kMenuButtonSize)];
            self.menuContinueLabel = label;
            label               = [[UILabel alloc] initWithFrame:
                                   CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)+(kContinueButtonSize/2)+kMenuIPhone5ContinueGapSize+kMenuButtonSize-10,  100, kMenuButtonSize)];
            self.menuScreenshotLabel = label;
            label               = [[UILabel alloc] initWithFrame:
                                   CGRectMake(kPlaceofLabels+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)+                    (kContinueButtonSize/2)+(KMenuIPhone5GapSize)+kMenuIPhone5ContinueGapSize+(2*kMenuButtonSize)-10,  100, kMenuButtonSize)];
            self.menuAxisLabel  = label;
    }
    NSArray* labelTextArray = [[NSArray alloc] initWithObjects:
                               kLocalizedBack,
                               kLocalizedRestart,
                               kLocalizedContinue,
                               kLocalizedScreenshot,
                               kLocalizedGrid, nil];
    NSArray* labelArray = [[NSArray alloc] initWithObjects:self.menuBackLabel,self.menuRestartLabel,self.menuContinueLabel, self.menuScreenshotLabel, self.menuAxisLabel,nil];
    for (int i = 0; i < [labelTextArray count]; ++i) {
        [self setupLabel:labelTextArray[i]
                 andView:labelArray[i]];
    }
}

- (void)setupLabel:(NSString*)name andView:(UILabel*)label
{
    label.text = name;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont fontWithName:@"Helvetica Neue" size:(14.0)];
    label.textAlignment = NSTextAlignmentCenter;
    [self.menuView addSubview:label];
    [self.menuView bringSubviewToFront:label];
}

- (void)setUpMenuButtons
{
    self.menuBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuContinueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuScreenshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuRestartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuAxisButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuAspectRatioButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [self setupButtonWithButton:self.menuBackButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_back"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_back_pressed"]
                    andSelector:@selector(stopProgram:)
     ];

    [self setupButtonWithButton:self.menuContinueButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_continue"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_continue_pressed"]
                    andSelector:@selector(continueProgram:withDuration:)
     ];

    [self setupButtonWithButton:self.menuScreenshotButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_screenshot"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_screenshot_pressed"]
                    andSelector:@selector(takeScreenshot:)
     ];

    [self setupButtonWithButton:self.menuRestartButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_restart"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_restart_pressed"]
                    andSelector:@selector(restartProgram:)
     ];

    [self setupButtonWithButton:self.menuAxisButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_toggle_axis"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_toggle_axis_pressed"]
                    andSelector:@selector(showHideAxis:)
     ];

    [self setupButtonWithButton:self.menuAspectRatioButton
                ImageNameNormal:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio"]
        andImageNameHighlighted:[UIImage imageNamed:@"stage_dialog_button_aspect_ratio_pressed"]
                    andSelector:@selector(manageAspectRatio:)
     ];
}

- (void)setupButtonWithButton:(UIButton*)button ImageNameNormal:(UIImage*)stateNormal andImageNameHighlighted:(UIImage*)stateHighlighted andSelector:(SEL)myAction
{
    [button setBackgroundImage:stateNormal
                      forState:UIControlStateNormal];
    [button setBackgroundImage:stateHighlighted
                      forState:UIControlStateHighlighted];
    [button setBackgroundImage:stateHighlighted
                      forState:UIControlStateSelected];
    [button  addTarget:self
                action:myAction
      forControlEvents:UIControlEventTouchUpInside];

    [self.menuView addSubview:button];
}

- (void)setUpMenuFrames
{
    self.menuAspectRatioButton.frame = CGRectMake(10,10, kMenuButtonSize-20, kMenuButtonSize-20);
    ///StartPosition
    if ([Util screenHeight]==kIphone4ScreenHeight) {
        self.menuBackButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)-(kContinueButtonSize/2)-(kMenuIPhone4GapSize)-(2*kMenuButtonSize)-kMenuIPhone4ContinueGapSize, kMenuButtonSize, kMenuButtonSize);
        
        self.menuRestartButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)-(kContinueButtonSize/2)-kMenuIPhone4ContinueGapSize-(kMenuButtonSize),  kMenuButtonSize, kMenuButtonSize);
        self.menuContinueButton.frame = CGRectMake(kPlaceOfButtons+kContinueOffset,(kIphone4ScreenHeight/2)-(kContinueButtonSize/2),  kContinueButtonSize, kContinueButtonSize);
        self.menuScreenshotButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)+(kContinueButtonSize/2)+kMenuIPhone4ContinueGapSize,  kMenuButtonSize, kMenuButtonSize);
        self.menuAxisButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),(kIphone4ScreenHeight/2)+(kContinueButtonSize/2)+(kMenuIPhone4GapSize)+kMenuIPhone4ContinueGapSize+(kMenuButtonSize),  kMenuButtonSize, kMenuButtonSize);
    } else {
        self.menuBackButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)-(kContinueButtonSize/2)-(KMenuIPhone5GapSize)-kMenuIPhone5ContinueGapSize-(2*kMenuButtonSize), kMenuButtonSize, kMenuButtonSize);
        self.menuRestartButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)-(kContinueButtonSize/2)-kMenuIPhone5ContinueGapSize-(kMenuButtonSize),  kMenuButtonSize, kMenuButtonSize);
        self.menuContinueButton.frame = CGRectMake(kPlaceOfButtons+kContinueOffset,([Util screenHeight]/2)-(kContinueButtonSize/2),  kContinueButtonSize, kContinueButtonSize);
        self.menuScreenshotButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)+(kContinueButtonSize/2)+kMenuIPhone5ContinueGapSize,  kMenuButtonSize, kMenuButtonSize);
        self.menuAxisButton.frame = CGRectMake(kPlaceOfButtons+((kContinueButtonSize-kMenuButtonSize)/2),([Util screenHeight]/2)+(kContinueButtonSize/2)+(KMenuIPhone5GapSize)+kMenuIPhone5ContinueGapSize+(kMenuButtonSize),  kMenuButtonSize, kMenuButtonSize);
    }
    //NSDebug(@"Width: %f",self.menuView.frame.size.width);
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
    //nullLabel
    UILabel *nullLabel = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight]/2 + 5, 10, 15)];
    nullLabel.text = @"0";
    nullLabel.textColor = [UIColor redColor];
    [self.gridView addSubview:nullLabel];
    //positveWidth
    UILabel *positiveWidth = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]- 40, [Util screenHeight]/2 + 5, 30, 15)];
    positiveWidth.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenWidth.floatValue/2];
    positiveWidth.textColor = [UIColor redColor];
    [self.gridView addSubview:positiveWidth];
    //negativWidth
    UILabel *negativeWidth = [[UILabel alloc] initWithFrame:CGRectMake(5, [Util screenHeight]/2 + 5, 40, 15)];
    negativeWidth.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenWidth.floatValue/2];
    negativeWidth.textColor = [UIColor redColor];
    [self.gridView addSubview:negativeWidth];
    //positveHeight
    UILabel *positiveHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight] - 20, 40, 15)];
    positiveHeight.text = [NSString stringWithFormat:@"-%d",(int)self.program.header.screenHeight.floatValue/2];
    positiveHeight.textColor = [UIColor redColor];
    [self.gridView addSubview:positiveHeight];
    //negativHeight
    UILabel *negativeHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5,5, 40, 15)];
    negativeHeight.text = [NSString stringWithFormat:@"%d",(int)self.program.header.screenHeight.floatValue/2];
    negativeHeight.textColor = [UIColor redColor];
    [self.gridView addSubview:negativeHeight];
    
    [self.view insertSubview:self.gridView aboveSubview:self.skView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [[AudioManager sharedAudioManager] stopAllSounds];
    [[SensorHandler sharedSensorHandler] stopSensors];

    [[ProgramManager sharedProgramManager] setProgram:nil];

    //Delete sound rec for loudness sensor
    NSError *error;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* soundfile = [documentsPath stringByAppendingPathComponent:@"loudness_handler.m4a"];
    if ([fileMgr removeItemAtPath:soundfile error:&error] != YES)
        NSDebug(@"No Sound file available or unable to delete file: %@", [error localizedDescription]);
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backButtonPressed:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)revealMenu:(UIButton*)sender
{
    self.skView.paused = YES;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AudioManager sharedAudioManager] pauseAllSounds];

    [UIView animateWithDuration:1.0f
                          delay:0.5f
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{[self revealAnimation];}
                     completion:^(BOOL finished){
                         self.menuOpen = YES;
     }];
}

- (void)revealAnimation
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuView.frame = CGRectMake(-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=YES;
}

- (void)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - button functions
- (void)stopProgram:(UIButton*)sender
{
    [self.parentViewController.navigationController setToolbarHidden:NO];
    [self.parentViewController.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)continueProgram:(UIButton*)sender withDuration:(CGFloat)duration
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    CGFloat animateDuration = 0.0f;
    animateDuration = duration > 0.0001f ? duration : 0.35f;

    [UIView animateWithDuration:animateDuration
                          delay:0.0f
                        options: UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{[self continueAnimation];}
                     completion:^(BOOL finished){
                         self.menuOpen = NO;
                     }];
    self.skView.paused = NO;

    if (duration != kDontResumeSounds) {
        [[AudioManager sharedAudioManager] resumeAllSounds];
    }
}

- (void)continueAnimation
{
    self.menuView.frame = CGRectMake(-kWidthSlideMenu-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
}

- (void)configureScene
{
    CGSize programSize = CGSizeMake(self.program.header.screenWidth.floatValue, self.program.header.screenHeight.floatValue);
    Scene *scene = [[Scene alloc] initWithSize:programSize andProgram:self.program];
    scene.name = self.program.header.programName;
    scene.scaleMode = SKSceneScaleModeFill;
    self.skView.paused = NO;
    [self.skView presentScene:scene];
    [[ProgramManager sharedProgramManager] setProgram:self.program];
}

- (void)restartProgram:(UIButton*)sender
{
    self.program.playing = NO;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("org.catrobat.restartProgram", 0);
    __weak typeof(self)weakSelf = self;
    dispatch_async(backgroundQueue, ^{
        [NSThread sleepForTimeInterval:1.0f]; // XXX: wait until all blocks are finished!!
        __weak typeof(ScenePresenterViewController*)weakSelfSelf = weakSelf;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelfSelf.program removeReferences];
            weakSelfSelf.program = nil;
            weakSelfSelf.program = [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
            for (SpriteObject *sprite in weakSelfSelf.program.objectList) {
                sprite.broadcastWaitDelegate = weakSelfSelf.broadcastWaitHandler;
            }
            [weakSelfSelf.program updateReferences];
            [[AudioManager sharedAudioManager] stopAllSounds];

            [weakSelfSelf.broadcastWaitHandler removeSpriteMessages];
            Scene *previousScene = (Scene*)weakSelfSelf.skView.scene;
            previousScene.program = weakSelfSelf.program;

            if (! weakSelfSelf.program) {
                [[[UIAlertView alloc] initWithTitle:kLocalizedCantRestartProgram
                                            message:nil
                                           delegate:weakSelfSelf.menuView
                                  cancelButtonTitle:kLocalizedOK
                                  otherButtonTitles:nil] show];
                return;
            }
            [weakSelfSelf.skView presentScene:previousScene];
            [weakSelfSelf continueProgram:nil withDuration:0.0f];
            //    ScenePresenterViewController *vc = [[ScenePresenterViewController alloc] initWithProgram:[Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]]];
            //
            //    UINavigationController *navController = weakSelfSelf.navigationController;
            //
            //    //Get all view controllers in navigation controller currently
            //    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
            //
            //    //Remove the last view controller
            //    [controllers removeLastObject];
            //
            //    //set the new set of view controllers
            //    [navController setViewControllers:controllers];
            //
            //    //Push a new view controller
            //    [navController pushViewController:vc animated:NO];
        });
    });
}

- (void)showHideAxis:(UIButton*)sender
{
    if (self.gridView.hidden == NO) {
        self.gridView.hidden = YES;
    } else {
        self.gridView.hidden = NO;
    }
}

- (void)manageAspectRatio:(UIButton *)sender
{
    self.skView.scene.scaleMode = self.skView.scene.scaleMode == SKSceneScaleModeAspectFit ? SKSceneScaleModeFill : SKSceneScaleModeAspectFit;
    [self.skView setNeedsLayout];
    self.menuOpen = YES;
    //pause Scene
    SKView * view= self.skView;
    view.paused=YES;
    //view.userInteractionEnabled = NO;
    [[AudioManager sharedAudioManager] pauseAllSounds];
}

- (void)takeScreenshot:(UIButton *)sender
{
    /// Screenshot function
    UIGraphicsBeginImageContextWithOptions(self.skView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.skView drawViewHierarchyInRect:self.skView.bounds afterScreenUpdates:NO];
    self.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self showSaveScreenshotActionSheet];
    
}
- (void)showSaveScreenshotActionSheet
{
    UIImage *imageToShare = self.snapshotImage;
    NSString* path = [self.program projectPath];
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
        SKView * view= weakself.skView;
        view.paused=YES;
    }];
    
    [self presentViewController:activityVC animated:YES completion:^(){
        SKView * view= weakself.skView;
        view.paused=YES;
    }];
}

// Now we have an activity view -> just in case we need change back to the action sheet
//- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//  NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
//  if ([buttonTitle isEqualToString:kLocalizedCameraRoll]) {
//    /// Write to Camera Roll
//    UIImageWriteToSavedPhotosAlbum(self.snapshotImage, nil, nil, nil);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLocalizedScreenshotSavedToCameraRoll
//                                                    message:nil
//                                                   delegate:self.menuView
//                                          cancelButtonTitle:kLocalizedOK
//                                          otherButtonTitles:nil];
//    [alert show];
//  }
//
//  if ([buttonTitle isEqualToString:kLocalizedProject]) {
//    NSString* path = [self.program projectPath];
//    NSString *pngFilePath = [NSString stringWithFormat:@"%@/manual_screenshot.png",path];
//    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(self.snapshotImage)];
//    [data writeToFile:pngFilePath atomically:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLocalizedScreenshotSavedToProject
//                                                    message:nil
//                                                   delegate:self.menuView
//                                          cancelButtonTitle:kLocalizedOK
//                                          otherButtonTitles:nil];
//    [alert show];
//
//  }
//
//}

#pragma mark PanGestureHandler
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
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
                             completion:^(BOOL finished) {
                                 //self.menuOpen = YES;
                                 //[[AudioManager sharedAudioManager] pauseAllSounds];
                             }];
        } else if (translate.x < 0.0 && translate.x > -kWidthSlideMenu && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleNegativePan:translate];}
                             completion:^(BOOL finished) {
                                 //SKView * view= (SKView*)_skView;
                                 //view.paused=NO;
                                 //[[AudioManager sharedAudioManager] resumeAllSounds];
                                 //self.menuOpen = NO;
                             }];
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
                                 //pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 //view.userInteractionEnabled = NO;
                                 [[AudioManager sharedAudioManager] pauseAllSounds];
                                 
                                 if (translate.x < (kWidthSlideMenu) && velocityX >300) {
                                     [self bounce];
                                 }
                             }];
        } else if(translate.x > 0.0 && translate.x <(kWidthSlideMenu/4) && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledNegative:translate];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused=NO;
                                 //view.userInteractionEnabled = YES;
                                 self.menuOpen= NO;
                                 [[AudioManager sharedAudioManager] resumeAllSounds];
                             }];
        } else if (translate.x < (-kWidthSlideMenu/4)  && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledNegative:translate];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused=NO;
                                 //view.userInteractionEnabled = YES;
                                 self.menuOpen= NO;
                                 [[AudioManager sharedAudioManager] resumeAllSounds];
                             }];
        } else if (translate.x > (-kWidthSlideMenu/4) && translate.x < 0.0   && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handleCancelledPositive:translate];}
                             completion:^(BOOL finished) {
                                 self.menuOpen = YES;
                                 //pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 //view.userInteractionEnabled = NO;
                                 [[AudioManager sharedAudioManager] pauseAllSounds];
                                 if (translate.x > -(kWidthSlideMenu) && velocityX < -100) {
                                     [self bounce];
                                 }
                             }];
        }
    }
}


- (void)handlePositvePan:(CGPoint)translate
{
    [self.view bringSubviewToFront:self.menuView];
//    UIColor *background = [UIColor darkBlueColor];//[[UIColor alloc] initWithPatternImage:snapshotImage];
//    self.menuView.backgroundColor = background;
//    
//    SKView * view= (SKView*)_skView;
//    view.paused=YES;
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
//    UIColor *background = [UIColor darkBlueColor];//[[UIColor alloc] initWithPatternImage:snapshotImage];
//    self.menuView.backgroundColor = background;
    self.menuView.frame = CGRectMake(-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=YES;
}

- (void)handleCancelledNegative:(CGPoint)translate
{
    self.menuView.frame = CGRectMake(-kWidthSlideMenu-kBounceEffect, 0, self.menuView.frame.size.width, self.menuView.frame.size.height);
    self.menuBtn.hidden=NO;
}

- (void)bounce
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    [animation setFromValue:[NSNumber numberWithFloat:kWidthSlideMenu/2]];
    [animation setToValue:[NSNumber numberWithFloat:(kWidthSlideMenu/2)+(kBounceEffect/2)]];
    [animation setDuration:.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5f :1.8f :1 :1]];
    [self.menuView.layer addAnimation:animation forKey:@"somekey"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.menuOpen) {
        NSDebug(@"touch on scene not allowed, because menu is open");
    }
    else{
        NSDebug(@"touch on scene allowed");
        for (UITouch* touch in touches) {
            CGPoint location = [touch locationInView:self.skView];
            NSDebug(@"StartTouchinScenePresenter");
            
            Scene *scene = (Scene *)self.skView.scene;
            if ([scene touchedwith:touches withX:location.x andY:location.y]) {
                break;
            }
        }
    }

}

- (void)pause
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AudioManager sharedAudioManager] pauseAllSounds];
}

- (void)resume
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AudioManager sharedAudioManager] resumeAllSounds];
}

@end

