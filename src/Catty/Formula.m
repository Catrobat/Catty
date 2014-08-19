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

#import "Formula.h"
#import "FormulaElement.h"
#import "GDataXMLNode.h"
#import "Operators.h"

@implementation Formula

- (id)initWithInteger:(int)value
{
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

- (id)initWithDouble:(double)value
{
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

- (id)initWithFloat:(float)value
{
    return [self initWithDouble:value];
}

- (id)initWithFormulaElement:(FormulaElement*)formulaTree
{
    self = [super init];
    if(self) {
        self.formulaTree = formulaTree;
    }
    return self;
}

- (double)interpretDoubleForSprite:(SpriteObject*)sprite
{
    return [self.formulaTree interpretRecursiveForSprite:sprite];
}

- (int)interpretIntegerForSprite:(SpriteObject*)sprite
{
    return (int)[self.formulaTree interpretRecursiveForSprite:sprite];    
}

- (BOOL)interpretBOOLForSprite:(SpriteObject*)sprite
{
    int result = [self interpretIntegerForSprite:sprite];
    return result != 0 ? true : false;
}

- (BOOL)isSingleNumberFormula
{
    return [self.formulaTree isSingleNumberFormula];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *formulaTreeXMLElement = [GDataXMLNode elementWithName:@"formulaTree"];
    for (GDataXMLElement *childElement in [self.formulaTree XMLChildElements]) {
        [formulaTreeXMLElement addChild:childElement];
    }
    return formulaTreeXMLElement;
}

@end
