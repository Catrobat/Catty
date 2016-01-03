/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "Operators.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import <float.h>
#include <math.h>

@interface FormulaEditorTest : XCTestCase

@end

@implementation FormulaEditorTest

- (void)testGetInternTokenList
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: ( - 1 )");
    XCTAssertEqual(-1.0, [[parseTree interpretRecursiveForSprite:nil] doubleValue], @"Formula interpretation is not as expected");
    
    NSMutableArray *internTokenListAfterConversion = [parseTree getInternTokenList];
    XCTAssertEqual([internTokenListAfterConversion count], [internTokenList count], @"Generate InternTokenList from Tree error");
    
    for (int index = 0; index < [internTokenListAfterConversion count]; index++) {
        XCTAssertTrue([((InternToken*)[internTokenListAfterConversion objectAtIndex:index]) isEqualTo:((InternToken*)[internTokenList objectAtIndex:index])],
                      @"Generate InternTokenList from Tree error");
    }
    
    [internTokenList removeAllObjects];
}

- (void)testInterpretNonExistingUserVariable
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:USER_VARIABLE
                                                                           value:@"notExistingUserVariable"
                                                                       leftChild:nil
                                                                      rightChild:nil
                                                                          parent:nil];
    
    XCTAssertEqual(0, [[formulaElement interpretRecursiveForSprite:nil] doubleValue], @"Not existing UserVariable misinterpretation");
}

- (void)testInterpretNotExisitingUnaryOperator
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR
                                                                           value:[Operators getName:PLUS]
                                                                       leftChild:nil
                                                                      rightChild:[[FormulaElement alloc]
                                                                                  initWithElementType:NUMBER
                                                                                  value:@"1.0" leftChild:nil
                                                                                  rightChild:nil parent:nil]
                                                                          parent:nil];
    
    XCTAssertThrowsSpecific([formulaElement interpretRecursiveForSprite:nil], InternFormulaParserException, @"Not existing unary operator misinterpretation");
}

- (void)testCheckDegeneratedDoubleValues
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:NUMBER
                                                                           value:[NSString stringWithFormat:@"%f", DBL_MAX]
                                                                       leftChild:nil
                                                                      rightChild:nil
                                                                          parent:nil];
    XCTAssertEqual(DBL_MAX, [[formulaElement interpretRecursiveForSprite:nil] doubleValue], @"Degenerated double values error");
    
    formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR
                                                           value:[Operators getName:MINUS]
                                                       leftChild:[[FormulaElement alloc] initWithElementType:NUMBER
                                                                                                       value:[NSString stringWithFormat:@"%f", DBL_MAX * -1]
                                                                                                   leftChild:nil
                                                                                                  rightChild:nil parent:nil]
                                                      rightChild:[[FormulaElement alloc] initWithElementType:NUMBER
                                                                                                       value:[NSString stringWithFormat:@"%f", DBL_MAX]
                                                                                                   leftChild:nil
                                                                                                  rightChild:nil
                                                                                                      parent:nil]
                                                          parent:nil];
    
    XCTAssertEqual(-INFINITY, [[formulaElement interpretRecursiveForSprite:nil] doubleValue], @"Degenerated double values error");
    
    formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR
                                                           value:[Operators getName:DIVIDE]
                                                       leftChild:[[FormulaElement alloc] initWithElementType:NUMBER value:@"0"
                                                                                            leftChild:nil
                                                                                           rightChild:nil
                                                                                               parent:nil]
                                                      rightChild:[[FormulaElement alloc] initWithElementType:NUMBER
                                                                                               value:@"0"
                                                                                           leftChild:nil
                                                                                          rightChild:nil
                                                                                              parent:nil]
                                                   parent:nil];
    
    XCTAssertTrue(isnan([[formulaElement interpretRecursiveForSprite:nil] doubleValue]), @"Degenerated double values error");
}

