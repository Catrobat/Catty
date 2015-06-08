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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "InternFormula.h"

@interface InternFormulaTokenSelectionTest : XCTestCase

@property(strong, nonatomic)InternFormula *internFormula;

@end

@interface InternFormulaTokenSelection (Testing)

@property (nonatomic)TokenSelectionType tokenSelectionType;
@property (nonatomic)NSInteger internTokenSelectionStart;
@property (nonatomic)NSInteger internTokenSelectionEnd;

- (id)mutableCopyWithZone:(NSZone *)zone;

@end

@implementation InternFormulaTokenSelectionTest

- (void)setUp {
    [super setUp];
    NSMutableArray *internTokens = [[NSMutableArray alloc] init];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME AndValue:[Functions getName:SIN]]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"42.42"]];
    [internTokens addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    _internFormula = [[InternFormula alloc] initWithInternTokenList:internTokens];
    [_internFormula generateExternFormulaStringAndInternExternMapping];
    int doubleClickIndex = (int)[[_internFormula getExternFormulaString] length];
    [_internFormula setCursorAndSelection:doubleClickIndex selected:YES];
    
}

- (void)testReplaceFunctionByToken
{
    XCTAssertEqual(0, [[self.internFormula getSelection]getStartIndex],@"Selection start index not as expected");
    XCTAssertEqual(3, [[self.internFormula getSelection]getEndIndex],@"Selection end index not as expected");
    
    InternFormulaTokenSelection *tokenSelection = [self.internFormula getSelection];
    InternFormulaTokenSelection *tokenSelectionDeepCopy = [tokenSelection mutableCopyWithZone:nil];
    
    XCTAssertTrue([tokenSelection equals:tokenSelectionDeepCopy], @"Deep copy of InternFormulaTokenSelection failed");
    
    tokenSelectionDeepCopy.tokenSelectionType = PARSER_ERROR_SELECTION;
    
    XCTAssertFalse([tokenSelectionDeepCopy equals:tokenSelection], @"Equal error in InternFormulaTokenSelection");
    
    tokenSelectionDeepCopy = [tokenSelection mutableCopyWithZone:nil];
    tokenSelectionDeepCopy.internTokenSelectionStart = -1;
    
    XCTAssertFalse([tokenSelectionDeepCopy equals:tokenSelection], @"Equal error in InternFormulaTokenSelection");
    
    tokenSelectionDeepCopy = [tokenSelection mutableCopyWithZone:nil];
    tokenSelectionDeepCopy.internTokenSelectionEnd = -1;
    
    XCTAssertFalse([tokenSelectionDeepCopy equals:tokenSelection], @"Equal error in InternFormulaTokenSelection");
    
    XCTAssertFalse([tokenSelectionDeepCopy equals:[NSNumber numberWithInt:1]], @"Equal error in InternFormulaTokenSelection");

}
























@end
