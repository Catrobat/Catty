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

#import <XCTest/XCTest.h>
#import "Formula.h"
#import "FormulaElement.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import "SpriteObject.h"
#import <float.h>
#include <math.h>
#import "Pocket_Code-Swift.h"

@interface FormulaParserTest : XCTestCase
@property (nonatomic, strong) id<FormulaManagerProtocol> formulaManager;
@property (nonatomic, strong) id<FormulaInterpreterProtocol> interpreter;
@property (nonatomic, strong) SpriteObject *object;
@end

@implementation FormulaParserTest

- (void)setUp {
    [super setUp];
    self.formulaManager = (id<FormulaManagerProtocol>)[[FormulaManager alloc] initWithSceneSize:[Util screenSize:true]];
    self.interpreter = (id<FormulaInterpreterProtocol>)self.formulaManager;
    self.object = [SpriteObject new];
}

- (void) testNumbers {
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.0"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1.0");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@""]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Formula is not parsed correctly: <empty number> {}");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Parser error value not as expected");
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"."]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Formula is not parsed correctly: .");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Parser error value not as expected");
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@".1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Formula is not parsed correctly: .1");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Parser error value not as expected");
    [internTokenList removeAllObjects];
}

- (void) testLogicalOperators
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:GreaterThanOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 2 > 1");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:GreaterThanOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 > 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:GreaterOrEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 >= 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:GreaterOrEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 >= 2");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:SmallerThanOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 < 2");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:SmallerThanOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 < 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:SmallerOrEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 <= 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:SmallerOrEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 2 <= 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:EqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 = 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:EqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 2 = 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 2 != 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotEqualOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: 1 != 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:AndOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: NOT 0 AND 1");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:AndOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: NOT 1 OR 0");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
    
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:OrOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: NOT 0 OR 0");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];

    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:NotOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:AndOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: NOT 0 AND 0");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    [internTokenList removeAllObjects];
}

- (void) testUnaryMinus
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];

    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 42.42");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(-42.42, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

- (void) testOperatorPriority
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];

    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  1 - 2 x 2");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(-3.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

- (void) testOperatorLeftBinding
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"5"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  5 - 4 - 1");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    
    internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"100"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:DivideOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"10"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:DivideOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"10"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  100 ÷ 10 ÷ 10");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(1.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

- (void) testOperatorChain
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"POWER"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  (1 + 2 × 3) ^ 2 + 1");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(50.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    
    internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"POWER"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  1 + 2 ^ (3 * 2)");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(65.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

- (void) testBracket
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];

    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  (1+2) x (1+2)");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(9.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    
    internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
        [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"POWER"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly:  -(1^2)--(-1--2)");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

- (void) testEmptyInput
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Formula is not parsed correctly: EMPTY FORMULA {}");
    XCTAssertEqual(FORMULA_PARSER_NO_INPUT, internParser.errorTokenIndex, @"Formula error value not as expected");
}

- (void) testFuctionalAndSimpleBracketsCorrection
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"ABS"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"5"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"10"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];

    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: abs(2 * (5 - 10))");
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(10.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MultOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"2"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"COS"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"0"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, "Formula is not parsed correctly: 3 * (2 + cos(0)) ");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(9.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]]; // TODO use Function property
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"MOD"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"5"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"3"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: mod( 1 , mod( 1 , mod( 5 , ( 3 )))) ");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertEqual(0.0, [self.interpreter interpretDouble:formula forSpriteObject:self.object]);
}

@end
