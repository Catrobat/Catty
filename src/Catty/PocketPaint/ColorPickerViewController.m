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

#import "ColorPickerViewController.h"
#import "NKOColorPickerView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import "CatrobatUISlider.h"

@interface ColorPickerViewController ()
@property (nonatomic,strong)UISegmentedControl *viewChanger;
@property (nonatomic,strong)UIView *rgbaView;
@property (nonatomic,strong)UIView *rgbaSliderView;
@property (nonatomic,strong)UIView *standardColors;
@property (nonatomic,strong)UIImageView *brushView;
@property (nonatomic,strong)CatrobatUISlider *redSlider;
@property (nonatomic,strong)UILabel *redLabel;
@property (nonatomic,strong)CatrobatUISlider *greenSlider;
@property (nonatomic,strong)UILabel *greenLabel;
@property (nonatomic,strong)CatrobatUISlider *blueSlider;
@property (nonatomic,strong)UILabel *blueLabel;
@property (nonatomic,strong)CatrobatUISlider *opacitySlider;
@property (nonatomic,strong)UILabel *opacityLabel;
@property (nonatomic,strong)NSMutableArray *colorArray;
@property (nonatomic,strong)NKOColorPickerView *colorPicker;
@end

@implementation ColorPickerViewController

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
    // Do any additional setup after loading the view.
  [self setupViews];
  [self setupStandardColorsView];
  [self setupRGBAView];
  [self setupBrushPreview];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
  self.view.backgroundColor = [UIColor backgroundColor];
    self.toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.toolBar.frame.size.height);
    self.toolBar.tintColor = [UIColor navTintColor];
  self.toolBar.barTintColor = UIColor.navBarColor;
}

- (void)setupViews
{
  NSArray *itemArray = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"sliderColors"],
                        [UIImage imageNamed:@"standardColors"], nil];
  self.viewChanger = [[UISegmentedControl alloc] initWithItems:itemArray];
  self.viewChanger.frame =CGRectMake(0, self.toolBar.frame.size.height, self.view.frame.size.width, 40);
  self.viewChanger.selectedSegmentIndex = 0;
  self.viewChanger.layer.cornerRadius = 0.0;
  self.viewChanger.layer.borderColor = [UIColor globalTintColor].CGColor;
  self.viewChanger.layer.borderWidth = 1.0f;
  self.viewChanger.layer.masksToBounds = YES;
  self.viewChanger.tintColor = [UIColor globalTintColor];
  [self.viewChanger addTarget:self
                              action:@selector(viewChanged:)
                    forControlEvents:UIControlEventValueChanged];

  [self.view addSubview:self.viewChanger];
  self.rgbaView = [[UIView alloc] initWithFrame:CGRectMake(0, 80,self.view.frame.size.width , self.view.frame.size.height *0.45f)];
  self.rgbaSliderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height *0.55f,self.view.frame.size.width , self.view.frame.size.height *0.55f)];
  self.standardColors =[[UIView alloc] initWithFrame:CGRectMake(0, 60,self.view.frame.size.width , self.view.frame.size.height)];
  [self.view addSubview:self.rgbaView];
  [self.view addSubview:self.rgbaSliderView];
  [self.view addSubview:self.standardColors];
  self.standardColors.hidden = YES;
}

