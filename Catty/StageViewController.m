//
//  StageViewController.m
//  Catty
//
//  Created by Mattias Rauter on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "StageViewController.h"
#import "Level.h"
#import "Sprite.h"
#import "LevelLoadingInfo.h"
#import "RetailParser.h"
#import "Brick.h"
#import "Script.h"

@interface StageViewController ()

@property (strong, nonatomic) Level *level;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) NSMutableArray *soundsArray;
@property (strong, nonatomic) NSMutableDictionary *soundsDict;

@end


@implementation StageViewController


@synthesize context = _context;
@synthesize effect = _effect;
@synthesize level = _level;

@synthesize levelLoadingInfo = _levelLoadingInfo;
@synthesize soundsDict = _soundsDict;


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
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.height, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];

    
    // load level here!
    [self loadLevel];
    [self startLevel];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
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


#pragma custom Getter/Setter

- (NSMutableArray*)soundsArray
{
    if (_soundsArray == nil)
        _soundsArray = [[NSMutableArray alloc] init];
    
    return _soundsArray;
}

- (NSMutableDictionary*)soundsDict;
{
    if (_soundsDict == nil)
        _soundsDict = [[NSMutableDictionary alloc] init];
    
    return _soundsDict;
}


#pragma mark - instance methods
- (void)startLevel
{
    for (Sprite *sprite in self.level.spritesArray)
    {
        [sprite start];
    }
}

- (void)loadLevel
{
    NSLog(@"Try to load project '%@'", self.levelLoadingInfo.visibleName);
    NSLog(@"Path: %@", self.levelLoadingInfo.basePath);
    
    NSString *xmlPath = [NSString stringWithFormat:@"%@projectcode.xml", self.levelLoadingInfo.basePath];       // TODO: change const string!!!

    NSLog(@"XML-Path: %@", xmlPath);
    
    RetailParser *parser = [[RetailParser alloc]init];
    self.level = [parser generateObjectForLevel:xmlPath];
    
    //setting effect
    for (Sprite *sprite in self.level.spritesArray)
    {
        sprite.effect = self.effect;
        sprite.spriteManagerDelegate = self;
        sprite.projectPath = self.levelLoadingInfo.basePath;
        
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
}







#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    
    //glClearColor(1, 1, 1, 1);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f); //black glkit view bg color
    
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (Sprite *sprite in self.level.spritesArray)
    {
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
//    float zIndex = 0;
    Sprite *foregroundSprite = nil;
    
    //check if a collision (tap) occured
    for (Sprite *sprite in self.level.spritesArray)
    {

        
        if(CGRectIntersectsRect(sprite.boundingBox, tapRect))// && [sprite getZIndex] >= zIndex)    // order in array is sprite-z-index
        {
//            zIndex = [sprite getZIndex];
            foregroundSprite = sprite;
        }
    }
    
    NSLog(@"User tapped sprite: %@", foregroundSprite.name);
    [foregroundSprite touch:kTouchActionTap];
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

-(void)bringNStepsBackSprite:(Sprite *)sprite numberOfSteps:(int)n
{
    NSMutableArray *sprites = [self.level.spritesArray mutableCopy];
    
    int oldIndex = [sprites indexOfObject:sprite];
    [sprites removeObject:sprite];
    
    int newIndex = oldIndex - n;
    if (newIndex < 1)
        newIndex = 1;
    if (newIndex >= [sprites count])    // negative n-value
        newIndex = [sprites count] - 1;
    
    [sprites insertObject:sprite atIndex:newIndex];
    
    self.level.spritesArray = [NSArray arrayWithArray:sprites];
}


-(void)addSound:(AVAudioPlayer *)sound forSprite:(Sprite*)sprite
{
    
    NSMutableArray* array = [self.soundsDict objectForKey:sprite.name];
    if(array == nil)
        array = [[NSMutableArray alloc] init];
    [array addObject:sound];
    
    [self.soundsDict setObject:array forKey:sprite.name];
    //[self.soundsArray addObject:sound];
    sound.delegate = self;
    [sound play];
}

-(void)stopAllSounds
{
//    for(AVAudioPlayer* player in self.soundsArray)
//    {
//        [player stop];
//    }
    
    for(NSString* key in self.soundsDict)
    {
        NSMutableArray* array = [self.soundsDict objectForKey:key];
        for(AVAudioPlayer* player in array)
        {
            [player stop];
        }

    }
    
    [self.soundsDict removeAllObjects];
}

-(void)setVolumeTo:(float)volume forSprite:(Sprite *)sprite
{
    NSMutableArray* array = [self.soundsDict objectForKey:sprite.name];
    for(AVAudioPlayer* player in array)
    {
        player.volume = volume;
    }
}

-(void)changeVolumeBy:(float)percent forSprite:(Sprite *)sprite
{
    
    NSMutableArray* array = [self.soundsDict objectForKey:sprite.name];
    for(AVAudioPlayer* player in array)
    {
        player.volume += percent;
    }
    
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Size: %d", [self.soundsArray count]);
    [_soundsArray removeObject:player];
    NSLog(@"Size: %d", [self.soundsArray count]);
    
}




// back button on view
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
