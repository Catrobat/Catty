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

#import "FormulaEditorTextView.h"
#import "FormulaEditorViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickCell.h"
#import "BrickFormulaProtocol.h"
#import "Formula.h"
#import <UIKit/UIKit.h>

@interface FormulaEditorTextView ()
@property (nonatomic, weak) FormulaEditorViewController *formulaEditorViewController;
@property (nonatomic, strong) UIButton *backspaceButton;
@end

@implementation FormulaEditorTextView

#define TEXT_FIELD_PADDING_HORIZONTAL 5
#define TEXT_FIELD_PADDING_VERTICAL 10
#define TEXT_FIELD_MARGIN_BOTTOM 2
#define BACKSPACE_HEIGHT 28
#define BACKSPACE_WIDTH 28

- (id)initWithFrame:(CGRect)frame AndFormulaEditorViewController:(FormulaEditorViewController*)formulaEditorViewController
{
    self = [super initWithFrame:frame];
    self.formulaEditorViewController = formulaEditorViewController;
    if (self) {
        self.delegate = self;
        self.inputView = [[[NSBundle mainBundle] loadNibNamed:@"FormulaEditor" owner:self.formulaEditorViewController options:nil] lastObject];
        self.inputView.backgroundColor = UIColor.airForceBlueColor;
        self.userInteractionEnabled = YES;
        
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont boldSystemFontOfSize:20.0f];
        
        self.contentInset = UIEdgeInsetsZero;
        self.textContainerInset = UIEdgeInsetsMake(TEXT_FIELD_PADDING_VERTICAL, TEXT_FIELD_PADDING_HORIZONTAL, TEXT_FIELD_PADDING_VERTICAL, TEXT_FIELD_PADDING_HORIZONTAL + BACKSPACE_WIDTH);
        
        self.backspaceButton = [[UIButton alloc] init];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateDisabled];
        self.backspaceButton.tintColor = UIColor.airForceBlueColor;
        self.backspaceButton.frame = CGRectMake(self.frame.size.width - BACKSPACE_WIDTH, 0, BACKSPACE_HEIGHT, BACKSPACE_WIDTH);
        [self.backspaceButton addTarget:self.formulaEditorViewController action:@selector(backspace:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backspaceButton];
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
   
- (void)setText:(NSString *)text
{
    [super setText:text];
    [self layoutIfNeeded];
    
    CGRect frame = self.frame;
    frame.size.height = self.contentSize.height;
    
    float maxHeight = [[UIScreen mainScreen] bounds].size.height - self.frame.origin.y - self.inputView.frame.size.height - TEXT_FIELD_MARGIN_BOTTOM;
    if(frame.size.height > maxHeight)
        frame.size.height = maxHeight;
    
    self.frame = frame;
    [self scrollRangeToVisible:NSMakeRange(self.text.length - 1, 1)];
    
    NSLog(@"lineHeight=%f, frameHeight=%f", self.font.lineHeight, self.frame.size.height);
    
    CGRect backspaceFrame = self.backspaceButton.frame;
    backspaceFrame.origin.y = self.contentSize.height - TEXT_FIELD_PADDING_VERTICAL - self.font.lineHeight/2 - self.backspaceButton.frame.size.height/2;
    self.backspaceButton.frame = backspaceFrame;
}

@end