- (void)setupStandardColorsView
{
  self.colorArray = [NSMutableArray array];
    self.standardColors.frame = CGRectMake(0, self.view.frame.size.height * 0.3f, self.view.frame.size.width, self.view.frame.size.height);
    int colorCount = 20;
    for (int i = 0; i < colorCount; i++) {
        if (i<4) {
            UIColor *color = [UIColor colorWithWhite:i/(float)(colorCount - (colorCount-4+1)) alpha:1.0];
            [self.colorArray addObject:color];
        } else {
            UIColor *color = [UIColor colorWithHue:(i-4) / (float)colorCount saturation:1.0 brightness:1.0 alpha:1.0];
            [self.colorArray addObject:color];
        }
        
    }

    if (self.view.frame.size.height > self.view.frame.size.width) {
        for (int i = 0; i < colorCount && i < self.colorArray.count; i++) {
            CALayer *layer = [CALayer layer];
            layer.cornerRadius = 6.0;
            UIColor *color = [self.colorArray objectAtIndex:i];
            layer.backgroundColor = color.CGColor;
            CGFloat width = self.view.frame.size.width;
            width = (width / 4.0f)-10.0f;
            CGFloat factor = 40.0f / 70.0f;
            int column = i % 4;
            int row = i / 4;
            layer.frame = CGRectMake(8 + (column * (width +8)), 8 + row * (width*factor+8), width, width*factor);
            layer.borderColor = [UIColor globalTintColor].CGColor;
            layer.borderWidth = 1.0f;
            [self.standardColors.layer addSublayer:layer];
        }

    } else {
        for (int i = 0; i < colorCount && i < self.colorArray.count; i++) {
            CALayer *layer = [CALayer layer];
            layer.cornerRadius = 6.0;
            UIColor *color = [self.colorArray objectAtIndex:i];
            layer.backgroundColor = color.CGColor;
            CGFloat width = self.view.frame.size.width;
            width = (width / 6.0f)-10.0f;
            CGFloat factor = 40.0f / 70.0f;
            int column = i % 6;
            int row = i / 6;
            layer.frame = CGRectMake(8 + (column * (width +8)), 8 + row * (width*factor+8), width,width*factor);
            layer.borderColor = [UIColor globalTintColor].CGColor;
            layer.borderWidth = 1.0f;
            [self.standardColors.layer addSublayer:layer];
        }
    }
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
  [self.standardColors addGestureRecognizer:recognizer];

}

- (void)setupRGBAView
{
  [self setupRedSlider];
  [self setupGreenSlider];
  [self setupBlueSlider];
  [self setupOpacitySlider];
  [self setupPicker];
}

- (void)setupRedSlider
{
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1f, self.view.frame.size.height*0.05f-7, 40, 10)];
  label.text = kLocalizedPaintRed;
  label.textColor = [UIColor redColor];
  [label sizeToFit];
  self.redSlider = [[CatrobatUISlider alloc] init];
  self.redSlider.frame =CGRectMake(self.view.frame.size.width*0.3f, self.view.frame.size.height*0.05f, 150, 5);
  [self.redSlider addTarget:self action:@selector(redAction:) forControlEvents:UIControlEventValueChanged];
  [self.redSlider setBackgroundColor:[UIColor clearColor]];
  self.redSlider.minimumValue = 0.0;
  self.redSlider.maximumValue = 255.0;
  self.redSlider.continuous = YES;
  self.redSlider.value = self.red*255.0f;
  self.redSlider.tintColor = [UIColor globalTintColor];
  self.redLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.redSlider.frame.origin.x+self.redSlider.frame.size.width+20, self.view.frame.size.height*0.05f-7, 40, 10)];
  self.redLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.red*255.0f)];
  [self.redLabel sizeToFit];
  self.redLabel.textColor = [UIColor globalTintColor];
  
  
  [self.rgbaSliderView addSubview:label];
  [self.rgbaSliderView addSubview:self.redLabel];
  [self.rgbaSliderView addSubview:self.redSlider];

}

