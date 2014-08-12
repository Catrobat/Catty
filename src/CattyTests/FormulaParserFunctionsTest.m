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

#import <XCTest/XCTest.h>
#import "Formula.h"
#import "FormulaElement.h"
#import "Operators.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import "SpriteObject.h"
#import "Util.h"
#import <float.h>
#include <math.h>

@interface FormulaParserFunctionsTest : XCTestCase

@end

@implementation FormulaParserFunctionsTest

const double DELTA = 0.01;

- (void) testSin
{
    FormulaElement *parseTree = [self getFormulaElement:SIN value:@"90"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: sin(90)");
    XCTAssertEqual(1, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testCos
{
    FormulaElement *parseTree = [self getFormulaElement:COS value:@"180"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: cos(180)");
    XCTAssertEqual(-1, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testTan
{
    FormulaElement *parseTree = [self getFormulaElement:TAN value:@"180"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: tan(180)");
    XCTAssertEqualWithAccuracy(0, [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
}

- (void) testLn
{
    FormulaElement *parseTree = [self getFormulaElement:LN value:@"2.7182818"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: ln(e)");
    XCTAssertEqualWithAccuracy(1, [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
}

- (void) testLog
{
    FormulaElement *parseTree = [self getFormulaElement:LOG value:@"10"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: log(10)");
    XCTAssertEqual(1, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testPi
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:PI_F]]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: pi");
    XCTAssertEqual(M_PI, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testSqrt
{
    FormulaElement *parseTree = [self getFormulaElement:SQRT value:@"100"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: sqrt(100)");
    XCTAssertEqual(10, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testRandomNaturalNumbers
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:RAND]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: random(0,1)");
    double result = [parseTree interpretRecursiveForSprite:nil];
    XCTAssertTrue(result == 0 || result == 1, @"Formula interpretation is not as expected");
}

- (void) testRound
{
    FormulaElement *parseTree = [self getFormulaElement:ROUND value:@"1.33333"];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: round(1.33333)");
    XCTAssertEqual(1, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testMod
{
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = 1 + offset;
        int divisor = 1 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MOD]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
        FormulaElement *parseTree = [internParser parseFormula];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        XCTAssertEqualWithAccuracy(0, [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 100; offset += 2) {
        int dividend = 3 + offset;
        int divisor = 2 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MOD]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
        FormulaElement *parseTree = [internParser parseFormula];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        XCTAssertEqualWithAccuracy(1, [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = 3 + offset;
        int divisor = 5 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MOD]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
        FormulaElement *parseTree = [internParser parseFormula];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        XCTAssertEqualWithAccuracy(dividend, [parseTree interpretRecursiveForSprite:nil], DELTA, "Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = -3 - offset;
        int divisor = 2 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MOD]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%f", fabs(dividend)]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
        FormulaElement *parseTree = [internParser parseFormula];
        
        XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        XCTAssertEqualWithAccuracy(1 + offset, [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
    }
}

- (void) testAbs
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:ABS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: abs(-1)");
    XCTAssertEqual(1, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testInvalidFunction
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"INVALID_FUNCTION"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNil(parseTree, @"Formula parsed but should not: INVALID_FUNCTION(1)");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Formula error value is not as expected");
}

- (void) testTrue
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:TRUE_F]]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: true");
    XCTAssertEqual(1.0, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testFalse
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:FALSE_F]]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: false");
    XCTAssertEqual(0.0, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testArcsin
{
    FormulaElement *parseTree = [self getFormulaElement:ARCSIN value:[NSString stringWithFormat:@"%f", [Util radiansToDegree:1 - DELTA/1000]]];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: arcsin(1)");
    XCTAssertEqualWithAccuracy([Util degreeToRadians:90], [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
}

- (void) testArccos
{
    FormulaElement *parseTree = [self getFormulaElement:ARCCOS value:[NSString stringWithFormat:@"%f", [Util radiansToDegree:0]]];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: arccos(0)");
    XCTAssertEqualWithAccuracy([Util degreeToRadians:90], [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
}

- (void) testArctan
{
    FormulaElement *parseTree = [self getFormulaElement:ARCTAN value:[NSString stringWithFormat:@"%f", [Util radiansToDegree:1]]];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: arctan(1)");
    XCTAssertEqualWithAccuracy([Util degreeToRadians:45], [parseTree interpretRecursiveForSprite:nil], DELTA, @"Formula interpretation is not as expected");
}

- (void) testMax
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MAX]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: max(3,4)");
    XCTAssertEqual(4, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (void) testMin
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:MIN]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormula];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: min(3,4)");
    XCTAssertEqual(3, [parseTree interpretRecursiveForSprite:nil], @"Formula interpretation is not as expected");
}

- (NSMutableArray*)getFunctionTokenList:(Function)function value:(NSString*)value
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:function]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:value]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    return internTokenList;
}

- (FormulaElement*)getFormulaElement:(Function)function value:(NSString*)value
{
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:[self getFunctionTokenList:function value:value]];
    return [internParser parseFormula];
}

@end
