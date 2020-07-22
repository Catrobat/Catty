/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@protocol FormulaEditorViewControllerDelegate <NSObject>
- (void)saveFormula:(Formula*)formula;
@end

@class BrickCellFormulaData;
@class FormulaManager;
@class UserList;

@interface FormulaEditorViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) InternFormula *internFormula;
@property (strong, nonatomic) FormulaEditorHistory *history;
@property (strong, nonatomic) NSMutableArray<UserVariable*> *variableSourceProject;
@property (strong, nonatomic) NSMutableArray<UserVariable*> *variableSourceObject;
@property (strong, nonatomic) NSMutableArray<UserVariable*> *listSourceProject;
@property (strong, nonatomic) NSMutableArray<UserVariable*> *listSourceObject;
@property (weak, nonatomic) SpriteObject *object;
@property (strong, nonatomic) FormulaManager *formulaManager;
@property (strong, nonatomic) id<FormulaEditorViewControllerDelegate> delegate;

- (id)initWithBrickCellFormulaData:(BrickCellFormulaData *)brickCellData andFormulaManager:(FormulaManager*)formulaManager;
- (void)setBrickCellFormulaData:(BrickCellFormulaData*)brickCellData;
- (void)update;
- (void)updateDeleteButton:(BOOL)enabled;
- (void)backspace:(id)sender;
- (BOOL)changeBrickCellFormulaData:(BrickCellFormulaData*)brickCellData andForce:(BOOL)forceChange;

- (void)handleInput;
- (BOOL)isVariableUsed:(UserVariable*)variable;
- (BOOL)isListUsed:(id<UserDataProtocol>)list;

@end
