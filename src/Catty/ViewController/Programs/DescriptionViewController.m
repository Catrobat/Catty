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

#import "DescriptionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "MyProgramsViewController.h"
#import "ProgramTableViewController.h"

@interface DescriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@end

@implementation DescriptionViewController

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
    self.view.backgroundColor = [UIColor whiteGrayColor];
    self.navigationBar.tintColor = [UIColor navTintColor];
    self.navigationBar.backgroundColor = [UIColor navBarColor];
    [self initHeader];
    [self initTextView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.descriptionTextView becomeFirstResponder];
    [self.descriptionTextView setSelectedTextRange:[self.descriptionTextView textRangeFromPosition:self.descriptionTextView.beginningOfDocument toPosition:self.descriptionTextView.endOfDocument]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark Initialization

- (void)initHeader
{
    self.header.text = kLocalizedSetDescription;
    self.header.textColor =  [UIColor globalTintColor];
}

-(void)initTextView
{
    self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.descriptionTextView.textColor = [UIColor textTintColor];
    self.descriptionTextView.tintColor = [UIColor globalTintColor];
    
    if ([self.delegate isKindOfClass:[MyProgramsViewController class]]) {
        MyProgramsViewController *mpvc;
        mpvc = (MyProgramsViewController*)self.delegate;
        self.descriptionTextView.text = mpvc.selectedProgram.header.programDescription;
    }
    if ([self.delegate isKindOfClass:[ProgramTableViewController class]]) {
        ProgramTableViewController *mpvc;
        mpvc = (ProgramTableViewController*)self.delegate;
        self.descriptionTextView.text = mpvc.program.header.programDescription;
    }
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneAction:(id)sender {
    
    [self.delegate setDescription:self.descriptionTextView.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
