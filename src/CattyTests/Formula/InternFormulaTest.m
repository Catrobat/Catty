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

#import "UIKit/UIKit.h"
#import "XCTest/XCTest.h"
#import "InternToken.h"
#import "Operators.h"
#import "InternFormula.h"

@interface InternFormulaTest : XCTestCase

@end

@interface InternFormula (Testing)

@property (nonatomic, strong)InternFormulaTokenSelection *internFormulaTokenSelection;
@property (nonatomic)int externCursorPosition;
@property (nonatomic, strong)ExternInternRepresentationMapping *externInternRepresentationMapping;
@property (nonatomic)int cursorPositionInternTokenIndex;

- (void)setExternCursorPositionLeftTo:(int)internTokenIndex;
- (void)selectCursorPositionInternToken:(TokenSelectionType)internTokenSelectionType;
- (CursorTokenPropertiesAfterModification)replaceCursorPositionInternTokenByTokenList:(NSArray *)internTokensToReplaceWith;

@end

@implementation InternFormulaTest

- (void)setUp {
    [super setUp];
}

- (void)testInsertRightToCurrentToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    InternFormula *internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"0."], @"Enter decimal mark error");
    
    internTokens = [[NSMutableArray alloc]init];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:1] getTokenStringValue] isEqualToString:@"0."], @"Enter decimal mark error");
    
    internTokens = [[NSMutableArray alloc]init];
    
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"0."], @"Enter decimal mark error");

}

- (void)testInsertLeftToCurrentToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    InternFormula *internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    NSString *externFormulaStringBeforeInput = [internFormula getExternFormulaString];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([externFormulaStringBeforeInput isEqualToString:[internFormula getExternFormulaString]] ,@"Number changed!");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:6 selected:NO];
    [internFormula handleKeyInputWithName:@"0" butttonType:1];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"42.420"] ,@"Append number error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:6 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"42.42"] ,@"Append number error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4242"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:5 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"4242."] ,@"Append decimal mark error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" butttonType:413];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"0."] ,@"Prepend decimal mark error");
    
    
}

- (void)testInsertOperaorInNumberToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1234"]];
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:2 selected:NO];
    [internFormula handleKeyInputWithName:@"MULT" butttonType:410];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"12"], @"Insert operator in number token error");
    XCTAssertTrue([[[internTokens objectAtIndex:1] getTokenStringValue] isEqualToString:@"MULT"], @"Insert operator in number token error");
    XCTAssertTrue([[[internTokens objectAtIndex:2] getTokenStringValue] isEqualToString:@"34"], @"Insert operator in number token error");

    
}

