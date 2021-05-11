/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "StagePresenterViewController.h"
#import "Util.h"
#import "Script.h"
#import "AudioManager.h"
#import "FlashHelper.h"
#import "CameraPreviewHandler.h"
#import "CatrobatLanguageDefines.h"
#import "RuntimeImageCache.h"
#import "Pocket_Code-Swift.h"

@interface StagePresenterViewController() <UIActionSheetDelegate, StagePresenterSideMenuDelegate>
@property (nonatomic, strong) Stage *stage;
@property (nonatomic, strong) SKView *skView;
@property (nonatomic, strong) StagePresenterSideMenuView *menuView;
@property (nonatomic, strong) NSLayoutConstraint *menuViewLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *menuViewRightConstraint;

@property (nonatomic) BOOL menuOpen;
@property (nonatomic) CGPoint firstGestureTouchPoint;
@property (nonatomic) UIImage *snapshotImage;
@end

@implementation StagePresenterViewController

- (void)stopProject
{
    [self.stage stopProject];
    
    // TODO remove Singletons
    [[CameraPreviewHandler shared] stopCamera];
    
    [[FlashHelper sharedFlashHandler] reset];
    [[FlashHelper sharedFlashHandler] turnOff]; // always turn off flash light when Scene is stopped
    
    [[BluetoothService sharedInstance] setStagePresenter:nil];
    [[BluetoothService sharedInstance] resetBluetoothDevice];
}

