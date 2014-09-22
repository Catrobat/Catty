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
@end

@implementation FormulaEditorTextField

- (id)initWithFrame:(CGRect)frame AndFormulaEditorViewController:(FormulaEditorViewController*)formulaEditorViewController
{
    self = [super initWithFrame:frame];
    self.formulaEditorViewController = formulaEditorViewController;
    if (self) {
        self.delegate = self.formulaEditorViewController;
        self.inputView = [[[NSBundle mainBundle] loadNibNamed:@"FormulaEditor" owner:self.formulaEditorViewController options:nil] lastObject];
        self.inputView.backgroundColor = UIColor.airForceBlueColor;
        self.userInteractionEnabled = YES;
        //[self addTarget:self.formulaEditorViewController action:@selector(inputDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        [self update];
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
}


@end
