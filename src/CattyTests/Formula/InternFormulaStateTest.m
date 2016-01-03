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
#import "InternFormulaState.h"
#import "InternFormula.h"

@interface InternFormulaStateTest : XCTestCase

@property InternFormulaState *internState;
@property InternFormulaState *internStateToCompareDifferentSelection;
@property InternFormulaState *internStateTokenList1;
@property InternFormulaState *internStateTokenList2;
@property InternFormulaState *internStateListAndSelection;

@end

@implementation InternFormulaStateTest

- (void)setUp {
    [super setUp];
    NSMutableArray *internTokenList = [[NSMutableArray alloc]init];
    NSMutableArray *differentInternTokenList1 = [[NSMutableArray alloc]init];
    NSMutableArray *differentInternTokenList2 = [[NSMutableArray alloc]init];
    InternFormulaTokenSelection *internTokenSelection = [[InternFormulaTokenSelection alloc]initWithTokenSelectionType:USER_SELECTION internTokenSelectionStart:0 internTokenSelectionEnd:1];
    _internState = [[InternFormulaState alloc]initWithList:internTokenList selection:nil andExternCursorPosition:0];
    _internStateToCompareDifferentSelection = [[InternFormulaState alloc]initWithList:internTokenList selection:internTokenSelection andExternCursorPosition:0];
    [differentInternTokenList1 addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER]];
    [differentInternTokenList2 addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_FUNCTION_NAME]];
    _internStateTokenList1 = [[InternFormulaState alloc]initWithList:differentInternTokenList1 selection:nil andExternCursorPosition:0];
    _internStateTokenList2 = [[InternFormulaState alloc]initWithList:differentInternTokenList2 selection:nil andExternCursorPosition:0];
    _internStateListAndSelection = [[InternFormulaState alloc]initWithList:differentInternTokenList1 selection:internTokenSelection andExternCursorPosition:0];
    
}

- (void)testEquals {
    
    XCTAssertFalse([_internState isEqual:_internStateToCompareDifferentSelection], @"TokenSelection is different");
    XCTAssertFalse([_internStateTokenList1 isEqual:_internStateTokenList2], @"TokenList is different");
    XCTAssertFalse([_internStateTokenList1 isEqual:[NSNumber numberWithDouble:1.0f]], @"Object to compare is not instance of InternFormulaState");
    XCTAssertTrue([_internStateListAndSelection isEqual:_internStateListAndSelection], @"FormulaStates should be the same");
}



@end
