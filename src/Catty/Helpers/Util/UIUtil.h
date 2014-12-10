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

#import <Foundation/Foundation.h>

@class MessageComboBoxView;
@class ObjectComboBoxView;
@class SoundComboBoxView;
@class LookComboBoxView;
@class VariableComboBoxView;
@class FormulaEditorTextField;
@class BrickCell;

@interface UIUtil : NSObject

+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame;
+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame AndText:(NSString*)text;
+ (UITextField*)newDefaultBrickTextFieldWithFrame:(CGRect)frame andNote:(NSString*)note AndBrickCell:(BrickCell*)brickCell;
+ (UIButton*)newDefaultBrickFormulaEditorWithFrame:(CGRect)frame ForBrickCell:(BrickCell*)brickCell AndLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber;

+ (MessageComboBoxView*)newDefaultBrickMessageComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items;
+ (ObjectComboBoxView*)newDefaultBrickObjectComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items;
+ (SoundComboBoxView*)newDefaultBrickSoundComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items;
+ (LookComboBoxView*)newDefaultBrickLookComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items;
+ (VariableComboBoxView*)newDefaultBrickVariableComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items;

@end
