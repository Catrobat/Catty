//
//  StageViewController.m
//  Catty
//
//  Created by Mattias Rauter on 03.04.13.
//
//

#import "StageViewController.h"

@interface StageViewController ()

@property (nonatomic, assign) BOOL firstDrawing;

@end

@implementation StageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.firstDrawing = YES;

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
        Sparrow.stage.width = 500;     // = XML-Project-width
        Sparrow.stage.height = 800;     // = XML-Project-heigth
        self.firstDrawing = NO;
        
        self.view.frame = CGRectMake(100,100,200,200);  // STAGE!!!

    }
}
@end
