/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "TextInputViewController.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatUISlider.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@interface TextInputViewController () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIPickerView *sizePickerView;
@property (nonatomic,strong) UIPickerView *fontPickerView;
@property (nonatomic,strong) UIButton *boldButton;
@property (nonatomic,strong) UIButton *italicButton;
@property (nonatomic,strong) UIButton *underlineButton;
@property (nonatomic,strong) NSMutableArray *sizePickerData;
@property (nonatomic,strong) NSMutableArray *fontPickerData;
@property (nonatomic,assign) NSInteger selectedRow;
@end

@implementation TextInputViewController

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
    [self setupView];
    [self setupPickerViews];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.toolBar.frame.size.height);
    self.toolBar.tintColor = [UIColor navTintColor];
    self.toolBar.barTintColor = UIColor.navBarColor;
    self.textField.text = self.text;
    if (self.fontSize == 40) {
        [self.sizePickerView selectRow:0 inComponent:0 animated:NO];
    } else if (self.fontSize == 60) {
        [self.sizePickerView selectRow:1 inComponent:0 animated:NO];
    } else if (self.fontSize == 80) {
        [self.sizePickerView selectRow:2 inComponent:0 animated:NO];
    }
    
    if (self.fontType == 0) {
        [self.fontPickerView selectRow:0 inComponent:0 animated:NO];
    } else if (self.fontType == 1) {
        [self.fontPickerView selectRow:1 inComponent:0 animated:NO];
    } else if (self.fontType == 2) {
        [self.fontPickerView selectRow:2 inComponent:0 animated:NO];
    }
    
    self.selectedRow = self.fontType;
    
    self.toolBar.translucent = false;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, statusBarHeight)];
    statusBarView.backgroundColor  =  UIColor.navBarColor;
    [self.view addSubview:statusBarView];
}

- (void)setupView
{
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.toolBar.frame) + 30, self.view.frame.size.width-40, self.view.frame.size.height * 0.25)];
    self.textField.textColor = [UIColor textTintColor];
    self.textField.layer.cornerRadius=0.0f;
    self.textField.layer.masksToBounds=YES;
    self.textField.layer.borderColor=[[UIColor globalTintColor]CGColor];
    self.textField.layer.borderWidth= 1.0f;
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [self.textField becomeFirstResponder];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.toolBar.frame) + 10, 100, 20)];
    textLabel.text = kLocalizedPaintText;
    textLabel.textColor = [UIColor globalTintColor];
    
    
    UILabel *attributesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height * 0.25 + 30 + CGRectGetMaxY(self.toolBar.frame), 100, 20)];
    attributesLabel.text = kLocalizedPaintAttributes;
    attributesLabel.textColor = [UIColor globalTintColor];
    
    
    self.fontPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height * 0.25 + 40 + CGRectGetMaxY(self.toolBar.frame), (self.view.frame.size.width-40) / 2.0 - 5, 100)];
    self.sizePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(20+(self.view.frame.size.width-40) / 2.0 + 5 , self.view.frame.size.height * 0.25 + 40 + CGRectGetMaxY(self.toolBar.frame), (self.view.frame.size.width-40) / 2.0 - 5, 100)];

    self.boldButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.boldButton.frame = CGRectMake(20, self.fontPickerView.frame.origin.y + self.fontPickerView.frame.size.height + 30, 100, 20);
    self.boldButton.tintColor = [UIColor globalTintColor];
    [self.boldButton setTitle:kLocalizedPaintBold forState:UIControlStateNormal];
    [self.boldButton addTarget:self action:@selector(boldAction) forControlEvents:UIControlEventTouchUpInside];
    _boldButton.selected = self.bold;
    
    self.italicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.italicButton.frame = CGRectMake(self.view.frame.size.width / 2 - 50, self.fontPickerView.frame.origin.y + self.fontPickerView.frame.size.height + 30, 100, 20);
    self.italicButton.tintColor = [UIColor globalTintColor];
    [self.italicButton setTitle:kLocalizedPaintItalic forState:UIControlStateNormal];
    [self.italicButton addTarget:self action:@selector(italicAction) forControlEvents:UIControlEventTouchUpInside];
    self.italicButton.selected = self.italic;
    
    self.underlineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.underlineButton.frame = CGRectMake(self.view.frame.size.width - 120, self.fontPickerView.frame.origin.y + self.fontPickerView.frame.size.height + 30, 100, 20);
    self.underlineButton.tintColor = [UIColor globalTintColor];
    [self.underlineButton setTitle:kLocalizedPaintUnderline forState:UIControlStateNormal];
    [self.underlineButton addTarget:self action:@selector(underlineAction) forControlEvents:UIControlEventTouchUpInside];
    self.underlineButton.selected = self.underline;
    

    [self.view addSubview:self.textField];
    [self.view addSubview:self.fontPickerView];
    [self.view addSubview:self.sizePickerView];
    [self.view addSubview:textLabel];
    [self.view addSubview:attributesLabel];
    [self.view addSubview:self.boldButton];
    [self.view addSubview:self.italicButton];
    [self.view addSubview:self.underlineButton];
}

