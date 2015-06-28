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
#import "Operators.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import "SpriteObject.h"
#import <float.h>
#include <math.h>

@interface FormulaParserErrorDetectionTest : XCTestCase

@end

@implementation FormulaParserErrorDetectionTest

- (void)testTooManyOperators
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: - - 42.42");
    XCTAssertEqual(1, internParser.errorTokenIndex, @"Error Token Index is not as expected");
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: +");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Error Token Index is not as expected");
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: + -");
    XCTAssertEqual(1, internParser.errorTokenIndex, @"Error Token Index is not as expected");
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MULT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: * 42.53");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Error Token Index is not as expected");
    
    [internTokenList removeAllObjects];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MINUS]]];
    
    internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: - 42.42 - 42.42 -");
    XCTAssertEqual(5, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

- (void) testOperatorMissing
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.52"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: 42.53 42.42");
    XCTAssertEqual(1, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

- (void) testNumberMissing
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:MULT]]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: * 42.53");
    XCTAssertEqual(0, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

- (void) testRightBracketMissing
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed: (42.53");
    XCTAssertEqual(2, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

- (void) testLefttBracketMissing
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, @"Invalid formula parsed:   42.53)");
    XCTAssertEqual(1, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

- (void) testOutOfBound
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.53"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNil(parseTree, "Invalid formula parsed: 42.53)");
    XCTAssertEqual(1, internParser.errorTokenIndex, @"Error Token Index is not as expected");
}

@end