- (void)testReplaceFunctionByToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:COS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:ROUND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    int doubleClickIndex = (int)[externFormulaString length];
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual(0, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(9, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
    [internFormula handleKeyInputWithName:@"4" butttonType:5];
    [internFormula handleKeyInputWithName:@"2" butttonType:3];
    
    XCTAssertNil([internFormula getSelection], @"Selection found but should not");
    
    externFormulaString = [internFormula getExternFormulaString];
    doubleClickIndex = (int)[externFormulaString length];
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual([[internFormula getSelection]getStartIndex], 0, @"Selection start index not as expected");
    XCTAssertEqual([[internFormula getSelection]getEndIndex], 0, @"Selection end index not as expected");

    
}

- (void)testReplaceFunctionButKeepParameters
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:COS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:ROUND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    int doubleClickIndex = (int)[externFormulaString length];
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual(0, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(9, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
    [internFormula handleKeyInputWithName:@"RAND" butttonType:506];
    
    XCTAssertEqual(2, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(8, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
    externFormulaString = [internFormula getExternFormulaString];
    doubleClickIndex = (int)[externFormulaString length];
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual(0, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(11, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
    [internFormula handleKeyInputWithName:@"SQRT" butttonType:505];
    
    externFormulaString = [internFormula getExternFormulaString];
    doubleClickIndex = (int)[externFormulaString length];
    
    XCTAssertEqual(2, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(8, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual(0, [[internFormula getSelection]getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(9, [[internFormula getSelection]getEndIndex], @"Selection end index not as expected");
    
}

- (void)testSelectBrackets
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:COS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    int doubleClickIndex = (int)[externFormulaString length];
    
    int offsetRight = 0;
    
    while (offsetRight < 2) {
        [internFormula setCursorAndSelection:(doubleClickIndex - offsetRight) selected:YES];
        XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
        XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
        offsetRight++;
    }
    
    [internFormula setCursorAndSelection:(doubleClickIndex - offsetRight) selected:YES];
    
    XCTAssertEqual(1, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(4, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex = 0;
    int offsetLeft = 0;
    
    while (offsetLeft < 2) {
        [internFormula setCursorAndSelection:(doubleClickIndex + offsetLeft) selected:YES];
        XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
        XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
        offsetLeft++;
    }
    
    [internFormula setCursorAndSelection:(doubleClickIndex + offsetLeft) selected:YES];
    
    XCTAssertEqual(1, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(4, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
}

- (void)testSelectFunctionAndSingleTab
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:RAND]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula setCursorAndSelection:0 selected:NO];
    XCTAssertEqual(0, [[internFormula getSelection]getStartIndex], @"Single Tab before Funtion fail");
    
    int doubleClickIndex = (int)[externFormulaString length];
    int offsetRight = 0;
    
    while (offsetRight < 2) {
        [internFormula setCursorAndSelection:(doubleClickIndex - offsetRight) selected:YES];
        XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
        XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
        offsetRight++;
    }
    
    [internFormula setCursorAndSelection:(doubleClickIndex - offsetRight) selected:YES];
    
    XCTAssertEqual(4, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(4, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex = 0;
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");

    doubleClickIndex = (int)[@"rand" length];
    
    int singleClickIndex = doubleClickIndex;
    
    [internFormula setCursorAndSelection:singleClickIndex selected:NO];
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex++;
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex += (int)[@" 42.42 " length];
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex++;
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    XCTAssertEqual(0, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(5, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
    doubleClickIndex++;
    
    [internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    XCTAssertEqual(4, [[internFormula getSelection] getStartIndex], @"Selection start index not as expected");
    XCTAssertEqual(4, [[internFormula getSelection] getEndIndex], @"Selection end index not as expected");
    
}

- (void)testReplaceSelection
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula setCursorAndSelection:1 selected:YES];
    
    int tokenSelectionStartIndex = -1;
    int tokenSelectionEndIndex = 3;
    
    InternFormulaTokenSelection *internFormulaTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:USER_SELECTION
                                                                                                    internTokenSelectionStart:tokenSelectionStartIndex
                                                                                                      internTokenSelectionEnd:tokenSelectionEndIndex];
    
    internFormula.internFormulaTokenSelection = internFormulaTokenSelection;
    
    [internFormula handleKeyInputWithName:@"0" butttonType:1];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
}

- (void)testHandleDeletion
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    NSString *externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula setCursorAndSelection:0 selected:NO];
    
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");

}

- (void)testDeleteInternTokenByIndex
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    NSString *externFormulaString = [internFormula getExternFormulaString];
    
    internFormula.externCursorPosition = -1;
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN AndValue:[Operators getName:PLUS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 1) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 2) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 2) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" butttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];

}

- (void)testSetExternCursorPositionLeftTo
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    ExternInternRepresentationMapping *externInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    
    int externCursorPositionBeforeMethodCall = [internFormula getExternCursorPosition];
    internFormula.externInternRepresentationMapping = externInternRepresentationMapping;
    [internFormula setExternCursorPositionLeftTo:1];
    
    XCTAssertEqual(externCursorPositionBeforeMethodCall, [internFormula getExternCursorPosition], @"Extern cursor position changed!");
    
}

- (void)testSetExternCursorPositionRightTo
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    int externCursorPositionBeforeMethodCall = [internFormula getExternCursorPosition];
    
    [internFormula setExternCursorPositionRightTo:1];
    
    XCTAssertEqual(externCursorPositionBeforeMethodCall, [internFormula getExternCursorPosition], @"Extern cursor position changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    [internFormula setExternCursorPositionRightTo:3];
    
    XCTAssertEqual(13, [internFormula getExternCursorPosition], @"Extern cursor position changed!");
    
    ExternInternRepresentationMapping *externInternRepresentationMapping = [[ExternInternRepresentationMapping alloc]init];
    internFormula.externInternRepresentationMapping = externInternRepresentationMapping;
    
    externCursorPositionBeforeMethodCall = [internFormula getExternCursorPosition];
    [internFormula setExternCursorPositionRightTo:2];
    
    XCTAssertEqual(externCursorPositionBeforeMethodCall, [internFormula getExternCursorPosition], @"Extern cursor position changed!");
}

- (void)testSelectCursorPositionInternTokenOnError
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    
    [internFormula selectCursorPositionInternToken:USER_SELECTION];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
}

- (void)testSelectCursorPositionInternToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 4) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 2) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length]) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
}

- (void)testreplaceCursorPositionInternTokenByTokenList
{
    NSMutableArray *tokensToReplaceWith = [[NSMutableArray alloc]init];
    [tokensToReplaceWith addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:YES];
    
    internFormula.cursorPositionInternTokenIndex = -1;
    
    XCTAssertEqual(DO_NOT_MODIFY, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [tokensToReplaceWith removeAllObjects];
    [tokensToReplaceWith addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_PERIOD]];

    XCTAssertEqual(DO_NOT_MODIFY, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on when second period token is inserted");
    
    [internTokens removeAllObjects];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4242"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    internFormula.cursorPositionInternTokenIndex = -1;
    
    XCTAssertEqual(DO_NOT_MODIFY, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];

    XCTAssertEqual(DO_NOT_MODIFY, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:[SensorManager stringForSensor:OBJECT_BRIGHTNESS]]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    XCTAssertEqual(AM_RIGHT, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:[SensorManager stringForSensor:OBJECT_BRIGHTNESS]]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    [tokensToReplaceWith removeAllObjects];
    [tokensToReplaceWith addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    
    XCTAssertEqual(AM_RIGHT, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
}
























@end
