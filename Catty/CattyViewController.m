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
    self.preferredFramesPerSecond = 30; // find appropriate value (30 is default)...a constant would be nice ;)
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 320, 0, 480, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];                                                               
    [self.view addGestureRecognizer:tapRecognizer];
    
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
    for (Brick *brick in script.bricksArray) {
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
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (Sprite *sprite in self.level.spritesArray)
    {
        //NSLog(@"render sprite <%@> at position %g / %g", sprite.name, sprite.position.x, sprite.position.y);
        [sprite render];
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
