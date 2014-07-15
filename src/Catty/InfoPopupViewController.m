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
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *bodyTextView;
@end

@implementation InfoPopupViewController

const int FRAME_PADDING_HORIZONTAL = 20;
const CGFloat FRAME_HEIGHT = 280.0f;

const int HEADER_PADDING_TOP = 10;
const int HEADER_LABEL_HEIGHT = 40;

const int BODY_PADDING_TOP = 5;
const int BODY_PADDING_BOTTOM = 5;

const int MENU_BUTTON_MARGIN_HORIZONTAL = 20;
const int BUTTON_HEIGHT = 30;
const int BUTTON_MARGIN_BOTTOM = 15;

- (UITextView *)bodyTextView
{
    if(!_bodyTextView) _bodyTextView = [[UITextView alloc] init];
    return _bodyTextView;
}

- (UIView *)contentView
{
    if(!_contentView) _contentView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x - FRAME_PADDING_HORIZONTAL, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    return _contentView;
}

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
    self.view.frame = CGRectMake(0,0, FRAME_HEIGHT, FRAME_HEIGHT);
    self.view.backgroundColor = [UIColor backgroundColor];
    [self initAboutPocketCodeButton];
    [self initTermsOfUseButton];
    [self initRateUsButton];
    [self initProgramVersion];
}

#pragma mark Initialization

- (void)initAboutPocketCodeButton
{
    UIButton *aboutPocketCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [aboutPocketCodeButton setTitle:kUIInfoPopupViewAboutPocketCode forState:UIControlStateNormal];
    [aboutPocketCodeButton addTarget:self
                        action:@selector(aboutPocketCode)
              forControlEvents:UIControlEventTouchUpInside];
    [aboutPocketCodeButton sizeToFit];
    aboutPocketCodeButton.frame = CGRectMake(self.view.frame.size.width / 2 - aboutPocketCodeButton.frame.size.width / 2, MENU_BUTTON_MARGIN_HORIZONTAL, aboutPocketCodeButton.frame.size.width, BUTTON_HEIGHT);
    
    [self addMenuButton:aboutPocketCodeButton];
}

- (void)initTermsOfUseButton
{
    UIButton *termsOfUseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [termsOfUseButton setTitle:kUIInfoPopupViewTermsOfUse forState:UIControlStateNormal];
    [termsOfUseButton addTarget:self
                        action:@selector(termsOfUse)
              forControlEvents:UIControlEventTouchUpInside];
    [termsOfUseButton sizeToFit];
    termsOfUseButton.frame = CGRectMake(self.view.frame.size.width / 2 - termsOfUseButton.frame.size.width / 2, 3 * MENU_BUTTON_MARGIN_HORIZONTAL + BUTTON_HEIGHT, termsOfUseButton.frame.size.width, BUTTON_HEIGHT);
    
    [self addMenuButton:termsOfUseButton];
}

- (void)initRateUsButton
{
    UIButton *rateUsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rateUsButton setTitle:kUIInfoPopupViewRateUs forState:UIControlStateNormal];
    [rateUsButton addTarget:self
                              action:@selector(openURLAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    [rateUsButton sizeToFit];
    rateUsButton.frame = CGRectMake(self.view.frame.size.width / 2 - rateUsButton.frame.size.width / 2, 5 * MENU_BUTTON_MARGIN_HORIZONTAL + 2 * BUTTON_HEIGHT, rateUsButton.frame.size.width, BUTTON_HEIGHT);
    
    [self addMenuButton:rateUsButton];
}

- (void)initProgramVersion
{
    NSString *version = [[NSString alloc] initWithFormat:@"%@%@", kUIInfoPopupViewVersionLabel, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, HEADER_PADDING_TOP, self.view.frame.size.width, HEADER_LABEL_HEIGHT)];
    [versionLabel setTextColor:[UIColor skyBlueColor]];
    [versionLabel setTextAlignment:NSTextAlignmentRight];
    [versionLabel setText:version];
    [versionLabel sizeToFit];
    versionLabel.frame = CGRectMake(0, self.view.frame.size.height - versionLabel.frame.size.height - BODY_PADDING_BOTTOM * 2, self.view.frame.size.width, versionLabel.frame.size.height);
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
}

- (void)addMenuButton:(UIButton *)button
{
    [self.view addSubview:button];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, button.frame.origin.y + button.frame.size.height + MENU_BUTTON_MARGIN_HORIZONTAL)];
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, button.frame.origin.y + button.frame.size.height + MENU_BUTTON_MARGIN_HORIZONTAL)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

