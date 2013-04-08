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
#import "ProgramLoadingInfo.h"
#import "Util.h"
#import "ProgramDefines.h"
#import "TestParser.h"

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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [Util setLastProgram:self.programLoadingInfo.visibleName];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 7.0f, 33.0f, 44.0f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* backImage = [UIImage imageNamed:@"back"];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [self.navigationController.view.superview addSubview:backButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        
        // just for test parser
        TestParser *testparser = [[TestParser alloc] init];
        Program *program = [testparser generateDebugProject_nextCostume];
        self.projectSize = CGSizeMake(program.header.screenWidth.floatValue, program.header.screenHeight.floatValue); // (normally set in loadProgram)
        
        //    TestParser *testparser = [[TestParser alloc]init];
        //    projectName = @"defaultProject";
        //    self.level = [testparser generateDebugLevel_GlideTo];
        //    self.level = [testparser generateDebugLevel_nextCostume];
        //    self.level = [testparser generateDebugLevel_HideShow];
        //    self.level = [testparser generateDebugLevel_SetXY];
        //    self.level = [testparser generateDebugLevel_broadcast];
        //    self.level = [testparser generateDebugLevel_broadcastWait];
        //    self.level = [testparser generateDebugLevel_comeToFront];
        //    self.level = [testparser generateDebugLevel_changeSizeByN];
        //    self.level = [testparser generateDebugLevel_parallelScripts];
        //    self.level = [testparser generateDebugLevel_loops];
        //    self.level = [testparser generateDebugLevel_rotate];
        //    self.level = [testparser generateDebugLevel_rotateFullCircle];
        //    self.level = [testparser generateDebugLevel_rotateAndMove];
        
        
        // parse Program
        Stage *stage = nil;
        //Program *program = [self loadProgram];
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
        self.navigationController.view.frame = CGRectMake(xOffset, yOffset, width, height);
        
        Sparrow.stage.color = 0xFF0000;

        self.firstDrawing = NO;
        
                
//        stage.pivotX = Sparrow.stage.width  / 2.0f;
//        stage.pivotY = Sparrow.stage.height / 2.0f;
//        stage.x = Sparrow.stage.width  / 2.0f;
//        stage.y = Sparrow.stage.height / 2.0f;
        
        
        [stage start];
    }
}


- (Program*)loadProgram
{
    NSDebug(@"Try to load project '%@'", self.programLoadingInfo.visibleName);
    NSLog(@"Path: %@", self.programLoadingInfo.basePath);
    

    NSString *xmlPath = [NSString stringWithFormat:@"%@", self.programLoadingInfo.basePath];
    
    NSDebug(@"XML-Path: %@", xmlPath);

    Parser *parser = [[Parser alloc]init];
    Program *program = [parser generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];
                        
    if(!program) {
        NSLog(@"Program could not be loaded!");
        abort();
    }

    NSLog(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    self.projectSize = CGSizeMake(program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    //setting effect
    for (SpriteObject *sprite in program.objectList)
    {
        sprite.spriteManagerDelegate = self;
        sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
        sprite.projectPath = xmlPath;   //self.levelLoadingInfo.basePath;

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


- (void)backButtonPressed:(UIButton *)sender
{
    self.navigationController.view.frame = [[UIScreen mainScreen] applicationFrame];
    [sender removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];

}



@end
