/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "InfoPopupViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>

@interface InfoPopupViewController ()
@property (nonatomic, strong) UIView *aboutPocketCodeView;

@end

@implementation InfoPopupViewController

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
    self.view.frame = CGRectMake(0,0, 280.0f, 280.0f);
    self.view.backgroundColor = [UIColor backgroundColor];
    [self initAboutPocketCodeButton];
    
}

-(void)initAboutPocketCodeButton
{
    UIButton *aboutPocketCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [aboutPocketCode setTitle:kUIInfoPopupViewAboutPocketCode forState:UIControlStateNormal];
    [aboutPocketCode addTarget:self
                        action:@selector(aboutPocketCode)
              forControlEvents:UIControlEventTouchUpInside];
    [aboutPocketCode sizeToFit];
    aboutPocketCode.frame = CGRectMake(20, 20, aboutPocketCode.frame.size.width, aboutPocketCode.frame.size.height);
    [self.view addSubview:aboutPocketCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Button actions

- (void)aboutPocketCode
{
    //init OverlayView
    self.aboutPocketCodeView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x -20, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.aboutPocketCodeView.backgroundColor = [UIColor backgroundColor];
    self.aboutPocketCodeView.layer.cornerRadius = 15;
    self.aboutPocketCodeView.layer.masksToBounds = YES;
    
    //init header
    UILabel *aboutPocketCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 10, self.view.frame.size.width, 40)];
    [aboutPocketCodeLabel setTextColor:[UIColor skyBlueColor]];
    [aboutPocketCodeLabel setText:kUIInfoPopupViewAboutPocketCode];
    [aboutPocketCodeLabel sizeToFit];
    aboutPocketCodeLabel.frame =CGRectMake(self.view.frame.size.width / 2 - aboutPocketCodeLabel.frame.size.width / 2, 10, aboutPocketCodeLabel.frame.size.width, aboutPocketCodeLabel.frame.size.height);
    aboutPocketCodeLabel.textAlignment = NSTextAlignmentCenter;
    [self.aboutPocketCodeView addSubview:aboutPocketCodeLabel];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, 40.0)];
    [path addLineToPoint:CGPointMake(self.aboutPocketCodeView.frame.size.width, 40.0)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.aboutPocketCodeView.layer addSublayer:shapeLayer];
    //init Body
    
    UITextView *bodyTextView = [[UITextView alloc] init];
    bodyTextView.frame = CGRectMake(20, 45, self.view.frame.size.width - 40, 50);
    bodyTextView.text = kUIInfoPopupViewAboutPocketCodeBody;
    [bodyTextView sizeToFit];
    bodyTextView.frame = CGRectMake(20, 45, self.view.frame.size.width - 40, bodyTextView.frame.size.height);
    bodyTextView.textColor = [UIColor lightOrangeColor];
    bodyTextView.backgroundColor = [UIColor backgroundColor];
    bodyTextView.editable = NO;
    
    [self.aboutPocketCodeView addSubview:bodyTextView];
    
    //TODO add Buttons for links
    // in the button function call something like this ->
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
    
    
    //initBackbutton
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:kUIInfoPopupViewBack forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    backButton.frame = CGRectMake(self.aboutPocketCodeView.frame.size.width / 2 - backButton.frame.size.width / 2, self.aboutPocketCodeView.frame.size.height - backButton.frame.size.height, backButton.frame.size.width, backButton.frame.size.height);
    [self.aboutPocketCodeView addSubview:backButton];
    
    
    //Animation to add the main subview -> aboutPocketCodeView
    self.aboutPocketCodeView.alpha = 0.0f;
    [self.view addSubview:self.aboutPocketCodeView];
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.aboutPocketCodeView.alpha = 1.0f;
                                }];
}

- (void)backAction
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                                self.aboutPocketCodeView.alpha = 0.0f;
                                }
                     completion:^(BOOL finished){
                                [self.aboutPocketCodeView removeFromSuperview];
                                }];    
    //TODO also remove other views if there are any (Termsofuse view..)
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

@end
