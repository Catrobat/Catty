//
//  CattyViewController.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "CattyViewController.h"
#import "Level.h"
#import "StartScript.h"
#import "Brick.h"
#import "SetCostumeBrick.h"
#import "TestParser.h"
#import "WhenScript.h"
#import "WaitBrick.h"
#import "RetailParser.h"
#import "Util.h"
#import "BaseSprite.h"

//debug
#import "Costume.h"
#import "TestParser.h"



@interface CattyViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) NSMutableArray *startScriptsArray;
@property (strong, nonatomic) NSMutableArray *whenScriptsArray;

@end

@implementation CattyViewController


@synthesize context = _context;
@synthesize effect = _effect;
@synthesize startScriptsArray = _startScriptsArray;
@synthesize whenScriptsArray = _whenScriptsArray;
@synthesize level = _level;


//debug
@synthesize sprite = _sprite;

#pragma mark - getter
- (NSMutableArray*)startScriptsArray
{
    if (!_startScriptsArray)
        _startScriptsArray = [[NSMutableArray alloc]init];
    return _startScriptsArray;
}

- (NSMutableArray*)whenScriptsArray
{
    if (!_whenScriptsArray)
        _whenScriptsArray = [[NSMutableArray alloc]init];
    return _whenScriptsArray;
}


#pragma mark - view loading and unloading
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 320, 0, 480, -1024, 1024); // TODO: do not use constants
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];                                                               
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    //load level before starting (this should happen BEFORE this controller is invoked
//    TestParser *parser = [[TestParser alloc] init];
//    parser.effect = self.effect;
//    self.level = [parser generateObjectForLevel:@"dup di dup"];

//    NSLog(@"%@", self.level);
//    //self.player = [[SGGSprite alloc] initWithFile:@"normalcat.png" effect:self.effect];   
//    
//    
//    Costume *newCostume1 = [[Costume alloc]init];
//    newCostume1.costumeFileName = @"normalcat.png";
//    newCostume1.costumeName = @"cat1";

    
    //self.sprite = [[Sprite alloc] initWithCostume:newCostume1 effect:self.effect];

    //loading real project
//    NSString *fileName = @"defaultProject";
//    NSString *projectName = @"defaultProject";
    NSString *fileName = @"rocket/rocket";
    NSString *projectName = @"rocket";
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"xml"];
    
    NSLog(@"XML-Path: %@", path);
    
    RetailParser *parser = [[RetailParser alloc] init];
//    self.level = [parser generateObjectForLevel:path];
    
    
    // DEBUG
    
    TestParser *testparser = [[TestParser alloc]init];
    projectName = @"defaultProject";
//    self.level = [testparser generateDebugLevel_GlideTo];
//    self.level = [testparser generateDebugLevel_nextCostume];
//    self.level = [testparser generateDebugLevel_HideShow];
//    self.level = [testparser generateDebugLevel_SetXY];
//    self.level = [testparser generateDebugLevel_broadcast];
//    self.level = [testparser generateDebugLevel_comeToFront];
//    self.level = [testparser generateDebugLevel_changeSizeByN];
//    self.level = [testparser generateDebugLevel_parallelScripts];
//    self.level = [testparser generateDebugLevel_loops];
//    self.level = [testparser generateDebugLevel_rotate];
    // DEBUG END
    
//    NSString *pathToImage = [NSString stringWithFormat:@"%@/defaultProject/images/%@", [Util applicationDocumentsDirectory], projectName];
//    NSString *path = [NSString stringWithFormat:@"/%@/%@/%@", self.projectName, SPRITE_IMAGE_FOLDER, fileName];
//    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:path ofType:nil];

    path = @"/Users/Mattias/Library/Application Support/iPhone Simulator/6.0/Applications/742C0D4A-0BD7-4037-AADF-DD7C4C17A383/Catty.app/defaultProject/";
    
    //setting effect
    for (Sprite *sprite in self.level.spritesArray)
    {
        sprite.effect = self.effect;
        sprite.spriteManagerDelegate = self;
        sprite.projectPath = path;
        //        sprite.projectName = projectName;
        
        // debug:
        NSLog(@"----------------------");
        NSLog(@"Sprite: %@", sprite.name);
        NSLog(@" ");
        NSLog(@"StartScript:");
        for (Script *script in sprite.startScriptsArray) {
            for (Brick *brick in [script getAllBricks]) {
                NSLog(@"  %@", [brick description]);
            }
        }
        for (Script *script in sprite.whenScriptsArray) {
            NSLog(@" ");
            NSLog(@"WhenScript:");
            for (Brick *brick in [script getAllBricks]) {
                NSLog(@"  %@", [brick description]);
            }
        }
        for (Script *script in [sprite.broadcastScripts allValues]) {
            NSLog(@" ");
            NSLog(@"BroadcastScript:");
            for (Brick *brick in [script getAllBricks]) {
                NSLog(@"  %@", [brick description]);
            }
        }

        // end debug
        
    }
    
    GLKBaseEffect *newEffect = [[GLKBaseEffect alloc]init];
    self.sprite = [[BaseSprite alloc]initWithEffect:newEffect];
    [self.sprite loadImageWithPath:[NSString stringWithFormat:@"%@/images/normalcat.png", path]];
    self.sprite.rotationInDegrees = -45.0f;

    [self performSelectorOnMainThread:@selector(tmp) withObject:nil waitUntilDone:NO];
    
    [self startLevel];
}

