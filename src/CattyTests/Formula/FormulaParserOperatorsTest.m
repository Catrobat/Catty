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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "InternFormulaUtils.h"
#import "InternFormula.h"

@interface FormulaParserOperatorsTest : XCTestCase

@end

@implementation FormulaParserOperatorsTest

- (void)setUp {
    [super setUp];
}

- (NSMutableArray *)buildBinaryOperator:(InternTokenType)firstTokenType
                             firstValue:(NSString *)firstValue
                           withOperator:(Operator)operator
                        secondTokenType:(InternTokenType)secondTokenType
                            secondValue:(NSString *)secondValue
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:firstTokenType AndValue:firstValue]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:operator]]];
    [internTokens addObject:[[InternToken alloc] initWithType:secondTokenType AndValue:secondValue]];

    return internTokens;
}

- (NSMutableArray *)mergeOperatorLists:(NSMutableArray *)firstList
                           withOperator:(Operator)operator
                        andSecondList:(NSMutableArray *)secondList
{
    [firstList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:operator]]];
    [firstList addObjectsFromArray:secondList];
    
    return firstList;
}

- (NSMutableArray *)appendOperationToList:(NSMutableArray *)internTokenList
                           withOperator:(Operator)operator
                        andTokenType:(InternTokenType)tokenType
                            withValue:(NSString *)value
{
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:operator]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:tokenType AndValue:value]];
    
    return internTokenList;
}

- (void)binaryOperatorTest:(NSMutableArray *)internTokens withExpectedResult:(NSString *)result
{
    InternFormulaParser *parser = [[InternFormulaParser alloc] initWithTokens:internTokens];
    FormulaElement *parseTree = [parser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil] doubleValue], [result doubleValue], @"Formula interpretation is not as expected!");
}


- (void)testOperatorChain
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    firstTerm = [self appendOperationToList:firstTerm withOperator:MULT andTokenType:TOKEN_TYPE_NUMBER withValue:@"3"];
    NSMutableArray *secontTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    firstTerm = [self mergeOperatorLists:firstTerm withOperator:MULT andSecondList:secontTerm];

    [self binaryOperatorTest:firstTerm withExpectedResult:@"14"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    secontTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"3" withOperator:MULT secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    firstTerm = [self mergeOperatorLists:firstTerm withOperator:MULT andSecondList:secontTerm];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"13"];
    
}

- (void)testOperatorLeftBinding
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"5" withOperator:MINUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"4"];
    [self appendOperationToList:firstTerm withOperator:MINUS andTokenType:TOKEN_TYPE_NUMBER withValue:@"1"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"100" withOperator:DIVIDE secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"10"];
    [self appendOperationToList:firstTerm withOperator:DIVIDE andTokenType:TOKEN_TYPE_NUMBER withValue:@"10"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
}

- (void)testOperatorPriority
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:MINUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self appendOperationToList:firstTerm withOperator:MULT andTokenType:TOKEN_TYPE_NUMBER withValue:@"2"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"-3"];

}

- (void)testUnaryMinus
{
    
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 42.42");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil]doubleValue], -42.42, @"Formula interpretation is not as expected");
    
}

- (void)testGreaterThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GREATER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
}

- (void)testGreaterOrEqualThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GREATER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
}

- (void)testSmallerThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SMALLER_THAN secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
}

- (void)testSmallerOrEqualThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SMALLER_OR_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
}

- (void)testEqual
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"5"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1.0" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1.0" withOperator:EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.9"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"equalString" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"equalString"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"!`\"§$%&/()=?" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"!`\"§$%&/()=????"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"555.555" withOperator:EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"055.77.77"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
}

- (void)testNotEqual
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"5"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1.0" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1.0" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.9"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"equalString" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"equalString"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"!`\"§$%&/()=?" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"!`\"§$%&/()=????"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"555.555" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"055.77.77"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1,555.555" withOperator:NOT_EQUAL secondTokenType:TOKEN_TYPE_STRING secondValue:@"1555.555"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
}

- (void)testNot
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:LOGICAL_NOT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil]doubleValue], 0.0, @"Formula interpretation is not as expected");
    
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:LOGICAL_NOT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil]doubleValue], 1.0, @"Formula interpretation is not as expected");
    
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:LOGICAL_NOT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_STRING AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil]doubleValue], 0.0, @"Formula interpretation is not as expected");
    
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:LOGICAL_NOT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_STRING AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    XCTAssertEqual([[parseTree interpretRecursiveForSprite:nil]doubleValue], 1.0, @"Formula interpretation is not as expected");
}

- (void)testAnd
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:LOGICAL_AND secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
}

- (void)testOr
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:LOGICAL_OR secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
}

- (void)testPlus
{
    NSString *firstOperand = @"1.3";
    NSString *secondOperand = @"3";
    NSString *result = @"4.3";
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PLUS secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:PLUS secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PLUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"3.14"];
}

- (void)testDivision
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"4.5";
    
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:DIVIDE secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DIVIDE secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:DIVIDE secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DIVIDE secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DIVIDE secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:nil];
}


- (void)testMultiplication
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"18.0";
    
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MULT secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MULT secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MULT secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MULT secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MULT secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:nil];
}

- (void)testMinus
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"7.0";
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MINUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MINUS secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MINUS secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MINUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MINUS secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"-3.14"];
}

@end
