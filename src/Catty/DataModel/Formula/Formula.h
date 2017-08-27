/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "InternFormula.h"
#import "InternFormulaState.h"
#import "CBMutableCopying.h"

@class FormulaElement;
@class SpriteObject;

@interface Formula : NSObject<CBMutableCopying>

@property (nonatomic, strong) FormulaElement *formulaTree;
@property (nonatomic, weak) NSString *displayString;
@property (nonatomic, strong, readonly) NSNumber *lastResult;
@property (nonatomic, strong, readonly) id bufferedResult;

- (id)initWithZero;
- (id)initWithInteger:(int)value;
- (id)initWithDouble:(double)value;
- (id)initWithFloat:(float)value;
- (id)initWithString:(NSString*)value;
- (id)initWithFormulaElement:(FormulaElement*)formulaTree;

- (double)interpretDoubleForSprite:(SpriteObject*)sprite;
- (double)interpretDoubleForSprite:(SpriteObject*)sprite andUseCache:(BOOL)useCache;
- (float)interpretFloatForSprite:(SpriteObject*)sprite;
- (int)interpretIntegerForSprite:(SpriteObject*)sprite;
- (int)interpretIntegerForSprite:(SpriteObject*)sprite andUseCache:(BOOL)useCache;
- (BOOL)interpretBOOLForSprite:(SpriteObject*)sprite;
- (NSString*)interpretString:(SpriteObject*)sprite;
- (id)interpretVariableDataForSprite:(SpriteObject*)sprite;
- (void)preCalculateFormulaForSprite:(SpriteObject*)sprite;

- (BOOL)isSingleNumberFormula;
- (BOOL)isEqualToFormula:(Formula*)formula;

- (void)setRoot:(FormulaElement*)formulaTree;
- (InternFormulaState*)getInternFormulaState;
- (NSString*)getDisplayString;
- (InternFormula*)getInternFormula;
- (void)setDisplayString:(NSString*)text;
- (NSString*)getResultForComputeDialog:(SpriteObject*)sprite;
- (NSInteger)getRequiredResources;
@end
