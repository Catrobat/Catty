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
#import "SpriteObject.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaParserException.h"
#import <float.h>
#import <math.h>
#import "Pocket_Code-Swift.h"

@interface FormulaElementTest : XCTestCase
@property(nonatomic, strong) id<FormulaManagerProtocol> formulaManager;
@end

@implementation FormulaElementTest

- (void)setUp
{
    [super setUp];
    self.formulaManager = (id<FormulaManagerProtocol>)[[FormulaManager alloc] initWithSceneSize:[Util screenSize:true]];
}

- (void)testGetInternTokenList
{
    NSMutableArray *internTokenList = [[NSMutableArray alloc] init];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_OPERATOR AndValue:MinusOperator.tag]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_NUMBER AndValue:@"1"]];
    [internTokenList addObject:[[InternToken alloc] initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    
    InternFormulaParser *internParser = [[InternFormulaParser alloc] initWithTokens:internTokenList andFormulaManager:self.formulaManager];
    FormulaElement *parseTree = [internParser parseFormulaForSpriteObject:nil];
    
    XCTAssertNotNil(parseTree, @"Formula is not parsed correctly: ( - 1 )");
    
    NSMutableArray *internTokenListAfterConversion = [parseTree getInternTokenList];
    XCTAssertEqual([internTokenListAfterConversion count], [internTokenList count], @"Generate InternTokenList from Tree error");
    
    for (int index = 0; index < [internTokenListAfterConversion count]; index++) {
        XCTAssertTrue([((InternToken*)[internTokenListAfterConversion objectAtIndex:index]) isEqualTo:((InternToken*)[internTokenList objectAtIndex:index])],
                      @"Generate InternTokenList from Tree error");
    }
    
    [internTokenList removeAllObjects];
}

@end
