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

#import "UIUtil.h"
#import "UIDefines.h"
#import "MessageComboBoxView.h"
#import "ObjectComboBoxView.h"
#import "SoundComboBoxView.h"
#import "LookComboBoxView.h"
#import "VariableComboBoxView.h"
#import "FormulaEditorButton.h"
#import "BrickDetailViewController.h"
#import "ScriptCollectionViewController.h"

@implementation UIUtil

+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame
{
    return [self newDefaultBrickLabelWithFrame:frame AndText:nil];
}

+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame AndText:(NSString*)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:kBrickLabelFontSize];
    if (text) {
        label.text = text;
        // adapt size to fit text
        [label sizeToFit];
        CGRect labelFrame = label.frame;
        labelFrame.size.height = frame.size.height;
        label.frame = labelFrame;
    }
    return label;
}

+ (UITextField*)newDefaultBrickTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:kBrickTextFieldFontSize];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return textField;
}

+ (UIButton*)newDefaultBrickFormulaEditorWithFrame:(CGRect)frame ForBrickCell:(BrickCell*)brickCell AndLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    FormulaEditorButton *button = [[FormulaEditorButton alloc] initWithFrame:frame AndBrickCell:brickCell AndLineNumber:lineNumber AndParameterNumber:paramNumber];
    return button;
}

+ (MessageComboBoxView*)newDefaultBrickMessageComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items
{
    MessageComboBoxView *comboBox = [[MessageComboBoxView alloc] initWithFrame:frame];
    comboBox.items = items;
    return comboBox;
}

+ (ObjectComboBoxView*)newDefaultBrickObjectComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items
{
    ObjectComboBoxView *comboBox = [[ObjectComboBoxView alloc] initWithFrame:frame];
    comboBox.items = items;
    return comboBox;
}

+ (SoundComboBoxView*)newDefaultBrickSoundComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items
{
    SoundComboBoxView *comboBox = [[SoundComboBoxView alloc] initWithFrame:frame];
    comboBox.items = items;
    return comboBox;
}

+ (LookComboBoxView*)newDefaultBrickLookComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items
{
    LookComboBoxView *comboBox = [[LookComboBoxView alloc] initWithFrame:frame];
    comboBox.items = items;
    return comboBox;
}

+ (VariableComboBoxView*)newDefaultBrickVariableComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items
{
    VariableComboBoxView *comboBox = [[VariableComboBoxView alloc] initWithFrame:frame];
    comboBox.items = items;
    return comboBox;
}

@end
