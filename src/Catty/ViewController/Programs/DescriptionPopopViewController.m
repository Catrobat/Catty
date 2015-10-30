/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "DescriptionPopopViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "MyProgramsViewController.h"
#import "ProgramTableViewController.h"

@interface DescriptionPopopViewController ()
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation DescriptionPopopViewController

const CGFloat DESCRIPTION_HEIGHT = 250.0f;
const CGFloat DESCRIPTION_WIDTH = 280.0f;

- (UITextView *)descriptionTextView
{
    if(!_descriptionTextView) _descriptionTextView = [[UITextView alloc] init];
    return _descriptionTextView;
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
    self.view.frame = CGRectMake(0,0, DESCRIPTION_WIDTH, DESCRIPTION_HEIGHT);
    self.view.backgroundColor = [UIColor backgroundColor];
    [self initHeader];
    [self initTextView];
    [self initButtons];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.descriptionTextView becomeFirstResponder];
    [self.descriptionTextView setSelectedTextRange:[self.descriptionTextView textRangeFromPosition:self.descriptionTextView.beginningOfDocument toPosition:self.descriptionTextView.endOfDocument]];
}

#pragma mark Initialization

- (void)initHeader
{
    self.header = [UILabel new];
    self.header.text = kLocalizedSetDescription;

    self.header.textColor =  [UIColor lightTextTintColor];
    self.header.font =  [UIFont systemFontOfSize:16.0f];
    [self.header sizeToFit];
    self.header.frame = CGRectMake(self.view.frame.size.width / 2 - self.header.frame.size.width / 2, 20, self.header.frame.size.width, self.header.frame.size.height);
    
    [self.view addSubview:self.header];
}

-(void)initTextView
{
    self.descriptionTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.descriptionTextView.textColor = [UIColor lightTextTintColor];
    self.descriptionTextView.tintColor = [UIColor globalTintColor];
    self.descriptionTextView.frame = CGRectMake(20, self.header.frame.origin.y+self.header.frame.size.height+30, self.view.frame.size.width-40, 100);
    
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
    
    [self.view addSubview:self.descriptionTextView];
}

-(void)initButtons
{

    self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.okButton addTarget:self
               action:@selector(saveAction)
     forControlEvents:UIControlEventTouchUpInside];
    [self.okButton setTitle:kLocalizedOK forState:UIControlStateNormal];
    self.okButton.frame = CGRectMake(self.view.frame.size.width/2, self.descriptionTextView.frame.origin.y+self.descriptionTextView.frame.size.height+30, self.view.frame.size.width/2, 30);
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton addTarget:self
                      action:@selector(cancelAction)
            forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:kLocalizedCancel forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(0, self.descriptionTextView.frame.origin.y+self.descriptionTextView.frame.size.height+30, self.view.frame.size.width/2, 30);
   
    
    [self.view addSubview:self.okButton];
    [self.view addSubview:self.cancelButton];
    
}

-(void)saveAction
{
    MyProgramsViewController *mpvc;
    ProgramTableViewController *pTVC;
    if ([self.delegate isKindOfClass:[MyProgramsViewController class]]) {
        mpvc = (MyProgramsViewController*)self.delegate;
        mpvc.changedDescription = self.descriptionTextView.text;
    } else if ([self.delegate isKindOfClass:[ProgramTableViewController class]]){
        pTVC = (ProgramTableViewController*)self.delegate;
        pTVC.changedProgramDescription = self.descriptionTextView.text;
    }
    
    [self.delegate dismissPopupWithCode:YES];
}

-(void)cancelAction
{
    [self.delegate dismissPopupWithCode:NO];
}

@end