- (void)initContentView:(NSString *)headerTitle withText:(NSString *)bodyText
{
    self.contentView.backgroundColor = [UIColor backgroundColor];
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    
    //init header
    UILabel *aboutPocketCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, HEADER_PADDING_TOP, self.view.frame.size.width, HEADER_LABEL_HEIGHT)];
    [aboutPocketCodeLabel setTextColor:[UIColor skyBlueColor]];
    [aboutPocketCodeLabel setText:headerTitle];
    [aboutPocketCodeLabel sizeToFit];
    aboutPocketCodeLabel.frame = CGRectMake(self.view.frame.size.width / 2 - aboutPocketCodeLabel.frame.size.width / 2, HEADER_PADDING_TOP, aboutPocketCodeLabel.frame.size.width, aboutPocketCodeLabel.frame.size.height);
    aboutPocketCodeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:aboutPocketCodeLabel];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, HEADER_LABEL_HEIGHT)];
    [path addLineToPoint:CGPointMake(self.contentView.frame.size.width, HEADER_LABEL_HEIGHT)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.contentView.layer addSublayer:shapeLayer];
    
    //init body
    self.bodyTextView.frame = CGRectMake(FRAME_PADDING_HORIZONTAL, HEADER_LABEL_HEIGHT + BODY_PADDING_TOP, self.view.frame.size.width - 2 * FRAME_PADDING_HORIZONTAL, 50);
    self.bodyTextView.text = bodyText;
    self.bodyTextView.textAlignment = NSTextAlignmentCenter;
    [self.bodyTextView sizeToFit];
    self.bodyTextView.frame = CGRectMake(FRAME_PADDING_HORIZONTAL, HEADER_LABEL_HEIGHT + BODY_PADDING_TOP, self.view.frame.size.width - 2 * FRAME_PADDING_HORIZONTAL, self.bodyTextView.frame.size.height);
    self.bodyTextView.textColor = [UIColor lightOrangeColor];
    self.bodyTextView.backgroundColor = [UIColor backgroundColor];
    self.bodyTextView.editable = NO;
    [self.contentView addSubview:self.bodyTextView];
    
    //initBackbutton
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:kUIInfoPopupViewBack forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    backButton.frame = CGRectMake(self.contentView.frame.size.width / 2 - backButton.frame.size.width / 2, self.contentView.frame.size.height - backButton.frame.size.height - BODY_PADDING_BOTTOM, backButton.frame.size.width, backButton.frame.size.height);
    [self.contentView addSubview:backButton];
    
    UIBezierPath *backPath = [UIBezierPath bezierPath];
    [backPath moveToPoint:CGPointMake(0.0, backButton.frame.origin.y - BODY_PADDING_BOTTOM / 2)];
    [backPath addLineToPoint:CGPointMake(self.contentView.frame.size.width, backButton.frame.origin.y - BODY_PADDING_BOTTOM / 2)];
    CAShapeLayer *backShapeLayer = [CAShapeLayer layer];
    backShapeLayer.path = [backPath CGPath];
    backShapeLayer.fillColor = [[UIColor skyBlueColor] CGColor];
    backShapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    backShapeLayer.lineWidth = 2.0f;
    backShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.contentView.layer addSublayer:backShapeLayer];
}

- (void)showContentView
{
    self.contentView.alpha = 0.0f;
    [self.view addSubview:self.contentView];
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentView.alpha = 1.0f;
                     }];
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
    [self initContentView:kUIInfoPopupViewAboutPocketCode withText:kUIInfoPopupViewAboutPocketCodeBody];
    
    //init buttons
    UIButton *sourceCodeLicenseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sourceCodeLicenseButton setTitle:kUIInfoPopupViewSourceCodeLicenseButtonLabel forState:UIControlStateNormal];
    [sourceCodeLicenseButton sizeToFit];
    sourceCodeLicenseButton.frame = CGRectMake(self.contentView.frame.size.width / 2 - sourceCodeLicenseButton.frame.size.width / 2, self.bodyTextView.frame.origin.y + self.bodyTextView.frame.size.height + BUTTON_MARGIN_BOTTOM, sourceCodeLicenseButton.frame.size.width, sourceCodeLicenseButton.frame.size.height);
    [sourceCodeLicenseButton addTarget:self action:@selector(openURLAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:sourceCodeLicenseButton belowSubview:self.bodyTextView];
    
    UIButton *aboutCatrobatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [aboutCatrobatButton setTitle:kUIInfoPopupViewAboutCatrobatButtonLabel forState:UIControlStateNormal];
    [aboutCatrobatButton sizeToFit];
    aboutCatrobatButton.frame = CGRectMake(self.contentView.frame.size.width / 2 - aboutCatrobatButton.frame.size.width / 2, sourceCodeLicenseButton.frame.origin.y + sourceCodeLicenseButton.frame.size.height, aboutCatrobatButton.frame.size.width, aboutCatrobatButton.frame.size.height);
    [aboutCatrobatButton addTarget:self action:@selector(openURLAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:aboutCatrobatButton belowSubview:self.bodyTextView];
    
    //Animation to add the main subview
    [self showContentView];
}

- (void)termsOfUse
{
    //init OverlayView
    [self initContentView:kUIInfoPopupViewTermsOfUse withText:kUIInfoPopupViewTermsOfUseBody];
    
    //init buttons
    UIButton *sourceCodeLicenseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sourceCodeLicenseButton setTitle:kUIInfoPopupViewTermsOfUse forState:UIControlStateNormal];
    [sourceCodeLicenseButton sizeToFit];
    sourceCodeLicenseButton.frame = CGRectMake(self.contentView.frame.size.width / 2 - sourceCodeLicenseButton.frame.size.width / 2, self.bodyTextView.frame.origin.y + self.bodyTextView.frame.size.height + BUTTON_MARGIN_BOTTOM, sourceCodeLicenseButton.frame.size.width, sourceCodeLicenseButton.frame.size.height);
    [sourceCodeLicenseButton addTarget:self action:@selector(openURLAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:sourceCodeLicenseButton belowSubview:self.bodyTextView];
    
    //Animation to add the main subview
    [self showContentView];
}

- (void)backAction
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                                    self.contentView.alpha = 0.0f;
                                }
                     completion:^(BOOL finished){
                                    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                }];
}

- (void)openURLAction:(id)sender
{
    NSString *url = nil;
    
    UIButton *button = (UIButton *)sender;
    if([button.currentTitle isEqualToString:kUIInfoPopupViewSourceCodeLicenseButtonLabel])
        url = kSourceCodeLicenseURL;
    else if([button.currentTitle isEqualToString:kUIInfoPopupViewAboutCatrobatButtonLabel])
        url = kAboutCatrobatURL;
    else if([button.currentTitle isEqualToString:kUIInfoPopupViewTermsOfUse])
        url = kAboutCatrobatURL;
    else if([button.currentTitle isEqualToString:kUIInfoPopupViewRateUs]) {
        url = kAppStoreURL;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
