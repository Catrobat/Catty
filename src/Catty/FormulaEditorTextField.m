/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "FormulaEditorTextField.h"
#import "FormulaEditorViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickCell.h"
#import "BrickFormulaProtocol.h"
#import "Formula.h"
#import <UIKit/UIKit.h>

@interface FormulaEditorTextField ()
@property (nonatomic, weak) FormulaEditorViewController *formulaEditorViewController;
@property (nonatomic, strong) UIButton *backspaceButton;
@end

@implementation FormulaEditorTextField

#define BACKSPACE_HEIGHT 25
#define BACKSPACE_WIDTH 25

- (id)initWithFrame:(CGRect)frame AndFormulaEditorViewController:(FormulaEditorViewController*)formulaEditorViewController
{
    self = [super initWithFrame:frame];
    self.formulaEditorViewController = formulaEditorViewController;
    if (self) {
        self.delegate = self;
        self.inputView = [[[NSBundle mainBundle] loadNibNamed:@"FormulaEditor" owner:self.formulaEditorViewController options:nil] lastObject];
        self.inputView.backgroundColor = UIColor.airForceBlueColor;
        self.userInteractionEnabled = YES;
        
        self.backspaceButton = [[UIButton alloc] init];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateDisabled];
        self.backspaceButton.frame = CGRectMake(0, 0, BACKSPACE_HEIGHT, BACKSPACE_WIDTH);
        self.backspaceButton.tintColor = UIColor.airForceBlueColor;
        [self.backspaceButton addTarget:self.formulaEditorViewController action:@selector(backspace:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = self.backspaceButton;
    }
    return self;
}

#pragma mark - TextField properties
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (BOOL)isTextSelectable
{
    return NO;
}

- (BOOL)isHighlighted
{
    return NO;
}

- (BOOL)isTracking
{
    return NO;
}

- (void)update
{
    [self.formulaEditorViewController.internFormula generateExternFormulaStringAndInternExternMapping];
    [self.formulaEditorViewController.internFormula updateInternCursorPosition];
    self.text = [self.formulaEditorViewController.internFormula getExternFormulaString];
    
    if([self.formulaEditorViewController.internFormula isEmpty]) {
        self.backspaceButton.enabled = NO;
        self.backspaceButton.alpha = 0.3;
    } else {
        self.backspaceButton.enabled = YES;
        self.backspaceButton.alpha = 1.0;
    }
}

@end