#pragma mark - View Event Handling
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _skView = [[SKView alloc] initWithFrame:self.view.bounds];
    _skView.paused = NO;
    
    #if DEBUG == 1
        _skView.showsFPS = YES;
        _skView.showsNodeCount = YES;
        _skView.showsDrawCount = YES;
    #endif
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    self.skView.backgroundColor = UIColor.background;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    // disable swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.menuOpen = NO;
    
    [self.view addSubview:self.skView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.menuView = [[StagePresenterSideMenuView alloc] initWithFrame:CGRectMake(0, 0, screenWidth / StagePresenterSideMenuView.widthProportionalPortrait, screenHeight) andStagePresenterViewController_: self];
    
    [self.view insertSubview:self.menuView aboveSubview:self.skView];
    
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.menuView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.menuView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    if (self.project.header.landscapeMode == YES)
    {
        self.menuViewRightConstraint = [self.menuView.rightAnchor constraintEqualToAnchor:self.view.leftAnchor constant:self.view.frame.size.width / StagePresenterSideMenuView.widthProportionalLandscape];
    } else {
        self.menuViewRightConstraint = [self.menuView.rightAnchor constraintEqualToAnchor:self.view.leftAnchor constant:self.view.frame.size.width / StagePresenterSideMenuView.widthProportionalPortrait];
    }
    
    self.menuViewRightConstraint.active = YES;
    self.menuViewLeadingConstraint = [self.menuView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor];
    self.menuViewLeadingConstraint.active = YES;
    [self.view layoutIfNeeded];
    
    [self setUpGridView];
    [self setupStageAndStart];
    
    [self hideMenuView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.stagePresenterViewControllerDidAppear object:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.menuView removeFromSuperview];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
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

#pragma mark - Initialization & Setup & Dealloc
#pragma mark Dealloc
- (void)dealloc
{
    [self freeRessources];
}

- (void)freeRessources
{
    self.project = nil;
    self.stage = nil;
    
    // Delete sound rec for loudness sensor
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *soundfile = [documentsPath stringByAppendingPathComponent:@"loudness_handler.m4a"];
    if ([fileMgr removeItemAtPath:soundfile error:&error] != YES)
        NSDebug(@"No Sound file available or unable to delete file: %@", [error localizedDescription]);
}

#pragma mark View Setup
- (void)setUpGridView
{
    self.gridView.backgroundColor = UIColor.clearColor;
    UIView *xArrow = [[UIView alloc] initWithFrame:CGRectMake(0,[Util screenHeight]/2,[Util screenWidth],1)];
    xArrow.backgroundColor = UIColor.redColor;
    [self.gridView addSubview:xArrow];
    UIView *yArrow = [[UIView alloc] initWithFrame:CGRectMake([Util screenWidth]/2,0,1,[Util screenHeight])];
    yArrow.backgroundColor = UIColor.redColor;
    [self.gridView addSubview:yArrow];
    // nullLabel
    UILabel *nullLabel = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight]/2 + 5, 10, 15)];
    nullLabel.text = @"0";
    nullLabel.textColor = UIColor.redColor;
    [self.gridView addSubview:nullLabel];
    // positveWidth
    UILabel *positiveWidth = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]- 40, [Util screenHeight]/2 + 5, 30, 15)];
    positiveWidth.textColor = UIColor.redColor;

    positiveWidth.frame = CGRectMake([Util screenWidth] - positiveWidth.frame.size.width - 5, [Util screenHeight]/2 + 5, positiveWidth.frame.size.width, positiveWidth.frame.size.height);
    
    // negativeWidth
    UILabel *negativeWidth = [[UILabel alloc] initWithFrame:CGRectMake(5, [Util screenHeight]/2 + 5, 40, 15)];
    negativeWidth.textColor = UIColor.redColor;
    
    // positveHeight
    UILabel *positiveHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5, [Util screenHeight] - 20, 40, 15)];
    positiveHeight.textColor = UIColor.redColor;

    // negativeHeight
    UIViewController *root = UIApplication.sharedApplication.keyWindow.rootViewController;
    UILabel *negativeHeight;
    if (@available(iOS 11.0, *)) {
        negativeHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5,root.view.safeAreaInsets.top, 40, 15)];
    } else {
        negativeHeight = [[UILabel alloc] initWithFrame:CGRectMake([Util screenWidth]/2 + 5,5, 40, 15)];
    }
    negativeHeight.textColor = UIColor.redColor;

    if (!self.project.header.landscapeMode) {
        positiveWidth.text = [NSString stringWithFormat:@"%d",(int)self.project.header.screenWidth.floatValue/2];
        negativeWidth.text = [NSString stringWithFormat:@"-%d",(int)self.project.header.screenWidth.floatValue/2];
        positiveHeight.text = [NSString stringWithFormat:@"-%d",(int)self.project.header.screenHeight.floatValue/2];
        negativeHeight.text = [NSString stringWithFormat:@"%d",(int)self.project.header.screenHeight.floatValue/2];
    } else {
        positiveWidth.text = [NSString stringWithFormat:@"%d",(int)self.project.header.screenHeight.floatValue/2];
        negativeWidth.text = [NSString stringWithFormat:@"-%d",(int)self.project.header.screenHeight.floatValue/2];
        positiveHeight.text = [NSString stringWithFormat:@"-%d",(int)self.project.header.screenWidth.floatValue/2];
        negativeHeight.text = [NSString stringWithFormat:@"%d",(int)self.project.header.screenWidth.floatValue/2];
    }
    
    [self.gridView addSubview:positiveWidth];
    [self.gridView addSubview:negativeWidth];
    [self.gridView addSubview:positiveHeight];
    [self.gridView addSubview:negativeHeight];
    
    [positiveWidth sizeToFit];
    [negativeWidth sizeToFit];
    [positiveHeight sizeToFit];
    [negativeHeight sizeToFit];
    
    [self.view insertSubview:self.gridView aboveSubview:self.skView];
}

- (void)setupStageAndStart
{
    // Initialize scene
    Stage *stage = [[[[StageBuilder alloc] initWithProject:self.project] andFormulaManager:self.formulaManager] build];
    
    if ([self.project.header.screenMode isEqualToString: kCatrobatHeaderScreenModeMaximize]) {
        stage.scaleMode = SKSceneScaleModeFill;
    } else if ([self.project.header.screenMode isEqualToString: kCatrobatHeaderScreenModeStretch]){
        stage.scaleMode = SKSceneScaleModeAspectFit;
    } else {
        stage.scaleMode = SKSceneScaleModeFill;
    }
    self.skView.paused = NO;
    self.stage = stage;
    
    [[BluetoothService sharedInstance] setStagePresenter:self];
    [[CameraPreviewHandler shared] setCamView:self.view];

    [self.skView presentScene:self.stage];
    if (![self.stage startProject]) {
        [self stopAction];
    }
    
    [self hideLoadingView];
    [self continueActionWithDuration:kFirstSwipeDuration];
}

