//
//  StartScreenViewController.m
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "StartScreenViewController.h"
#import "ImageSprite.h"

@interface StartScreenViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;


//temp
@property (nonatomic, strong) ImageSprite *sprite;
@end

@implementation StartScreenViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize sprite = _sprite;

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
    
    
    ImageSprite *sprite = [[ImageSprite alloc] initWithEffect:self.effect];
    self.sprite = sprite;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [self.sprite render];
    
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    [self.sprite update:self.timeSinceLastUpdate];
}

@end
