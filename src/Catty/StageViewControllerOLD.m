//
//  StageViewController.m
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "StageViewControllerOLD.h"
#import "Program.h"
#import "SpriteObject.h"
//#import "LevelLoadingInfo.h"
#import "Parser.h"
#import "Brick.h"
#import "Script.h"
#import "BaseSprite.h"
#import "SpriteManagerDelegate.h"
#import "BroadcastWaitHandler.h"
#import "Whenscript.h"
#import "Startscript.h"
#import "Broadcastscript.h"

@interface StageViewControllerOLD ()

@property (strong, nonatomic) Program *level;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (strong, nonatomic) BaseSprite *blackLeft;
@property (strong, nonatomic) BaseSprite *blackRight;
@property (strong, nonatomic) BaseSprite *blackTop;
@property (strong, nonatomic) BaseSprite *blackBottom;

@property (strong, nonatomic) BroadcastWaitHandler *broadcastWaitHandler;

@end


@implementation StageViewControllerOLD


@synthesize context = _context;
@synthesize effect = _effect;
@synthesize level = _level;

@synthesize levelLoadingInfo = _levelLoadingInfo;

@synthesize blackLeft = _blackLeft;
@synthesize blackRight = _blackRight;
@synthesize blackTop = _blackTop;
@synthesize blackBottom = _blackBottom;

@synthesize broadcastWaitHandler = _broadcastWaitHandler;


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

    //graphics context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.delegate = self;
    [EAGLContext setCurrentContext:self.context];
    
    //custom catty code
    self.delegate = self;
    self.preferredFramesPerSecond = FRAMES_PER_SECOND;
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    NSLog(@"screen (width/height): %f / %f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.height, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];

    
    self.broadcastWaitHandler = [[BroadcastWaitHandler alloc]init];
    
    // load level here!
    [self loadLevel];
    
    // set black frame for scaled projects
    // TODO: dirty!!!
    SpriteObject *sprite = [self.level.objectList lastObject];
    
    float screenWidth  = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imageFilePath = [bundle pathForResource:@"tmp.png" ofType:nil];

    NSLog(@"Path to black image: %@", imageFilePath);
    
    if (sprite.xOffset > 0) {
        self.blackLeft  = [[BaseSprite alloc] init];
        self.blackRight = [[BaseSprite alloc] init];
        self.blackLeft.effect  = self.effect;
        self.blackRight.effect = self.effect;
        self.blackLeft.realPosition  = GLKVector3Make(sprite.xOffset/2.0f, screenHeight/2.0f, 1024);
        self.blackRight.realPosition = GLKVector3Make(screenWidth-(sprite.xOffset/2.0f), screenHeight/2.0f, 1024);
        [self.blackLeft  loadImageWithPath:imageFilePath width:sprite.xOffset height:screenHeight];
        [self.blackRight loadImageWithPath:imageFilePath width:sprite.xOffset height:screenHeight];
    }
    
    if (sprite.yOffset > 0) {
        self.blackTop    = [[BaseSprite alloc] init];
        self.blackBottom = [[BaseSprite alloc] init];
        self.blackTop.effect    = self.effect;
        self.blackBottom.effect = self.effect;
        self.blackTop.realPosition    = GLKVector3Make(screenWidth/2.0f, screenHeight-(sprite.yOffset/2.0f), 1024);
        self.blackBottom.realPosition = GLKVector3Make(screenWidth/2.0f, sprite.yOffset/2.0f, 1024);
        [self.blackTop    loadImageWithPath:imageFilePath width:screenWidth height:sprite.yOffset];
        [self.blackBottom loadImageWithPath:imageFilePath width:screenWidth height:sprite.yOffset];
    }
    
    [self startLevel];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self stopAllSounds];
    for (SpriteObject *sprite in self.level.objectList) {
        [sprite stopAllScripts];
    }
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - instance methods
- (void)startLevel
{
    
    for (SpriteObject *sprite in self.level.objectList)
    {
        [sprite start];
    }
}

