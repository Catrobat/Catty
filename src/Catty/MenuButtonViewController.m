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

#import "MenuButtonViewController.h"
#import "SlidingViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface MenuButtonViewController ()

@end

@implementation MenuButtonViewController

@synthesize backButton = _backButton;
@synthesize continueButton = _continueButton;
@synthesize screenshotButton = _screenshotButton;


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

    
    [self.slidingViewController setAnchorRightRevealAmount:100.0f];
    self.slidingViewController.underLeftWidthLayout = FullWidth;
    
    [self.view addSubview:self.menuView];
    self.menuView.backgroundColor = [UIColor darkBlueColor];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(15.0f, 7.0f, 33.0f, 44.0f);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(stopLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.backButton];
    
    self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _continueButton.frame = CGRectMake(10.0f, 100.0f, 33.0f, 44.0f);
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"ic_media_play"] forState:UIControlStateNormal];
    [_continueButton addTarget:self action:@selector(continueLevel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.continueButton];
    
    [self.menuView addSubview:self.backButton];
    
    self.screenshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _screenshotButton.frame = CGRectMake(20.0f, 180.0f, 33.0f, 44.0f);
    [_screenshotButton setBackgroundImage:[UIImage imageNamed:@"screenshot"] forState:UIControlStateNormal];
    [_screenshotButton addTarget:self action:@selector(takeScreenshot:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView addSubview:self.screenshotButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma button functions

- (void)stopLevel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)continueLevel:(UIButton *)sender
{
    [self.slidingViewController anchorTopViewTo:Right];
}


- (void)takeScreenshot:(UIButton *)sender
{
    NSString *popupmessage = [NSString stringWithFormat:@"Soon available"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Screenshot"
                                                    message:popupmessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