- (void)testIsLogicalOperator
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:USER_VARIABLE value:@"notExistingUserVariable" leftChild:nil
                                                               rightChild:nil parent:nil];
    XCTAssertFalse([formulaElement isLogicalOperator], @"isLogicalOperator found logical operator but was userVariable");
}

- (void) testContainsElement
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR
                                                                           value:[Operators getName:MINUS]
                                                                       leftChild:[[FormulaElement alloc] initWithElementType:NUMBER
                                                                                                                       value:@"0.0"
                                                                                                                   leftChild:nil
                                                                                                                  rightChild:nil
                                                                                                                      parent:nil]
                                                                      rightChild:[[FormulaElement alloc] initWithElementType:USER_VARIABLE
                                                                                                                       value:@"user-variable"
                                                                                                                   leftChild:nil
                                                                                                                  rightChild:nil
                                                                                                                      parent:nil]
                                                                          parent:nil];
    
    XCTAssertTrue([formulaElement containsElement:USER_VARIABLE], @"ContainsElement: uservariable not found");
    
    formulaElement = [[FormulaElement alloc] initWithElementType:FUNCTION
                                                           value:[Functions getName:SIN]
                                                       leftChild:[[FormulaElement alloc] initWithElementType:OPERATOR
                                                                                                       value:@"+"
                                                                                                   leftChild:nil
                                                                                                  rightChild:nil
                                                                                                      parent:nil]
                                                      rightChild: nil
                                                          parent:nil];
    
    XCTAssertTrue(![formulaElement containsElement:NUMBER], @"ContainsElement: Operator \" + \" should not have been found!");
    
}

//- (void)testClone
//{
//    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:MINUS]
//                                                                      leftChild:[[FormulaElement alloc] initWithElementType:NUMBER value:@"0.0" leftChild:nil rightChild:nil parent:nil]
//                                                                      rightChild:[[FormulaElement alloc] initWithElementType:USER_VARIABLE value:@"user-variable" leftChild:nil rightChild:nil parent:nil]
//                                                                          parent:nil];
//    
//    NSMutableArray *internTokenList = [formulaElement getInternTokenList];
//    
//    FormulaElement *clonedFormulaElement = [formulaElement clone];
//    NSMutableArray *internTokenListAfterClone = [clonedFormulaElement getInternTokenList];
//    
//    for (int index = 0; index < [internTokenListAfterClone count]; index++) {
//        XCTAssertTrue(((InternToken*)[internTokenListAfterClone objectAtIndex:index]).internTokenType == ((InternToken*)[internTokenList objectAtIndex:index]).internTokenType
//                   && [((InternToken*)[internTokenListAfterClone objectAtIndex:index]).tokenStringValue isEqualToString:((InternToken*)[internTokenList objectAtIndex:index]).tokenStringValue],
//                      @"Clone error");
//        
//    }
//    
//    formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR value:[Operators getName:MINUS]
//                                                      leftChild:nil
//                                                     rightChild:[[FormulaElement alloc] initWithElementType:USER_VARIABLE value:@"user-variable" leftChild:nil rightChild:nil parent:nil]
//                                                         parent:nil];
//    
//    internTokenList = [formulaElement getInternTokenList];
//    
//    clonedFormulaElement = [formulaElement clone];
//    internTokenListAfterClone = [clonedFormulaElement getInternTokenList];
//    
//    for (int index = 0; index < [internTokenListAfterClone count]; index++) {
//        XCTAssertTrue(((InternToken*)[internTokenListAfterClone objectAtIndex:index]).internTokenType == ((InternToken*)[internTokenList objectAtIndex:index]).internTokenType
//                   && [((InternToken*)[internTokenListAfterClone objectAtIndex:index]).tokenStringValue isEqualToString:((InternToken*)[internTokenList objectAtIndex:index]).tokenStringValue],
//                      @"Clone error");
//    }
//    
//}


@end