- (void)loadLevel
{
//    NSLog(@"Try to load project '%@'", self.levelLoadingInfo.visibleName);
//    NSLog(@"Path: %@", self.levelLoadingInfo.basePath);
//    
//    NSString *xmlPath = [NSString stringWithFormat:@"%@code.xml", self.levelLoadingInfo.basePath];       // TODO: change const string!!!
//
//    NSLog(@"XML-Path: %@", xmlPath);
//    
//    Parser *parser = [[Parser alloc]init];
//    self.level = [parser generateObjectForLevel:xmlPath];
//    
//    NSLog(@"ProjectResolution: width/height:  %f / %f", self.level.header.screenWidth.floatValue, self.level.header.screenHeight.floatValue);
//    
//    CGSize screenResolution = CGSizeMake(self.level.header.screenWidth.floatValue, self.level.header.screenHeight.floatValue);
//    
//    //setting effect
//    for (SpriteObject *sprite in self.level.objectList)
//    {
//        sprite.effect = self.effect;
//        sprite.spriteManagerDelegate = self;
//        sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
//        sprite.projectPath = self.levelLoadingInfo.basePath;
//        [sprite setProjectResolution:screenResolution];
//        
//        // TODO: change!
//        for (Script *script in sprite.scriptList) {
//            for (Brick *brick in script.brickList) {
//                brick.object = sprite;
//            }
//        }
//        
//        
//        
//        
//        // debug:
//        NSLog(@"----------------------");
//        NSLog(@"Sprite: %@", sprite.name);
//        NSLog(@" ");
//        NSLog(@"StartScript:");
//        for (Script *script in sprite.scriptList) {
//            if ([script isKindOfClass:[Startscript class]]) {
//                for (Brick *brick in [script getAllBricks]) {
//                    NSLog(@"  %@", [brick description]);
//                }
//            }
//        }
//        for (Script *script in sprite.scriptList) {
//            if ([script isKindOfClass:[Whenscript class]]) {
//                NSLog(@" ");
//                NSLog(@"WhenScript:");
//                for (Brick *brick in [script getAllBricks]) {
//                    NSLog(@"  %@", [brick description]);
//                }
//            }
//        }
//        for (Script *script in sprite.scriptList) {
//            if ([script isKindOfClass:[Broadcastscript class]]) {
//                NSLog(@" ");
//                NSLog(@"BroadcastScript:");
//                for (Brick *brick in [script getAllBricks]) {
//                    NSLog(@"  %@", [brick description]);
//                }
//            }
//        }
//    }
}







#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    
    glClearColor(1, 1, 1, 1);
    //glClearColor(0.0f, 0.0f, 0.0f, 0.0f); //black glkit view bg color
    
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (SpriteObject *sprite in self.level.objectList) {
        [sprite render];
    }
    [self.blackLeft   render];
    [self.blackRight  render];
    [self.blackTop    render];
    [self.blackBottom render];
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    //NSLog(@"Update...");
    for (SpriteObject *sprite in self.level.objectList) {
        [sprite update:self.timeSinceLastUpdate];
    }
}


#pragma mark - touch delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.paused = !self.paused;
    //NSLog(@"touched");
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = CGPointMake(touchLocation.x, [UIScreen mainScreen].bounds.size.height - touchLocation.y);
    
    NSLog(@"tapped at %g / %g", touchLocation.x, touchLocation.y);
    
    float width = 5; //todo: adjust this later
    float height = 5; //todo adjust this later
    CGRect tapRect = CGRectMake(touchLocation.x, touchLocation.y, width, height);
    
    //depth check
//    float zIndex = 0;
    SpriteObject *foregroundSprite = nil;
    
    //check if a collision (tap) occured
    for (SpriteObject *sprite in self.level.objectList)
    {
        if(CGRectIntersectsRect(sprite.boundingBox, tapRect) && sprite.showSprite)// && [sprite getZIndex] >= zIndex)    // order in array is sprite-z-index
        {
//            zIndex = [sprite getZIndex];
            foregroundSprite = sprite;
        }
    }
    
    NSLog(@"User tapped sprite: %@", foregroundSprite.name);
    [foregroundSprite touch:kTouchActionTap];
}

#pragma mark - SpriteManagerDelegate
-(void)bringToFrontSprite:(SpriteObject *)sprite
{
    // TODO: CHANGE THIS ASAP!!!
    NSMutableArray *sprites = [self.level.objectList mutableCopy];
    [sprites removeObject:sprite];
    [sprites addObject:sprite];
    self.level.objectList = [NSArray arrayWithArray:sprites];
}

-(void)bringNStepsBackSprite:(SpriteObject *)sprite numberOfSteps:(int)n
{
    NSMutableArray *sprites = [self.level.objectList mutableCopy];
    
    int oldIndex = [sprites indexOfObject:sprite];
    [sprites removeObject:sprite];
    
    int newIndex = oldIndex - n;
    if (newIndex < 1)
        newIndex = 1;
    if (newIndex >= [sprites count])    // negative n-value
        newIndex = [sprites count] - 1;
    
    [sprites insertObject:sprite atIndex:newIndex];
    
    self.level.objectList = [NSArray arrayWithArray:sprites];
}


-(void)stopAllSounds
{
    for(SpriteObject* sprite in self.level.objectList)
    {
        [sprite stopAllSounds];
    }
}



// back button on view
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
