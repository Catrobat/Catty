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
#import "InternFormulaParserException.h"

@interface InternFormulaUtilsTest : XCTestCase

@end

@implementation InternFormulaUtilsTest

- (void)setUp {
    [super setUp];
}

- (void)testGetFunctionByFunctionBracketCloseOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketClose:nil index:0], @"End function-bracket index is 0");
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketClose:internTokens index:2], @"End function-bracket index is InternTokenListSize");
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketClose:internTokens index:1], @"No function name before brackets");

    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketClose:internTokens index:2], @"No function name before brackets");
}

- (void)testGetFunctionByParameterDelimiter
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:RAND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:RAND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:RAND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];

    NSArray *functionTokens = [InternFormulaUtils getFunctionByParameterDelimiter:internTokens index:8];
    XCTAssertEqual([functionTokens count], [internTokens count], @"GetFunctionByParameter wrong function returned");
    
    for(int index = 0; index < [functionTokens count]; index++)
    {
        if([[functionTokens objectAtIndex:index] getTokenStringValue] != nil || [[internTokens objectAtIndex:index] getTokenStringValue] != nil)
        {
            XCTAssertTrue([[functionTokens objectAtIndex:index] getInternTokenType] == [[internTokens objectAtIndex:index] getInternTokenType]
                          && [[[functionTokens objectAtIndex:index] getTokenStringValue] isEqualToString:[[internTokens objectAtIndex:index] getTokenStringValue]],
                          @"GetFunctionByParameter wrong function returned");
        }
    }

}

- (void)testGetFunctionByParameterDelimiterOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils getFunctionByParameterDelimiter:nil index:0], @"Function delimiter index is 0");
    XCTAssertNil([InternFormulaUtils getFunctionByParameterDelimiter:internTokens index:2], @"End delimiter index is InternTokenListSize");
    XCTAssertNil([InternFormulaUtils getFunctionByParameterDelimiter:internTokens index:1], @"No function name before brackets");

    [internTokens removeAllObjects];

    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils getFunctionByParameterDelimiter:internTokens index:2], @"No function name before brackets");
}

- (void)testGetFunctionByFunctionBracketOpenOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketOpen:nil index:0], @"Function bracket index is 0");
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketOpen:internTokens index:2], @"End delimiter index is InternTokenListSize");
    XCTAssertNil([InternFormulaUtils getFunctionByFunctionBracketOpen:internTokens index:1], @"No function name before brackets");


}

- (void)testGenerateTokenListByBracketOpenOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils generateTokenListByBracketOpen:internTokens index:3], @"Index is >= list.size");
    XCTAssertNil([InternFormulaUtils generateTokenListByBracketOpen:internTokens index:0], @"Index Token is not bracket open");

    
}

- (void)testGenerateTokenListByBracketOpen
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    NSArray *functionTokens = [InternFormulaUtils generateTokenListByBracketOpen:internTokens index:0];
    XCTAssertEqual([functionTokens count], [internTokens count], @"GetFunctionByParameter wrong function returned");
    
    for(int index = 0; index < [functionTokens count]; index++)
    {
        if([[functionTokens objectAtIndex:index] getTokenStringValue] != nil || [[internTokens objectAtIndex:index] getTokenStringValue] != nil)
        {
            XCTAssertTrue([[functionTokens objectAtIndex:index] getInternTokenType] == [[internTokens objectAtIndex:index] getInternTokenType]
                          && [[[functionTokens objectAtIndex:index] getTokenStringValue] isEqualToString:[[internTokens objectAtIndex:index] getTokenStringValue]],
                          @"GetFunctionByParameter wrong function returned");
        }
    }
}

- (void)testGenerateTokenListByBracketCloseOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    XCTAssertNil([InternFormulaUtils generateTokenListByBracketClose:internTokens index:3], @"Index is >= list.size");
    XCTAssertNil([InternFormulaUtils generateTokenListByBracketClose:internTokens index:0], @"Index Token is not bracket close");
}