- (void)setupGreenSlider
{
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1f, self.view.frame.size.height*0.15f-7, 40, 10)];
  label.text = kLocalizedPaintGreen;
  label.textColor = [UIColor greenColor];
  [label sizeToFit];
  self.greenSlider = [[CatrobatUISlider alloc] init];
  self.greenSlider.frame =CGRectMake(self.view.frame.size.width*0.3f, self.view.frame.size.height*0.15f, 150, 5);
  [self.greenSlider addTarget:self action:@selector(greenAction:) forControlEvents:UIControlEventValueChanged];
  [self.greenSlider setBackgroundColor:[UIColor clearColor]];
  self.greenSlider.minimumValue = 0.0;
  self.greenSlider.maximumValue = 255.0;
  self.greenSlider.continuous = YES;
  self.greenSlider.value = self.green*255.0f;
  self.greenSlider.tintColor = [UIColor globalTintColor];
  self.greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.greenSlider.frame.origin.x+self.greenSlider.frame.size.width+20, self.view.frame.size.height*0.15f-7, 40, 10)];
  self.greenLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.green*255.0f)];
  [self.greenLabel sizeToFit];
  self.greenLabel.textColor = [UIColor globalTintColor];
  
  
  [self.rgbaSliderView addSubview:label];
  [self.rgbaSliderView addSubview:self.greenLabel];
  [self.rgbaSliderView addSubview:self.greenSlider];
  
}
- (void)setupBlueSlider
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1f, self.view.frame.size.height*0.25f-7, 40, 10)];
  label.text = kLocalizedPaintBlue;
  label.textColor = [UIColor blueColor];
  [label sizeToFit];
  self.blueSlider = [[CatrobatUISlider alloc] init];
  self.blueSlider.frame =CGRectMake(self.view.frame.size.width*0.3f, self.view.frame.size.height*0.25f, 150, 5);
  [self.blueSlider addTarget:self action:@selector(blueAction:) forControlEvents:UIControlEventValueChanged];
  [self.blueSlider setBackgroundColor:[UIColor clearColor]];
  self.blueSlider.minimumValue = 0.0;
  self.blueSlider.maximumValue = 255.0;
  self.blueSlider.continuous = YES;
  self.blueSlider.value = self.blue*255.0f;
  self.blueSlider.tintColor = [UIColor globalTintColor];
  self.blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.blueSlider.frame.origin.x+self.blueSlider.frame.size.width+20, self.view.frame.size.height*0.25f-7, 40, 10)];
  self.blueLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.blue*255.0f)];
  [self.blueLabel sizeToFit];
  self.blueLabel.textColor = [UIColor globalTintColor];
  
  
  [self.rgbaSliderView addSubview:label];
  [self.rgbaSliderView addSubview:self.blueLabel];
  [self.rgbaSliderView addSubview:self.blueSlider];
  
}

- (void)setupOpacitySlider
{
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1f, self.view.frame.size.height*0.35f-7, 40, 10)];
  label.text = kLocalizedPaintAlpha;
  label.textColor = [UIColor blackColor];
  [label sizeToFit];
  self.opacitySlider = [[CatrobatUISlider alloc] init];
  self.opacitySlider.frame =CGRectMake(self.view.frame.size.width*0.3f, self.view.frame.size.height*0.35f, 150, 5);
  [self.opacitySlider addTarget:self action:@selector(opacityAction:) forControlEvents:UIControlEventValueChanged];
  [self.opacitySlider setBackgroundColor:[UIColor clearColor]];
  self.opacitySlider.minimumValue = 0.0;
  self.opacitySlider.maximumValue = 255.0;
  self.opacitySlider.continuous = YES;
  self.opacitySlider.value = self.opacity*255.0f;
  self.opacitySlider.tintColor = [UIColor globalTintColor];
  self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.opacitySlider.frame.origin.x+self.opacitySlider.frame.size.width+20, self.view.frame.size.height*0.35f-7, 40, 10)];
  self.opacityLabel.text = [NSString stringWithFormat:@"%.0f%%",roundf(self.opacity*100.0f)];
  [self.opacityLabel sizeToFit];
  self.opacityLabel.textColor = [UIColor globalTintColor];
  
  
  [self.rgbaSliderView addSubview:label];
  [self.rgbaSliderView addSubview:self.opacityLabel];
  [self.rgbaSliderView addSubview:self.opacitySlider];
  
}

- (void)setupPicker
{
  NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
      //Your code handling a color change in the picker view.
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    self.red = r;
    self.green = g;
    self.blue = b;
    self.opacity = a;
    [self updatePreview];
    [self updateRGBAView];
  };
  
  self.colorPicker = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height * 0.05f, self.view.frame.size.width,self.view.frame.size.height * 0.3f) color:[UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.opacity] andDidChangeColorBlock:colorDidChangeBlock];
  [self.rgbaView addSubview:self.colorPicker];
}

