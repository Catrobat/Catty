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

#import <XCTest/XCTest.h>
#import "Formula.h"
#import "FormulaElement.h"
#import "Util.h"
#import "Math.h"

@interface InternFormulaParserStringFunctionsTest : XCTestCase

@end


@implementation InternFormulaParserStringFunctionsTest

- (void)setUp {
    [super setUp];
    //ProgramManager *programManager = [ProgramManager sharedProgramManager];
    //VariablesContainer *container = programManager.program.variables;
    //UserVariable *userVariable = [container getUserVariableNamed:self.currentToken.tokenStringValue forSpriteObject:object];
    //TODO: Add tests for UserVariables if strings are possible
}

- (FormulaElement*)getFormulaElementForFunction:(Function)function WithLeftValue:(NSString*)leftValue AndRightValue:(NSString*)rightValue
{
    FormulaElement *leftElement = [[FormulaElement alloc] initWithType:@"STRING" value:leftValue leftChild:nil rightChild:nil parent:nil];
    FormulaElement *rightElement = nil;
    
    if(rightValue != nil)
        rightElement = [[FormulaElement alloc] initWithType:@"STRING" value:rightValue leftChild:nil rightChild:nil parent:nil];
    
    FormulaElement *formula = [[FormulaElement alloc] initWithType:@"FUNCTION" value:[Functions getName:function] leftChild:leftElement rightChild:rightElement parent:nil];
    
    return formula;
}

- (void)testLenght
{
    NSString *firstParameter = @"testString";
    FormulaElement *formula = [self getFormulaElementForFunction:LENGTH WithLeftValue:firstParameter AndRightValue:nil];
    XCTAssertNotNil(formula, @"Formula is not parsed correctly!");
    XCTAssertEqual([[formula interpretRecursiveForSprite:nil] doubleValue], [firstParameter length], @"Formula interpretation is not as expected!");
    
}































@end