- (void) setupPickerViews
{

    self.fontPickerView.delegate = self;
    self.fontPickerView.dataSource = self;
    self.fontPickerView.tintColor = [UIColor globalTintColor];
    self.sizePickerView.delegate = self;
    self.sizePickerView.dataSource = self;
    self.sizePickerView.tintColor = [UIColor globalTintColor];
    self.sizePickerData = [[NSMutableArray alloc] initWithObjects:@"40",@"60",@"80",@"100",@"120",nil];
    self.fontPickerData = [[NSMutableArray alloc] initWithObjects:@"Standard",@"Serif",@"SanSerif", nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark PickerView

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.fontPickerView) {
        return self.fontPickerData.count;
    } else {
        return self.sizePickerData.count;
    }
}


-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";

    if (pickerView == self.fontPickerView) {
        title =  self.fontPickerData[row];
    } else {
        title =  self.sizePickerData[row];
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor globalTintColor]}];
    
    return attString;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.fontPickerView) {
        [self fontSelected:row];
        self.selectedRow = row;
    } else {
        NSString *sizeString = self.sizePickerData[row];
        self.fontSize = sizeString.integerValue;
    }
}


-(void)fontSelected:(NSInteger)row
{
    if (row == 0) {
        self.fontString = @"Standard";
        self.fontType = 0;
    } else if (row == 1) {
        if (self.bold && !self.italic) {
            self.fontString = @"TimesNewRomanPS-BoldMT";
        } else if (self.italic && !self.bold) {
            self.fontString = @"TimesNewRomanPS-ItalicMT";
        } else if (self.italic && self.bold) {
            self.fontString = @"TimesNewRomanPS-BoldItalicMT";
        } else{
            self.fontString = @"TimesNewRomanPSMT";
        }
        self.fontType = 1;
    } else if (row == 2) {
        if (self.bold && !self.italic) {
            self.fontString = @"Arial-BoldMT";
        } else if (self.italic && !self.bold) {
            self.fontString = @"Arial-ItalicMT";
        } else if (self.italic && self.bold) {
            self.fontString = @"Arial-BoldItalicMT";
        } else{
            self.fontString = @"ArialMT";
        }
        self.fontType = 2;
    }
}

-(void)boldAction{
    self.bold = !self.bold;
    self.boldButton.selected = self.bold;
    [self fontSelected:self.selectedRow];
}

-(void)italicAction{
    self.italic = !self.italic;
    self.italicButton.selected = self.italic;
    [self fontSelected:self.selectedRow];
}

-(void)underlineAction{
    self.underline = !self.underline;
    self.underlineButton.selected = self.underline;
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
    if ([self.textField.text  isEqual: @""]) {
        [Util alertWithText:kLocalizedPaintTextAlert];
        return;
    }
    self.text = self.textField.text;
    NSMutableDictionary *dict;
    if ([self.fontString isEqualToString:@"Standard"]) {
        if (self.bold && !self.italic) {
            dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:self.fontSize], NSFontAttributeName,
                    [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
        } else if (self.italic && !self.bold) {
            dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont italicSystemFontOfSize:self.fontSize], NSFontAttributeName,
                    [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
        } else if (self.italic && self.bold) {
            dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.fontSize], NSFontAttributeName,
                    [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
        } else{
            dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.fontSize], NSFontAttributeName,
                    [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
        }
       
    } else {
        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [UIFont fontWithName:self.fontString size:self.fontSize], NSFontAttributeName,
                               [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    }
    
    if (self.underline) {
        [dict setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    }
    

    
    self.fontDictionary = dict;
    NSDictionary *saveDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.bold],@"Bold",[NSNumber numberWithBool:self.italic],@"Italic",[NSNumber numberWithBool:self.underline],@"Underline",[NSNumber numberWithInteger:self.fontSize],@"Size",[NSNumber numberWithInteger:self.fontType],@"Font", nil];
    [self.delegate closeTextInput:self andDictionary:saveDict];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self.delegate closeTextInput:self andDictionary:nil];
}

@end