-(void)tmp
{
    [NSThread sleepForTimeInterval:3];
    self.sprite.position = GLKVector3Make(100.0f, 100.0f, 0.0f);
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
        
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - instance methods
- (void)startLevel
{
    for (Sprite *sprite in self.level.spritesArray)
    {
        [sprite start];
//        for (StartScript *script in sprite.startScriptsArray)
//        {
//            NSLog(@"run start script");
//            //[self runScript:script];
//            [script executeForSprite:sprite];
//        }
    }
 
}

//- (void)runScript:(Script*)script
//{
//    for (Brick *brick in script.bricksArray) 
//    {
//        if ([brick isMemberOfClass:[SetCostumeBrick class]]) 
//        {
//            
////            NSLog(@"run SetCostumeBrick of sprite <%@>", brick.sprite.name);
//            
//            
//            SetCostumeBrick *setCostumeBrick = (SetCostumeBrick*)brick;
//            
////            brick.sprite.indexOfCurrentCostumeInArray = setCostumeBrick.indexOfCostumeInArray;
//            
//        }// else if (brick == anotherBrickClass)... and so on...
//    }
//}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {    
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);

    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    //NSLog(@"draw in rect...");
    
    [self.sprite render];
    
//    for (Sprite *sprite in self.level.spritesArray)
//    {
//        //NSLog(@"render sprite <%@> at position %g / %g", sprite.name, sprite.position.x, sprite.position.y);
//        [sprite render];
//    }
    for (Sprite *sprite in self.level.spritesArray)
    {
        //NSLog(@"render sprite <%@> at position %g / %g", sprite.name, sprite.position.x, sprite.position.y);
        [sprite render];
    }

}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    //NSLog(@"Update...");
    for (Sprite *sprite in self.level.spritesArray)
    {
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
    touchLocation = CGPointMake(touchLocation.x, 480 - touchLocation.y);    // TODO: DO NOT USE CONSTANTS!!
    
    NSLog(@"tapped at %g / %g", touchLocation.x, touchLocation.y);
    
    float width = 5; //todo: adjust this later
    float height = 5; //todo adjust this later
    CGRect tapRect = CGRectMake(touchLocation.x, touchLocation.y, width, height);
    
    //depth check
    float zIndex = 0;
    Sprite *foregroundSprite = nil;
    
    //check if a collision (tap) occured
    for (Sprite *sprite in self.level.spritesArray)
    {
        //just debug output
//        NSLog(@"Bounding box: x=%f, y=%f, width=%f, height=%f", sprite.boundingBox.origin.x, 
//              sprite.boundingBox.origin.y, 
//              sprite.boundingBox.size.width, 
//              sprite.boundingBox.size.height);
//        NSLog(@"Tap rect: x=%f, y=%f, width=%f, height=%f", tapRect.origin.x, 
//              tapRect.origin.y, 
//              tapRect.size.width, 
//              tapRect.size.height);
        
        if(CGRectIntersectsRect(sprite.boundingBox, tapRect) && [sprite getZIndex] >= zIndex)
        {
            zIndex = [sprite getZIndex];
            foregroundSprite = sprite;
        }
    }
    
    NSLog(@"User tapped sprite: %@", foregroundSprite.name);
    NSString *message = [NSString stringWithFormat:@"User tapped: %@", foregroundSprite.name];
    
    //diiiirty...
    /*for (WhenScript *whenScript in self.level.whenScriptsArray)
    {
        for (Brick *brick in whenScript.bricksArray)
        {
            if (brick.sprite == foregroundSprite)
            {
                
                [brick perform];

            }
        }
    }*/
    
    [foregroundSprite touch:kTouchActionTap];
    
    
    //just for debug purposes
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    //[alert show];
    
    
}

#pragma mark - SpriteManagerDelegate
-(void)bringToFrontSprite:(Sprite *)sprite
{
    // TODO: CHANGE THIS ASAP!!!
    NSMutableArray *sprites = [self.level.spritesArray mutableCopy];
    [sprites removeObject:sprite];
    [sprites addObject:sprite];
    self.level.spritesArray = [NSArray arrayWithArray:sprites];
}

@end
