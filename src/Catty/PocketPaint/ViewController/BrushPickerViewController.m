/**
 *  Copyright (C) 2010-2016 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "BrushPickerViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "PaintViewController.h"
#import "UIImage+Rotate.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatUISlider.h"

@interface BrushPickerViewController ()
@property (nonatomic,strong)UIImageView *brushView;
@property (nonatomic,strong)CatrobatUISlider *brushSlider;
@property (nonatomic,strong)UILabel *thicknessLabel;
@property (nonatomic,strong)UISegmentedControl *brushEndingControl;

@end

@implementation BrushPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andController:(PaintViewController *)controller
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.frame = frame;
        self.brush = controller.thickness;
        self.brushEnding = controller.ending;
        self.color =[UIColor colorWithRed:controller.red green:controller.green blue:controller.blue alpha:controller.opacity];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBar];
    self.view.backgroundColor = [UIColor backgroundColor];
    
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBrushPreview];
    [self setupSegmentedControl];
    [self setupBrushSlider];
}

- (void)setupToolBar
{
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self.view addSubview:self.toolBar];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:kLocalizedPaintWidth style:UIBarButtonItemStylePlain target:nil action:nil];
    [title setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor navTintColor], NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} forState:UIControlStateDisabled];
    [title setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor navTintColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]} forState:UIControlStateNormal];
    title.enabled = NO;
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolBar setItems:@[title,flexibleItem, self.doneButton]];
    self.toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.toolBar.frame.size.height);
    self.toolBar.tintColor = [UIColor navTintColor];
    self.toolBar.barTintColor = UIColor.navBarColor;
    
    
}


- (void)setupSegmentedControl
{
    NSArray *mySegments = [[NSArray alloc] initWithObjects: kLocalizedPaintRound,
                           kLocalizedPaintSquare, nil];
    self.brushEndingControl = [[UISegmentedControl alloc] initWithItems:mySegments];
    CGFloat width = self.view.frame.size.width-140.0f;
    self.brushEndingControl.frame =CGRectMake(self.view.center.x-width/2.0f, self.view.frame.size.height*0.7f, width, self.view.frame.size.height*0.1f);
    self.brushEndingControl.tintColor = [UIColor globalTintColor];
    switch (self.brushEnding) {
        case Round:
            self.brushEndingControl.selectedSegmentIndex = 0;
            break;
        case Square:
            self.brushEndingControl.selectedSegmentIndex = 1;
            break;
        default:
            break;
    }
    
    [self.brushEndingControl addTarget:self
                                action:@selector(whichBrushEnding:)
                      forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.brushEndingControl];
}

- (void)setupBrushSlider
{
    self.brushSlider = [[CatrobatUISlider alloc] init];
    self.brushSlider.frame =CGRectMake(self.view.frame.size.width*0.25f, self.view.frame.size.height*0.5f, self.view.frame.size.width/2, 20);
    [self.brushSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.brushSlider setBackgroundColor:[UIColor clearColor]];
    self.brushSlider.minimumValue = 1.0f;
    self.brushSlider.maximumValue = 75.0f;
    self.brushSlider.continuous = YES;
    self.brushSlider.value = self.brush;
    self.brushSlider.tintColor = [UIColor globalTintColor];
    //  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.25f, self.view.frame.size.height*0.35f, 40, 10)];
    //  label.text = kLocalizedPaintWidth;
    //  [label sizeToFit];
    //  label.textColor = [UIColor globalTintColor];
    self.thicknessLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.brushSlider.frame.origin.x+self.brushSlider.frame.size.width +10, self.view.frame.size.height*0.5f-7, 40, 10)];
    self.thicknessLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.brush)];
    self.thicknessLabel.textColor = [UIColor globalTintColor];
    [self.thicknessLabel sizeToFit];
    
    //  [self.view addSubview:label];
    [self.view addSubview:self.thicknessLabel];
    [self.view addSubview:self.brushSlider];
    
}

- (void)setupBrushPreview
{
    self.brushView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-60, 20, 125, 125)];
    UIGraphicsBeginImageContext(self.brushView.frame.size);
    switch (self.brushEnding) {
        case Round:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
            break;
        case Square:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
            break;
        default:
            break;
    }
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.color.CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.brushView.image = [image imageRotatedByDegrees:45];
    
    UIGraphicsEndImageContext();
    [self.view addSubview:self.brushView];
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)whichBrushEnding:(UISegmentedControl *)paramSender
{
    NSInteger selectedIndex = [paramSender selectedSegmentIndex];
    switch (selectedIndex) {
        case 0:
            self.brushEnding = Round;
            break;
        case 1:
            self.brushEnding = Square;
            break;
        default:
            break;
    }
    
    
    UIGraphicsBeginImageContext(self.brushView.frame.size);
    switch (self.brushEnding) {
        case Round:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
            break;
        case Square:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
            break;
        default:
            break;
    }
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.color.CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.brushView.image = [image imageRotatedByDegrees:45];
    UIGraphicsEndImageContext();
    
}

- (void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    float value = slider.value;
    self.thicknessLabel.text = [NSString stringWithFormat:@"%.0f",roundf(value)];
    [self.thicknessLabel sizeToFit];
    
    self.brush = roundf(value);
    
    UIGraphicsBeginImageContext(self.brushView.frame.size);
    switch (self.brushEnding) {
        case Round:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapRound);
            break;
        case Square:
            CGContextSetLineCap(UIGraphicsGetCurrentContext(),kCGLineCapSquare);
            break;
        default:
            break;
    }
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.color.CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),55, 55);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.brushView.image = [image imageRotatedByDegrees:45];
    UIGraphicsEndImageContext();
    
    
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    [self.delegate closeBrushPicker:self];
}


@end
