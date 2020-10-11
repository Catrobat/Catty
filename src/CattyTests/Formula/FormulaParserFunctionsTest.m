/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import "SpriteObject.h"
#import "Util.h"
#import <float.h>
#include <math.h>
#import "Pocket_Code-Swift.h"

@interface FormulaParserFunctionsTest : XCTestCase
@property (nonatomic, strong) FormulaManager* formulaManager;
@property (nonatomic, strong) id<FormulaInterpreterProtocol> interpreter;
@property (nonatomic, strong) SpriteObject *spriteObject;
@end

@implementation FormulaParserFunctionsTest

#define EPSILON 0.01

- (void)setUp
{
    self.formulaManager = [[FormulaManager alloc] initWithStageSize:[Util screenSize:true] andLandscapeMode: false];
    self.interpreter = (id<FormulaInterpreterProtocol>)self.formulaManager;
    self.spriteObject = [[SpriteObject alloc] init];
}

- (void) testSin
{
    Formula *formula = [self getFormula:@"SIN" value:@"90"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: sin(90)");
    XCTAssertEqual(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testCos
{
    Formula *formula = [self getFormula:@"COS" value:@"180"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: cos(180)");
    XCTAssertEqual(-1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testTan
{
    Formula *formula = [self getFormula:@"TAN" value:@"180"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: tan(180)");
    XCTAssertEqualWithAccuracy(0, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
}

- (void) testLn
{
    Formula *formula = [self getFormula:@"LN" value:@"2.7182818"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: ln(e)");
    XCTAssertEqualWithAccuracy(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
}

- (void) testLog
{
    Formula *formula = [self getFormula:@"LOG" value:@"10"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: log(10)");
    XCTAssertEqual(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testPi
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"PI"]]; // TODO use Function property
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: pi");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(M_PI, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testSqrt
{
    Formula *formula = [self getFormula:@"SQRT" value:@"100"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: sqrt(100)");
    XCTAssertEqual(10, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testExp
{
    Formula *formula = [self getFormula:@"EXP" value:@"3"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: exp(0)");
    XCTAssertEqualWithAccuracy(20.08f, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], 0.1f, @"Formula interpretation is not as expected");
}

- (void) testRandomNaturalNumbers
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"RAND"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: random(0,1)");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    double result = [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject];
    XCTAssertTrue(result == 0 || result == 1, @"Formula interpretation is not as expected");
}

- (void) testRound
{
    Formula *formula = [self getFormula:@"ROUND" value:@"1.33333"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: round(1.33333)");
    XCTAssertEqual(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testMod
{
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = 1 + offset;
        int divisor = 1 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
        FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        
        Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
        XCTAssertEqualWithAccuracy(0, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 100; offset += 2) {
        int dividend = 3 + offset;
        int divisor = 2 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
        FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        
        Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
        XCTAssertEqualWithAccuracy(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = 3 + offset;
        int divisor = 5 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", dividend]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
        FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
        
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        
        Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
        XCTAssertEqualWithAccuracy(dividend, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, "Formula interpretation is not as expected");
    }
    
    for (int offset = 0; offset < 10; offset += 1) {
        int dividend = -3 - offset;
        int divisor = 2 + offset;
        
        NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", abs(dividend)]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:[NSString stringWithFormat:@"%i", divisor]]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
        
        InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
        FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
        
        XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: mod(%i, %i)", dividend, divisor);
        
        Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
        XCTAssertEqualWithAccuracy(1 + offset, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
    }
}

- (void) testAbs
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"ABS"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: abs(-1)");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testInvalidFunction
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"INVALID_FUNCTION"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Formula parsed but should not: INVALID_FUNCTION(1)");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Formula error value is not as expected");
}

- (void) testTrue
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"TRUE"]]; // TODO use Function property
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: true");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testFalse
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"FALSE"]]; // TODO use Function property
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: false");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testArcsin
{
    Formula *formula = [self getFormula:@"ASIN" value:@"1"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: arcsin(1)");
    XCTAssertEqualWithAccuracy(90, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
}

- (void) testArccos
{
    Formula *formula = [self getFormula:@"ACOS" value:@"0"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: arccos(0)");
    XCTAssertEqualWithAccuracy(90, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
}

- (void) testArctan
{
    Formula *formula = [self getFormula:@"ATAN" value:@"1"]; // TODO use Function property
    XCTAssertNotNil(formula, @"Formula is not parsed correctly: arctan(1)");
    XCTAssertEqualWithAccuracy(45, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Formula interpretation is not as expected");
}

- (void) testMax
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MAX"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: max(3,4)");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(4, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (void) testMin
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MIN"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: min(3,4)");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(3, [self.interpreter interpretDouble:formula forSpriteObject:self.spriteObject], @"Formula interpretation is not as expected");
}

- (Formula*)getFormula:(NSString*)tag value:(NSString*)value
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:value]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    return [[Formula alloc] initWithFormulaElement:[internParser parseFormulaForSpriteObject:nil]];
}

@end