- (void)setupBrushPreview
{
  self.brushView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.height * 0.05f, 87.5, self.view.frame.size.height * 0.1f, self.view.frame.size.height * 0.05f)];
  self.brushView.layer.cornerRadius = 10.0f;
  [self updatePreview];
  [self.view addSubview:self.brushView];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redAction:(id)sender
{
  UISlider *slider = (UISlider*)sender;
  float value = slider.value;
  self.redLabel.text = [NSString stringWithFormat:@"%.0f",roundf(value)];
  [self.redLabel sizeToFit];
  self.red = value/255.0f;
  [self updatePreview];
}
- (void)greenAction:(id)sender
{
  UISlider *slider = (UISlider*)sender;
  float value = slider.value;
  self.greenLabel.text = [NSString stringWithFormat:@"%.0f",roundf(value)];
  [self.greenLabel sizeToFit];
  self.green = value/255.0f;
  [self updatePreview];
}
- (void)blueAction:(id)sender
{
  UISlider *slider = (UISlider*)sender;
  float value = slider.value;
  self.blueLabel.text = [NSString stringWithFormat:@"%.0f",roundf(value)];
  [self.blueLabel sizeToFit];
  self.blue = value/255.0f;
  [self updatePreview];
}
- (void)opacityAction:(id)sender
{
  UISlider *slider = (UISlider*)sender;
  float value = slider.value;
  self.opacityLabel.text = [NSString stringWithFormat:@"%.0f%%",roundf(value)/255.0f*100.0f];
  [self.opacityLabel sizeToFit];
  self.opacity = value/255.0f;
  [self updatePreview];
}

- (void)updatePreview
{
  self.brushView.backgroundColor = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.opacity];
  [self.colorPicker setColor:[UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.opacity]];
}

- (void)viewChanged:(UISegmentedControl *)paramSender
{
  NSInteger selectedIndex = [paramSender selectedSegmentIndex];
  switch (selectedIndex) {
    case 0:
      self.rgbaView.hidden = NO;
      self.rgbaSliderView.hidden = NO;
      self.standardColors.hidden = YES;
      break;
    case 1:
      self.rgbaView.hidden = YES;
      self.rgbaSliderView.hidden = YES;
      self.standardColors.hidden = NO;
      break;
    default:
      break;
  }

}

- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
  CGPoint point = [recognizer locationInView:self.standardColors];
  CGFloat width = self.view.frame.size.width;
  width = (width / 4.0f)-10.0f;
  CGFloat factor = 40.0f / 70.0f;
  int row = (int)((point.y - 8) / ((width*factor)+8));
  int column = (int)((point.x - 8) / (width+8));
  int index = row * 4 + column;
	
	if (index < _colorArray.count) {
		UIColor *color = [_colorArray objectAtIndex:index];
    CGFloat red,green,blue,opacity;
    [color getRed:&red green:&green blue:&blue alpha:&opacity];
    self.red = red;
    self.blue = blue;
    self.green = green;
    self.opacity = opacity;
	}
  [self updatePreview];
  [self updateRGBAView];
}

- (void)updateRGBAView
{
  self.redSlider.value = self.red*255.0f;
  self.redLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.red*255.0f)];
  [self.redLabel sizeToFit];
  self.greenSlider.value = self.green*255.0f;
  self.greenLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.green*255.0f)];
  [self.greenLabel sizeToFit];
  self.blueSlider.value = self.blue*255.0f;
  self.blueLabel.text = [NSString stringWithFormat:@"%.0f",roundf(self.blue*255.0f)];
  [self.blueLabel sizeToFit];
  
//  [self resetColorPicker];
  
  [self.rgbaView setNeedsDisplay];
}

- (void)resetColorPicker
{
  NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
      //Your code handling a color change in the picker view.
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    self.red = r;
    self.green = g;
    self.blue = b;
    self.opacity = a;
    [self updatePreview];
    [self updateRGBAView];
  };
  [self.colorPicker removeFromSuperview];
  self.colorPicker = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height * 0.1f +5, self.view.frame.size.width,self.view.frame.size.height * 0.3f) color:[UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.opacity] andDidChangeColorBlock:colorDidChangeBlock];
  [self.rgbaView addSubview:self.colorPicker];
  [self.rgbaView bringSubviewToFront:self.colorPicker];
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

- (IBAction)closeAction:(UIBarButtonItem *)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self.delegate closeColorPicker:self];
}

- (BOOL)prefersStatusBarHidden { return YES; }




@end
