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
#import "InternFormula.h"
#import "InternToken.h"
#import "Operators.h"

@interface InternFormulaTests : XCTestCase

@end

@implementation InternFormulaTests

//-(void)testInsertRightToCurrentToken
//{
//    NSMutableArray *internTokens = [[NSMutableArray alloc]init];
//    [internTokens addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_OPERATOR AndValue:[Operators getName:PLUS]]];
//    InternFormula *internFormula = [[InternFormula alloc]initWithInternTokenList:internTokens];
//    [internFormula generateExternFormulaStringAndInternExternMapping];
//    [internFormula setCursorAndSelection:0 selected:NO];
//    [internFormula handleKeyInputWithName:nil butttonType:DECIMAL_MARK];
//    
//    XCTAssertTrue([[[internTokens objectAtIndex:0]getTokenStringValue]isEqualToString:@"0."]
//                  , @"Enter decimal mark error");
//}

@end
