/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
#import "InternFormula.h"
#import "Pocket_Code-Swift.h"

@interface InternFormulaTest : XCTestCase
@property (nonatomic, strong) FormulaManager *formulaManager;
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
    _formulaManager = [[FormulaManager alloc] initWithStageSize:CGSizeZero andLandscapeMode: false];
}

- (void)testInsertRightToCurrentToken
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    InternFormula *internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"0."], @"Enter decimal mark error");
    
    internTokens = [[NSMutableArray alloc]init];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([[[internTokens objectAtIndex:1] getTokenStringValue] isEqualToString:@"0."], @"Enter decimal mark error");
    
    internTokens = [[NSMutableArray alloc]init];
    
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
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
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([externFormulaStringBeforeInput isEqualToString:[internFormula getExternFormulaString]] ,@"Number changed!");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:6 selected:NO];
    [internFormula handleKeyInputWithName:@"0" buttonType:1];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"42.420"] ,@"Append number error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:6 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"42.42"] ,@"Append number error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"4242"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:5 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"4242."] ,@"Append decimal mark error");
    
    internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:0 selected:NO];
    [internFormula handleKeyInputWithName:@"DECIMAL_MARK" buttonType:TOKEN_TYPE_DECIMAL_MARK];
    
    XCTAssertTrue([[[internTokens objectAtIndex:0] getTokenStringValue] isEqualToString:@"0."] ,@"Prepend decimal mark error");
}

- (void)testSelectBrackets
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"COS"]]; // TODO use Function property
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
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"RAND"]]; // TODO use Function property
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

    doubleClickIndex = (int)[kUIFEFunctionRand length];
    
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
    
    [internFormula handleKeyInputWithName:@"0" buttonType:1];
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
    
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
}

- (void)testDeleteInternTokenByIndex
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    NSString *externFormulaString = [internFormula getExternFormulaString];
    
    internFormula.externCursorPosition = -1;
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN AndValue:PlusOperator.tag]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[kUIFEFunctionSine length] + 1) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[kUIFEFunctionSine length] + 2) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[kUIFEFunctionSine length] + 2) selected:NO];
    
    externFormulaString = [internFormula getExternFormulaString];
    
    [internFormula handleKeyInputWithName:@"CLEAR" buttonType:4000];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([[internFormula getExternFormulaString] isEqualToString:externFormulaString], @"ExternFormulaString changed on buggy input!");
    
    [internTokens removeAllObjects];
}

- (void)testSetExternCursorPositionLeftTo
{
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
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
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:PlusOperator.tag]];
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
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[kUIFEFunctionSine length] + 4) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length] + 2) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:((int)[@"sin" length]) selected:YES];
    
    XCTAssertNil(internFormula.internFormulaTokenSelection, @"Selection changed!");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
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
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:@"SIN"]]; // TODO use Function property
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];

    XCTAssertEqual(DO_NOT_MODIFY, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:BrightnessSensor.tag]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    XCTAssertEqual(AM_RIGHT, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
    
    [internTokens removeAllObjects];
    
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_SENSOR AndValue:BrightnessSensor.tag]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    [internFormula setCursorAndSelection:1 selected:NO];
    
    [tokensToReplaceWith removeAllObjects];
    [tokensToReplaceWith addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    
    XCTAssertEqual(AM_RIGHT, [internFormula replaceCursorPositionInternTokenByTokenList:tokensToReplaceWith],@"Do not modify on error");
}

- (void)testLongDecimalNumber
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
    NSString *expectedValue = [NSString stringWithFormat:@"5%@5555", [formatter decimalSeparator]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:expectedValue]];
    
    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([expectedValue isEqualToString:[internFormula getExternFormulaString]], @"The value changed!");
    
    [internTokens removeAllObjects];
    
    expectedValue = [NSString stringWithFormat:@"5%@555555555555555", [formatter decimalSeparator]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:expectedValue]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([expectedValue isEqualToString:[internFormula getExternFormulaString]], @"The value changed!");
    
    [internTokens removeAllObjects];
    
    NSString *inputValue = @"5,5555";
    expectedValue = [NSString stringWithFormat:@"5%@5555", [formatter decimalSeparator]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:inputValue]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([expectedValue isEqualToString:[internFormula getExternFormulaString]], @"The value changed!");
    
    [internTokens removeAllObjects];
    
    inputValue = @"5,55555555555555555555555";
    expectedValue = [NSString stringWithFormat:@"5%@55555555555555555555555", [formatter decimalSeparator]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:inputValue]];
    
    internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
    [internFormula generateExternFormulaStringAndInternExternMapping];
    
    XCTAssertTrue([expectedValue isEqualToString:[internFormula getExternFormulaString]], @"The value changed!");
    
}
@end
