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

#import <XCTest/XCTest.h>
#import "Formula.h"
#import "FormulaElement.h"
#import "InternToken.h"
#import "Operators.h"
#import "InternFormulaParser.h"

@interface FormulaTest : XCTestCase

@end

@implementation FormulaTest

- (void) testIsSingleNumberFormula
{
    Formula *formula = [[Formula alloc] initWithInteger:1];
    NSDebug(@"Formula display string %@", [formula getDisplayString]);
    XCTAssertTrue([formula isSingleNumberFormula], @"Formula should be single number formula");

    formula = [[Formula alloc] initWithDouble:1.0];
    XCTAssertTrue([formula isSingleNumberFormula], @"Formula should be single number formula");
    
    formula = [[Formula alloc] initWithFloat:1.0];
    XCTAssertTrue([formula isSingleNumberFormula], @"Formula should be single number formula");
    
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    
    InternToken *token = [[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]];
    InternToken *tokenNumber = [[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"];
    [internTokenList addObject:token];
    [internTokenList addObject:tokenNumber];

    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 1");
    XCTAssertEqual(-1, [[parseTree interpretRecursiveForSprite:nil] doubleValue], @"Formula interpretation is not as expected");
    [internTokenList removeAllObjects];
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertTrue([formula isSingleNumberFormula], @"Formula should be single number formula");
    
    token = [[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]];
    tokenNumber = [[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.0"];
    [internTokenList addObject:token];
    [internTokenList addObject:tokenNumber];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 1");
    XCTAssertEqual(-1, [[parseTree interpretRecursiveForSprite:nil] doubleValue], @"Formula interpretation is not as expected");
    [internTokenList removeAllObjects];

    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertTrue([formula isSingleNumberFormula], @"Formula should be single number formula");

    token = [[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]];
    tokenNumber = [[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.0"];
    InternToken *secondToken = [[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]];
    InternToken *secondNumber = [[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.0"];
    [internTokenList addObject:token];
    [internTokenList addObject:tokenNumber];
    [internTokenList addObject:secondToken];
    [internTokenList addObject:secondNumber];

    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: - 1 - 1");
    XCTAssertEqual(-2, [[parseTree interpretRecursiveForSprite:nil] doubleValue], @"Formula interpretation is not as expected");
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertFalse([formula isSingleNumberFormula], "Should NOT be a single number formula");
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:ROUND]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.1111"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: round(1.1111)");
    XCTAssertEqual(1, [[parseTree interpretRecursiveForSprite:nil] doubleValue], "Formula interpretation is not as expected");
    [internTokenList removeAllObjects];
    
    formula = [[Formula alloc] initWithFormulaElement:parseTree];
    XCTAssertFalse([formula isSingleNumberFormula], "Should NOT be a single number formula");
}

@end
