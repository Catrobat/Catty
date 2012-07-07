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

//debug
#import "Costume.h"

//defines
#define FRAMES_PER_SECOND 30


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
@synthesize player = _player;
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
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 320, 0, 480, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];                                                               
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    //load level before starting (this should happen BEFORE this controller is invoked
    TestParser *parser = [[TestParser alloc] init];
    parser.effect = self.effect;
    self.level = [parser generateObjectForLevel:@"dup di dup"];

    NSLog(@"%@", self.level);
    //self.player = [[SGGSprite alloc] initWithFile:@"normalcat.png" effect:self.effect];   
    
    
    Costume *newCostume1 = [[Costume alloc]init];
    newCostume1.filePath = @"normalcat.png";
    newCostume1.name = @"cat1";

    
    //self.sprite = [[Sprite alloc] initWithCostume:newCostume1 effect:self.effect];

    
    [self startLevel];
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
    for (StartScript *script in self.startScriptsArray)
    {
        NSLog(@"run start script");
        [self runScript:script];
    }
}

- (void)runScript:(Script*)script
{
    for (Brick *brick in script.bricksArray) 
    {
        if ([brick isMemberOfClass:[SetCostumeBrick class]]) 
        {
            
            NSLog(@"run SetCostumeBrick of sprite <%@>", brick.sprite.name);
            
            
            SetCostumeBrick *setCostumeBrick = (SetCostumeBrick*)brick;
            
            brick.sprite.indexOfCurrentCostumeInArray = setCostumeBrick.indexOfCostumeInArray;
            
        }// else if (brick == anotherBrickClass)... and so on...
    }
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {    
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);

    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    //NSLog(@"draw in rect...");
    
    //[self.sprite render];
    
//    for (Sprite *sprite in self.level.spritesArray)
//    {
//        //NSLog(@"render sprite <%@> at position %g / %g", sprite.name, sprite.position.x, sprite.position.y);
//        [sprite render];
//    }
    for (SGGSprite *sprite in self.level.spritesArray)
    {
        //NSLog(@"render sprite <%@> at position %g / %g", sprite.name, sprite.position.x, sprite.position.y);
        [sprite render];
    }

}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    //NSLog(@"Update...");
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
    
    //    int sizeOfSpritesArray = self.level.spritesArray.count;
    //    for (int i=sizeOfSpritesArray-1; i>=0; i--)
    //    {
    //        Sprite *sprite = [self.level.spritesArray objectAtIndex:i];
    //        
    //        if (touchLocation.x >= sprite.position.x
    //        
    //    }
    
    NSLog(@"tapped at %g / %g", touchLocation.x, touchLocation.y);
    
}


@end
