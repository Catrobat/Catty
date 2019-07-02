/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "Pocket_Code-Swift.h"

@interface FormulaParserOperatorsTest : XCTestCase
@property (nonatomic, strong) id<FormulaManagerProtocol> formulaManager;
@property (nonatomic, strong) id<FormulaInterpreterProtocol> interpreter;
@end

@implementation FormulaParserOperatorsTest

- (void)setUp {
    [super setUp];
    self.formulaManager = (id<FormulaManagerProtocol>)[[FormulaManager alloc] initWithSceneSize:[Util screenSize:true]];
    self.interpreter = (id<FormulaInterpreterProtocol>)self.formulaManager;
}

- (NSMutableArray *)buildBinaryOperator:(InternTokenType)firstTokenType
                             firstValue:(NSString *)firstValue
                           withOperator:(NSString*)operatorTag
                        secondTokenType:(InternTokenType)secondTokenType
                            secondValue:(NSString *)secondValue
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:firstTokenType AndValue:firstValue]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:operatorTag]];
    [internTokens addObject:[[InternToken alloc] initWithType:secondTokenType AndValue:secondValue]];

    return internTokens;
}

- (NSMutableArray *)mergeOperatorLists:(NSMutableArray *)firstList
                           withOperator:(NSString*)operatorTag
                        andSecondList:(NSMutableArray *)secondList
{
    [firstList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:operatorTag]];
    [firstList addObjectsFromArray:secondList];
    
    return firstList;
}

- (NSMutableArray *)appendOperationToList:(NSMutableArray *)internTokenList
                           withOperator:(NSString*)operatorTag
                        andTokenType:(InternTokenType)tokenType
                            withValue:(NSString *)value
{
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:operatorTag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:tokenType AndValue:value]];
    
    return internTokenList;
}

- (void)binaryOperatorTest:(NSMutableArray *)internTokens withExpectedResult:(NSString *)result
{
    InternFormulaParser *parser = [[InternFormulaParser alloc] initWithTokens:internTokens andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [parser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual([self.interpreter interpretInteger:formula forSpriteObject:[SpriteObject new]], [result intValue], @"Formula interpretation is not as expected!");
}

- (void)testOperatorChain
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    firstTerm = [self appendOperationToList:firstTerm withOperator:MultOperator.tag andTokenType:TOKEN_TYPE_NUMBER withValue:@"3"];
    NSMutableArray *secontTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    firstTerm = [self mergeOperatorLists:firstTerm withOperator:MultOperator.tag andSecondList:secontTerm];

    [self binaryOperatorTest:firstTerm withExpectedResult:@"14"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    secontTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"3" withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    firstTerm = [self mergeOperatorLists:firstTerm withOperator:MultOperator.tag andSecondList:secontTerm];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"13"];
    
}

- (void)testOperatorLeftBinding
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"5" withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"4"];
    [self appendOperationToList:firstTerm withOperator:MinusOperator.tag andTokenType:TOKEN_TYPE_NUMBER withValue:@"1"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"100" withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"10"];
    [self appendOperationToList:firstTerm withOperator:DivideOperator.tag andTokenType:TOKEN_TYPE_NUMBER withValue:@"10"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
}

- (void)testOperatorPriority
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self appendOperationToList:firstTerm withOperator:MultOperator.tag andTokenType:TOKEN_TYPE_NUMBER withValue:@"2"];
    
    [self binaryOperatorTest:firstTerm withExpectedResult:@"-3"];
}

- (void)testUnaryMinus
{
    
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 42.42");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual([self.interpreter interpretDouble:formula forSpriteObject:[SpriteObject new]], -42.42, @"Formula interpretation is not as expected");
}

- (void)testGreaterThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GreaterThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
}

- (void)testGreaterOrEqualThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:GreaterOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
}

- (void)testSmallerThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SmallerThanOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
}

- (void)testSmallerOrEqualThan
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"2" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"2"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"2" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:SmallerOrEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"2"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
}

- (void)testEqual
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"5"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1.0" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1.0" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.9"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"equalString" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"equalString"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"!`\"§$%&/()=?" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"!`\"§$%&/()=????"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"555.555" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"055.77.77"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
}

- (void)testNotEqual
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"5"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1.0" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1.0" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1.9"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"equalString" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"equalString"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1.0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"!`\"§$%&/()=?" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"!`\"§$%&/()=????"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"555.555" withOperator:NotEqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"055.77.77"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1,555.555" withOperator:EqualOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1555.555"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
}

- (void)testNot
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:[SpriteObject new]]);
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual([self.interpreter interpretDouble:formula forSpriteObject:[SpriteObject new]], 1.0);
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_STRING AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:[SpriteObject new]]);
    
    internTokenList = [[NSMutableArray alloc]init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_STRING AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly!");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:[SpriteObject new]]);
}

- (void)testAnd
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:AndOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
}

- (void)testOr
{
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"0"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"1" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"1"];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"1"];
    
    
    NSMutableArray *secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"0" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"1"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
    
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:@"0" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"0"];
    
    secondTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:@"1" withOperator:OrOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:@"0"];
    [self binaryOperatorTest:secondTerm withExpectedResult:@"1"];
}

- (void)testPlus
{
    NSString *firstOperand = @"1.3";
    NSString *secondOperand = @"3";
    NSString *result = @"4.3";
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:PlusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"NaN"];
}

- (void)testDivision
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"4.5";
    
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:DivideOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:nil];
}


- (void)testMultiplication
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"18.0";
    
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MultOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:nil];
}

- (void)testMinus
{
    NSString *firstOperand = @"9.0";
    NSString *secondOperand = @"2";
    NSString *result = @"7.0";
    
    NSMutableArray *firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_NUMBER firstValue:firstOperand withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_STRING secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:result];
    
    firstOperand = @"NotANumber";
    secondOperand = @"3.14";
    
    firstTerm = [self buildBinaryOperator:TOKEN_TYPE_STRING firstValue:firstOperand withOperator:MinusOperator.tag secondTokenType:TOKEN_TYPE_NUMBER secondValue:secondOperand];
    [self binaryOperatorTest:firstTerm withExpectedResult:@"NaN"];
}

@end
