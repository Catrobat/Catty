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

#import <Foundation/Foundation.h>
#import "Functions.h"
#import "Operators.h"
#import "CBMutableCopying.h"

@class SpriteObject;

typedef NS_ENUM(NSInteger, ElementType) {
    OPERATOR = 10000,
    FUNCTION,
    NUMBER,
    SENSOR,
    USER_VARIABLE,
    BRACKET,
    STRING
};

typedef NS_ENUM(NSInteger, IdempotenceState) {
    NOT_CHECKED = 0,
    IDEMPOTENT,
    NOT_IDEMPOTENT
};

@interface FormulaElement : NSObject<CBMutableCopying>

@property (nonatomic, assign) ElementType type;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) FormulaElement* leftChild;
@property (nonatomic, strong) FormulaElement* rightChild;
@property (nonatomic, strong) FormulaElement* parent;
@property (nonatomic) IdempotenceState idempotenceState;

- (id)initWithType:(NSString*)type
             value:(NSString*)value
         leftChild:(FormulaElement*)leftChild
        rightChild:(FormulaElement*)rightChild
            parent:(FormulaElement*)parent;

- (id)initWithElementType:(ElementType)type
             value:(NSString*)value
         leftChild:(FormulaElement*)leftChild
        rightChild:(FormulaElement*)rightChild
            parent:(FormulaElement*)parent;

- (id)interpretRecursiveForSprite:(SpriteObject*)sprite;

- (BOOL)isEqualToFormulaElement:(FormulaElement*)formulaElement;

- (FormulaElement*) getRoot;

- (void)replaceElement:(FormulaElement*)current;

- (NSString*)stringForElementType:(ElementType)type;

- (void)replaceElement:(ElementType)type value:(NSString*)value;

- (void)replaceWithSubElement:(NSString*) operator rightChild:(FormulaElement*)rightChild;

- (NSMutableArray*)getInternTokenList;

- (BOOL)isLogicalOperator;

- (BOOL)isLogicalFunction;

//- (BOOL)hasFunctionStringReturnType;

- (BOOL)isSingleNumberFormula;

- (BOOL)containsElement:(ElementType)elementType;

@end
