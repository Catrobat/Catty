//
//  Game.m
//  AppScaffold
//

#import "Game.h" 

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)setup;
- (void)onImageTouched:(SPTouchEvent *)event;
- (void)onResize:(SPResizeEvent *)event;

@property (nonatomic, strong) SPImage *image; // just temp

@end


// --- class implementation ------------------------------------------------------------------------

@implementation Game
{
    SPSprite *_contents;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setup
{
    // This is where the code of your game will start. 
    // In this sample, we add just a few simple elements to get a feeling about how it's done.
    
    [SPAudioEngine start];  // starts up the sound engine
    
    
    // The Application contains a very handy "Media" class which loads your texture atlas
    // and all available sound files automatically. Extend this class as you need it --
    // that way, you will be able to access your textures and sounds throughout your 
    // application, without duplicating any resources.
    
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    
    
    // Create some placeholder content: a background image, the Sparrow logo, and a text field.
    // The positions are updated when the device is rotated. To make that easy, we put all objects
    // in one sprite (_contents): it will simply be rotated to be upright when the device rotates.

    _contents = [SPSprite sprite];
    [self addChild:_contents];

    SPImage *background = [[SPImage alloc] initWithContentsOfFile:@"background.jpg"];
    [_contents addChild:background];
    
    //NSString *text = @"To find out how to create your own game out of this scaffold, "
    //                 @"have a look at the 'First Steps' section of the Sparrow website!";
    
//    SPTextField *textField = [[SPTextField alloc] initWithWidth:280 height:80 text:text];
//    textField.x = (background.width - textField.width) / 2;
//    textField.y = (background.height / 2) - 135;
//    [_contents addChild:textField];

    SPImage *image = [[SPImage alloc] initWithTexture:[Media atlasTexture:@"sparrow"]];
    image.pivotX = (int)image.width  / 2;
    image.pivotY = (int)image.height / 2;
    image.x = background.width  / 2;
    image.y = background.height / 2 + 40;
    [_contents addChild:image];
    
    self.image = image;
    
    [self updateLocations];
    
    // play a sound when the image is touched
    [image addEventListener:@selector(onImageTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    // and animate it a little
    /*SPTween *tween = [SPTween tweenWithTarget:image time:1.5 transition:SP_TRANSITION_EASE_IN_OUT];
    [tween animateProperty:@"y" targetValue:image.y + 30];
    [tween animateProperty:@"rotation" targetValue:0.1];
    tween.repeatCount = 0; // repeat indefinitely
    tween.reverse = YES;
    [Sparrow.juggler addObject:tween];*/
    

    // The controller autorotates the game to all supported device orientations. 
    // Choose the orienations you want to support in the Xcode Target Settings ("Summary"-tab).
    // To update the game content accordingly, listen to the "RESIZE" event; it is dispatched
    // to all game elements (just like an ENTER_FRAME event).
    // 
    // To force the game to start up in landscape, add the key "Initial Interface Orientation"
    // to the "App-Info.plist" file and choose any landscape orientation.
    
    //[self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
    // Per default, this project compiles as a universal application. To change that, enter the 
    // project info screen, and in the "Build"-tab, find the setting "Targeted device family".
    //
    // Now choose:  
    //   * iPhone      -> iPhone only App
    //   * iPad        -> iPad only App
    //   * iPhone/iPad -> Universal App  
    // 
    // Sparrow's minimum deployment target is iOS 5.
}

- (void)updateLocations
{
    int gameWidth  = Sparrow.stage.width;
    int gameHeight = Sparrow.stage.height;
    
    _contents.x = (int) (gameWidth  - _contents.width)  / 2;
    _contents.y = (int) (gameHeight - _contents.height) / 2;
}

- (void)onImageTouched:(SPTouchEvent *)event
{
    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    if ([touches anyObject]) {
        NSLog(@"TOUCHED");
        // TEST for resize
        //    SPTween *tween = [SPTween tweenWithTarget:self.image time:1.0f];
        //    [tween animateProperty:@"scaleX" targetValue:self.image.scaleX * 1.5];
        //    [tween animateProperty:@"scaleY" targetValue:self.image.scaleY * 1.5];
        //    tween.repeatCount = 1;
        //    [Sparrow.juggler addObject:tween];
        
        // TEST for rotation
        SPTween *tween = [SPTween tweenWithTarget:self.image time:1.0f];
        [tween animateProperty:@"rotation" targetValue:GLKMathDegreesToRadians(360.0f)];
        tween.repeatCount = 1;
        [Sparrow.juggler addObject:tween];
        
        // TEST for move
        //    SPTween *tween = [SPTween tweenWithTarget:self.image time:1.0f];
        //    [tween animateProperty:@"x" targetValue:self.image.x + 20.0f];
        //    [tween animateProperty:@"y" targetValue:self.image.y - 50.0f];
        //    tween.repeatCount = 1;
        //    [Sparrow.juggler addObject:tween];
        
        // TEST for position
        //    SPTween *tween = [SPTween tweenWithTarget:self.image time:1.0f];
        //    [tween animateProperty:@"x" targetValue:10];
        //    [tween animateProperty:@"y" targetValue:10];
        //    tween.repeatCount = 1;
        //    [Sparrow.juggler addObject:tween];
        
        // TEST for alpha
        //    SPTween *tween = [SPTween tweenWithTarget:self.image time:1.0f];
        //    [tween animateProperty:@"alpha" targetValue:0.2f];
        //    tween.repeatCount = 1;
        //    [Sparrow.juggler addObject:tween];
        
        // TEST for brightness (<100%)
        //    SPImage *image = (SPImage*)self.image;
        //    //image.color = SP_COLOR(100, 200, 255);
        //
        //    CGFloat scale = 0.5f; // MUST be <1.0 (=100%)
        //
        //    uint hexColor = image.color;
        //    uint r = (hexColor >> 16);
        //    uint g = ((hexColor << 16) >> 24);
        //    uint b = ((hexColor << 24) >> 24);
        //    NSLog(@"Color in hex: %x", hexColor);
        //    NSLog(@"R: %d", r);
        //    NSLog(@"G: %d", g);
        //    NSLog(@"B: %d", b);
        //
        //    // set color
        //    image.color = SP_COLOR(r*scale, g*scale, b*scale);
        //    NSLog(@"COLOR SET");
    }    
    
    /*NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    if ([touches anyObject]) [Media playSound:@"sound.caf"];*/
}

//- (void)onResize:(SPResizeEvent *)event
//{
//    NSLog(@"new size: %.0fx%.0f (%@)", event.width, event.height, 
//          event.isPortrait ? @"portrait" : @"landscape");
//    
//    [self updateLocations];
//}

@end