-(void)resaveLooks
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        for (SpriteObject *object in self.project.scene.objects) {
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

#pragma mark - Game Event Handling
- (void)pauseAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[self.stage getSoundEngine] pause];
        [[FlashHelper sharedFlashHandler] pause];
        [[BluetoothService sharedInstance] pauseBluetoothDevice];
    });
    
    [self.stage pauseScheduler];
}

- (void)resumeAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[self.stage getSoundEngine] resume];
        [[BluetoothService sharedInstance] continueBluetoothDevice];
        if ([FlashHelper sharedFlashHandler].wasTurnedOn == FlashON) {
            [[FlashHelper sharedFlashHandler] resume];
        }
    });
    
    [self.stage resumeScheduler];
}

- (void)continueAction
{
    [self continueActionWithDuration:0];
}

- (void)continueActionWithDuration:(CGFloat)duration
{
    if (duration != kFirstSwipeDuration) {
        [self resumeAction];
    }
    
    CGFloat animateDuration = 0.0f;
    animateDuration = (duration > 0.0001f && duration < 1.0f)? duration : 0.35f;

    [UIView animateWithDuration:animateDuration
                          delay:kHideMenuViewDelay
                        options: UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{[self hideMenuView];}
                     completion:^(BOOL finished){
                         self.menuOpen = NO;
                         self.menuView.userInteractionEnabled = YES;
                         if (animateDuration == duration) {
                             [self takeAutomaticScreenshotForSKView:self.skView andProject:self.project.scene];
                         }
                     }];
    self.skView.paused = NO;
}

- (void)stopAction
{
    Stage *previousStage = self.stage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        self.menuView.userInteractionEnabled = NO;
        previousStage.userInteractionEnabled = NO;
        [self stopProject];
        previousStage.userInteractionEnabled = YES;
    });
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restartAction
{
    [self showLoadingView];
    
    self.menuView.userInteractionEnabled = NO;
    self.stage.userInteractionEnabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self stopProject];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.project = [Project projectWithLoadingInfo:[Util lastUsedProjectLoadingInfo]];
            [self setupStageAndStart];
            [self.menuView restartWithProject:self.project];
        });
    });
}

#pragma mark - Bluetooth Event Handling
-(void)connectionLost
{
    [self showLoadingView];
    self.menuView.userInteractionEnabled = NO;
    Stage *previousStage = self.stage;
    previousStage.userInteractionEnabled = NO;
    [self stopProject];
    previousStage.userInteractionEnabled = YES;
    [self hideLoadingView];
    
    [[[[AlertControllerBuilder alertWithTitle:@"Lost Bluetooth Connection" message:kLocalizedPocketCode]
       addCancelActionWithTitle:kLocalizedOK handler:^{
           [self.parentViewController.navigationController setToolbarHidden:NO];
           [self.parentViewController.navigationController setNavigationBarHidden:NO];
           [self.navigationController popViewControllerAnimated:YES];
       }] build]
     showWithController:self];
}

#pragma mark - User Event Handling

- (void)showHideAxisAction
{
    if (self.gridView.hidden == NO) {
        self.gridView.hidden = YES;
    } else {
        self.gridView.hidden = NO;
    }
}

- (void)aspectRatioAction
{
    self.stage.scaleMode = self.stage.scaleMode == SKSceneScaleModeAspectFit ? SKSceneScaleModeFill : SKSceneScaleModeAspectFit;
    if ([self.project.header.screenMode isEqualToString:kCatrobatHeaderScreenModeStretch]) {
         self.project.header.screenMode = kCatrobatHeaderScreenModeMaximize;
    } else {
        self.project.header.screenMode = kCatrobatHeaderScreenModeStretch;
    }
    [self.skView setNeedsLayout];
    self.menuOpen = YES;
    // pause Scene
    SKView *view = self.skView;
    view.paused = YES;
}

