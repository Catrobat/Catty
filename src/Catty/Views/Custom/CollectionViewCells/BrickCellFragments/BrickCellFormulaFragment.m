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


#import "BrickCellFormulaFragment.h"
#import "BrickCell.h"
#import "BrickFormulaProtocol.h"
#import "FormulaEditorButton.h"
#import "LanguageTranslationDefines.h"

@interface BrickCellFormulaFragment()
@property (nonatomic) NSInteger lineNumber;
@property (nonatomic) NSInteger parameterNumber;
@end

@implementation BrickCellFormulaFragment

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    Brick<BrickFormulaProtocol> *formulaBrick = (Brick<BrickFormulaProtocol>*)brickCell.scriptOrBrick;
    Formula *formula = [formulaBrick formulaForLineNumber:line andParameterNumber:parameter
];
    if(self = [super initWithFrame:frame AndBrickCell:brickCell AndFormula: formula]) {
        self.brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
    }
    return self;
}

- (void)saveFormula:(Formula *)formula
{
    [self.formula setRoot:formula.formulaTree];
    [self.brickCell.fragmentDelegate updateData:self.formula forBrick:(Brick*)self.brickCell.scriptOrBrick andLineNumber:self.lineNumber andParameterNumber:self.parameterNumber];

}

@end