- (void)testGenerateTokenListByBracketClose
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];

    NSArray *functionTokens = [InternFormulaUtils generateTokenListByBracketClose:internTokens index:8];
    XCTAssertEqual([functionTokens count], [internTokens count], @"GetFunctionByParameter wrong function returned");
    
    for(int index = 0; index < [functionTokens count]; index++)
    {
        if([[functionTokens objectAtIndex:index] getTokenStringValue] != nil || [[internTokens objectAtIndex:index] getTokenStringValue] != nil)
        {
            XCTAssertTrue([[functionTokens objectAtIndex:index] getInternTokenType] == [[internTokens objectAtIndex:index] getInternTokenType]
                          && [[[functionTokens objectAtIndex:index] getTokenStringValue] isEqualToString:[[internTokens objectAtIndex:index] getTokenStringValue]],
                          @"GetFunctionByParameter wrong function returned");
        }
    }
}

- (void)testGetFunctionParameterInternTokensAsListsOnErrorInput
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertNil([InternFormulaUtils getFunctionParameterInternTokensAsLists:nil], @"InternToken list is null");
    XCTAssertNil([InternFormulaUtils getFunctionParameterInternTokensAsLists:internTokens], @"InternToken list is too small");

    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertNil([InternFormulaUtils getFunctionParameterInternTokensAsLists:internTokens], @"First token is not a FunctionName Token");

    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];

    XCTAssertNil([InternFormulaUtils getFunctionParameterInternTokensAsLists:internTokens], @"Second token is not a Bracket Token");

}

- (void)testIsFunction
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertFalse([InternFormulaUtils isFunction:internTokens], @"List contains more elements than just ONE function");

}

- (void)testgetFirstInternTokenTypeOnErrorInput
{
    NSArray *internTokens = [[NSArray alloc] init];
    XCTAssertThrowsSpecific([InternFormulaUtils getFirstInternTokenType:nil], InternFormulaParserException, @"Token list is null");
    XCTAssertThrowsSpecific([InternFormulaUtils getFirstInternTokenType:internTokens], InternFormulaParserException, @"Token list is null");

}

- (void)testisPeriodTokenOnError
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertFalse([InternFormulaUtils isPeriodToken:nil], @"Shoult return false, when parameter is null");
    XCTAssertFalse([InternFormulaUtils isPeriodToken:internTokens], @"List size not equal to 1");
}

- (void)testisFunctionTokenOnError
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];

    XCTAssertFalse([InternFormulaUtils isFunctionToken:nil], @"Shoult return false on null");
    XCTAssertFalse([InternFormulaUtils isFunctionToken:internTokens], @"Shoult return false, when List size < 1");

}

- (void)testIsNumberOnError
{
    XCTAssertFalse([InternFormulaUtils isNumberToken:nil], @"Should return false if parameter is null");
}

- (void)testReplaceFunctionButKeepParametersOnError
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];

    XCTAssertNil([InternFormulaUtils replaceFunctionButKeepParameters:nil replaceWith:nil], @"Should return null if functionToReplace is null");
    XCTAssertEqual([InternFormulaUtils replaceFunctionButKeepParameters:internTokens replaceWith:internTokens], internTokens, @"Function without params whould return null");
}

- (void)testGetFunctionParameterCountOnError
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertEqual(0, [InternFormulaUtils getFunctionParameterCount:nil], @"Should return 0 if List is null");
    XCTAssertEqual(0, [InternFormulaUtils getFunctionParameterCount:internTokens], @"Should return 0 if List size < 4");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertEqual(0, [InternFormulaUtils getFunctionParameterCount:internTokens], @"Should return 0 if first Token is not a function name token");

    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];

    XCTAssertEqual(0, [InternFormulaUtils getFunctionParameterCount:internTokens], @"Should return 0 if second Token is not a function bracket open token");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    
    XCTAssertEqual(0, [InternFormulaUtils getFunctionParameterCount:internTokens], @"Should return 0 if function list does not contain a bracket close token");
}

- (void)testDeleteNumberByOffset
{
    InternToken *numberToken = [[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1.1"];
    
    XCTAssertTrue([InternFormulaUtils deleteNumberByOffset:numberToken numberOffset:0] == numberToken, @"Wrong character deleted");
}










@end