- (void)takeScreenshotAction
{
    [self takeManualScreenshotForSKView:self.skView andProject:self.project.scene];
}

#pragma mark - Pan Gesture Handler

- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0;
    
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.firstGestureTouchPoint = [gesture locationInView:gesture.view];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (translate.x > 0.0 && translate.x < self.menuView.frame.size.width && self.firstGestureTouchPoint.x < kSlidingStartArea && self.menuOpen == NO ) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handlePositvePan:translate];}
                             completion:nil];
        }else if (translate.x > 0.0 && translate.x < self.menuView.frame.size.width && self.menuOpen == YES ) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self handlePositvePan:translate];}
                             completion:nil];
            
        } else if (translate.x < 0.0 && translate.x > -self.menuView.frame.size.width && self.menuOpen == YES) {
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
        if (translate.x > (self.menuView.frame.size.width/4) && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self showMenuView];}
                             completion:^(BOOL finished) {
                                 self.menuOpen = YES;
                                 // pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 [self pauseAction];
                             }];
        } else if(translate.x > 0.0 && translate.x <(self.menuView.frame.size.width/4) && self.menuOpen == NO && self.firstGestureTouchPoint.x < kSlidingStartArea) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self hideMenuView];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused = NO;
                                 self.menuOpen = NO;
                                 [self resumeAction];
                             }];
        } else if (translate.x < (-self.menuView.frame.size.width/4)  && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self hideMenuView];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused = NO;
                                 self.menuOpen = NO;
                                 [self resumeAction];
                             }];
        } else if (translate.x > (-self.menuView.frame.size.width/4) && self.menuOpen == YES) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self showMenuView];}
                             completion:^(BOOL finished) {
                                 self.menuOpen = YES;
                                 // pause Scene
                                 SKView * view= self.skView;
                                 view.paused=YES;
                                 [self pauseAction];
                             }];
        }
        else {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{[self hideMenuView];}
                             completion:^(BOOL finished) {
                                 SKView * view = self.skView;
                                 view.paused = NO;
                                 self.menuOpen = NO;
                                 [self resumeAction];
                             }];
        }
    }
}

- (void)handlePositvePan:(CGPoint)translate
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuViewLeadingConstraint.constant = -self.menuView.frame.size.width + translate.x;
    self.menuViewRightConstraint.constant = translate.x;
    [self.view layoutIfNeeded];
}

- (void)handleNegativePan:(CGPoint)translate
{
    if (self.menuViewRightConstraint.constant > 0)
    {
        self.menuViewLeadingConstraint.constant = self.menuViewLeadingConstraint.constant + translate.x;
        self.menuViewRightConstraint.constant = self.menuViewRightConstraint.constant + translate.x;
        if (self.menuViewRightConstraint.constant < 0.0)
        {
            self.menuViewLeadingConstraint.constant = self.menuViewLeadingConstraint.constant + fabs(self.menuViewRightConstraint.constant);
            self.menuViewRightConstraint.constant = 0.0;
            self.menuOpen = NO;
        }
        [self.view layoutIfNeeded];
    }
}

- (void)showMenuView
{
    [self.view bringSubviewToFront:self.menuView];
    self.menuViewLeadingConstraint.constant = 0;
    
    if(self.project.header.landscapeMode == YES){
        self.menuViewRightConstraint.constant = self.view.frame.size.width / StagePresenterSideMenuView.widthProportionalLandscape;
    } else {
        self.menuViewRightConstraint.constant = self.view.frame.size.width / StagePresenterSideMenuView.widthProportionalPortrait;
    }
    [self.view layoutIfNeeded];
}

- (BOOL)checkEmbroideryEnabled
{
    return self.isEmbroideryStreamFilled;
}

- (void)hideMenuView
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.menuViewLeadingConstraint.constant = -self.menuView.frame.size.width;
        self.menuViewRightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    });
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
    }
    return _loadingView;
}

- (void)showLoadingView
{
    [self.loadingView show];
}

- (void)hideLoadingView
{
    [self.loadingView hide];
}

- (BOOL)isPaused
{
    return self.menuOpen;
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

@end
