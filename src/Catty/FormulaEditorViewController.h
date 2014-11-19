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

#import <UIKit/UIKit.h>
#import "InternFormula.h"
#import "Formula.h"
#import "FormulaEditorHistory.h"
#import "SpriteObject.h"

@class FormulaEditorViewController;
@class BrickCell;

@protocol FormulaEditorViewControllerDelegate <NSObject>

@optional
- (void)formulaEditorViewController:(FormulaEditorViewController *)formulaEditorViewController
                      withBrickCell:(BrickCell *)brickCell;
@end

@interface FormulaEditorViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) id<FormulaEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) InternFormula *internFormula;
@property (strong, nonatomic) FormulaEditorHistory *history;
@property (strong, nonatomic) NSMutableArray *variableSourceProgram;
@property (strong, nonatomic) NSMutableArray *variableSourceObject;
@property (weak, nonatomic) SpriteObject *object;

- (id)initWithBrickCell:(BrickCell*)brickCell;
- (void)setFormula:(Formula*)formula;
- (void)update;
- (void)updateDeleteButton:(BOOL)enabled;
- (void)backspace:(id)sender;

@end
