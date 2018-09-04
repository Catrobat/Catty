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

#import "Formula.h"
#import "Pocket_Code-Swift.h"

@implementation Formula

- (id)initWithInteger:(int)value {
    self = [super init];
    
    if(self) {
        if(value < 0) {
            int absValue = abs(value);
            self.formulaTree = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:MINUS] leftChild:nil rightChild:nil parent:nil];
            FormulaElement *rightChild = [[FormulaElement alloc] initWithElementType:NUMBER value:[NSString stringWithFormat:@"%d", absValue] leftChild:nil rightChild:nil parent:self.formulaTree];
            self.formulaTree.rightChild = rightChild;
        } else {
            self.formulaTree = [[FormulaElement alloc] initWithElementType:NUMBER value:[NSString stringWithFormat:@"%d", value] leftChild:nil rightChild:nil parent:nil];
            
        }
    }
    return self;
}

- (id)initWithDouble:(double)value {
    self = [super init];
    
    if(self) {
        if(value < 0) {
            double absValue = fabs(value);
            self.formulaTree = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:MINUS] leftChild:nil rightChild:nil parent:nil];
            FormulaElement *rightChild = [[FormulaElement alloc] initWithElementType:NUMBER value:[NSString stringWithFormat:@"%f", absValue] leftChild:nil rightChild:nil parent:self.formulaTree];
            self.formulaTree.rightChild = rightChild;
        } else {
            self.formulaTree = [[FormulaElement alloc] initWithElementType:NUMBER value:[NSString stringWithFormat:@"%f", value] leftChild:nil rightChild:nil parent:nil];
        }
    }
    return self;
}

- (id)initWithFloat:(float)value {
    return [self initWithDouble:value];
}

- (id)initWithFormulaElement:(FormulaElement*)formulaTree {
    self = [super init];
    if (self) {
        self.formulaTree = formulaTree;
    }
    return self;
}

- (id)initWithString:(NSString *)value {
    self = [super init];
    
    if(self) {
        FormulaElement *formulaElement = [FormulaElement new];
        formulaElement.type = STRING;
        formulaElement.value = value;
        self.formulaTree = formulaElement;
    }
    return self;
}

- (id)initWithZero {
    return [self initWithInteger:0];
}

- (void) preCalculateFormulaForSprite:(SpriteObject*)sprite {
    // TODO
    //self.bufferedResult = [self.formulaTree interpretRecursiveForSprite:sprite];
}

- (BOOL)isSingularNumber
{
    return ([self.formulaTree isSingleNumberFormula] || self.formulaTree.type == STRING) && [self.formulaTree.value doubleValue] == 1.0;
}

- (void)setRoot:(FormulaElement*)formulaTree
{
    self.displayString = nil;
    self.formulaTree = formulaTree;
}

- (InternFormulaState*)getInternFormulaState {
    return [[self getInternFormula] getInternFormulaState];
}

- (InternFormula*)getInternFormula {
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:[self.formulaTree getInternTokenList]];
    return internFormula;
}

- (NSString*)getDisplayString {
    if (self.displayString != nil) {
        return self.displayString;
    } else {
        InternFormula *internFormula = [self getInternFormula];
        [internFormula generateExternFormulaStringAndInternExternMapping];
        return [internFormula getExternFormulaString];
    }
}

- (void)setDisplayString:(NSString *)text
{
    if (text == nil) {
        _displayString = nil;
    } else {
        _displayString = [NSString stringWithFormat:@"%@",text];
    }
}

- (BOOL)isEqualToFormula:(Formula*)formula
{
    if ([self.formulaTree isEqualToFormulaElement:formula.formulaTree]) {
        return YES;
    }
    return NO;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    Formula *formula = [Formula new];
    if (self.formulaTree) {
        formula.formulaTree = [self.formulaTree mutableCopyWithContext:context];
    }
    return formula;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.formulaTree getRequiredResources];
}


@end
