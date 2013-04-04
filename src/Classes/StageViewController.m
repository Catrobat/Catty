//
//  StageViewController.m
//  Catty
//
//  Created by Mattias Rauter on 03.04.13.
//
//

#import "StageViewController.h"
#import "Parser.h"
#import "Program.h"
#import "SpriteObject.h"
#import "BroadcastWaitHandler.h"
#import "Brick.h"
#import "Script.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "BroadcastScript.h"
#import "Stage.h"

@interface StageViewController () <SpriteManagerDelegate>

@property (nonatomic, assign) BOOL firstDrawing;
@property (nonatomic, assign) CGSize projectSize;
@property (nonatomic, strong) BroadcastWaitHandler *broadcastWaitHandler;
@end

@implementation StageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.firstDrawing = YES;
        self.broadcastWaitHandler = [[BroadcastWaitHandler alloc]init];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [super glkView:view drawInRect:rect];
    if (self.firstDrawing) {
        
        // parse Program
        Stage *stage = nil;
        Program *program = [self loadProgram];
        if ([self.root isKindOfClass:[Stage class]]) {
            stage = (Stage*)self.root;
            stage.program = program;
        } else {
            abort();
        }
        
                
        
        float screenWidth  = [UIScreen mainScreen].bounds.size.width;
        float screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        
        float scaleFactor = 1.0f;
        if (self.projectSize.width > 0 && self.projectSize.height > 0) {
            float scaleX = screenWidth  / self.projectSize.width;
            float scaleY = screenHeight / self.projectSize.height;
            scaleFactor = MIN(scaleX, scaleY);
        }
        
        int xOffset = (screenWidth  - (self.projectSize.width  * scaleFactor)) / 2.0f;
        int yOffset = (screenHeight - (self.projectSize.height * scaleFactor)) / 2.0f;
        

        
        NSLog(@"Scale screen size:");
        NSLog(@"  Device:    %f / %f    (%f)", screenWidth, screenHeight, screenWidth/screenHeight);
        NSLog(@"  Project:   %f / %f    (%f)", self.projectSize.width, self.projectSize.height, self.projectSize.width/self.projectSize.height);
        NSLog(@"  Scale-Factor: %f",   scaleFactor);
        NSLog(@"  Offset:    %d / %d", xOffset, yOffset);
        
        float width  = screenWidth  - (2 * xOffset);
        float height = screenHeight - (2 * yOffset);
        
        
        Sparrow.stage.width  = self.projectSize.width;      // = XML-Project-width
        Sparrow.stage.height = self.projectSize.height;     // = XML-Project-heigth
        self.view.frame = CGRectMake(xOffset, yOffset, width, height);  // STAGE!!! TODO: calculat ratio and offset
        
        Sparrow.stage.color = 0xFF0000;

        self.firstDrawing = NO;
        
        [stage start];
    }
}


- (Program*)loadProgram
{
//    NSLog(@"Try to load project '%@'", self.levelLoadingInfo.visibleName);
//    NSLog(@"Path: %@", self.levelLoadingInfo.basePath);
    

//    NSString *xmlPath = [NSString stringWithFormat:@"%@code.xml", self.levelLoadingInfo.basePath];       // TODO: change const string!!!
    NSString *xmlPath = @"/Users/Mattias/Library/Application Support/iPhone Simulator/6.1/Applications/28446E58-9C81-4FFF-B4CB-AE6D11695142/Documents/levels/Mein erstes Projekt/code.xml";
    
    NSLog(@"XML-Path: %@", xmlPath);

    Parser *parser = [[Parser alloc]init];
    Program *program = [parser generateObjectForLevel:xmlPath];

    NSLog(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    self.projectSize = CGSizeMake(program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    //setting effect
    for (SpriteObject *sprite in program.objectList)
    {
        sprite.spriteManagerDelegate = self;
        sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
        sprite.projectPath = xmlPath;   //self.levelLoadingInfo.basePath;
        [sprite setProjectResolution:self.projectSize];

        // TODO: change!
        for (Script *script in sprite.scriptList) {
            for (Brick *brick in script.brickList) {
                brick.object = sprite;
            }
        }




        // debug:
        NSLog(@"----------------------");
        NSLog(@"Sprite: %@", sprite.name);
        NSLog(@" ");
        NSLog(@"StartScript:");
        for (Script *script in sprite.scriptList) {
            if ([script isKindOfClass:[Startscript class]]) {
                for (Brick *brick in [script getAllBricks]) {
                    NSLog(@"  %@", [brick description]);
                }
            }
        }
        for (Script *script in sprite.scriptList) {
            if ([script isKindOfClass:[Whenscript class]]) {
                NSLog(@" ");
                NSLog(@"WhenScript:");
                for (Brick *brick in [script getAllBricks]) {
                    NSLog(@"  %@", [brick description]);
                }
            }
        }
        for (Script *script in sprite.scriptList) {
            if ([script isKindOfClass:[Broadcastscript class]]) {
                NSLog(@" ");
                NSLog(@"BroadcastScript:");
                for (Brick *brick in [script getAllBricks]) {
                    NSLog(@"  %@", [brick description]);
                }
            }
        }
    }
    return program;
}

@end
