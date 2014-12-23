/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "XMLParserAbstractTest.h"

@interface XMLParserFormulaTests : XMLParserAbstractTest

@end

@implementation XMLParserFormulaTests

- (void)testValidFormulaList {
    
    GDataXMLDocument *document = [self getXMLDocumentForPath:[self getPathForXML:@"ValidFormulaList"]];
    GDataXMLElement *xmlElement = [document rootElement];
    
    NSArray *brickElement = [xmlElement nodesForXPath:@"//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]" error:nil];
    XCTAssertEqual([brickElement count], 1);
    
    NSArray *objectArray = [xmlElement nodesForXPath:@"//program/objectList/object[1]" error:nil];
    XCTAssertEqual([objectArray count], 1);
    GDataXMLElement *objectElement = [objectArray objectAtIndex:0];
    
    NSMutableArray *lookList = [SpriteObject parseAndCreateLooks:objectElement];
    GDataXMLElement *brickXMLElement = [brickElement objectAtIndex:0];

    CBXMLContext *context = [CBXMLContext new];
    context.spriteObject = [SpriteObject new];
    context.spriteObject.lookList = lookList;
    Brick *brick = [SetVariableBrick parseFromElement:brickXMLElement withContext:context];

    XCTAssertTrue(brick.brickType == kSetVariableBrick, @"Invalid brick type");
    XCTAssertTrue([brick isKindOfClass:[SetVariableBrick class]], @"Invalid brick class");
    
    SetVariableBrick *setVariableBrick = (SetVariableBrick*)brick;
    
    XCTAssertTrue([setVariableBrick.userVariable.name isEqualToString:@"random from"], @"Invalid user variable name");
    
    Formula *formula = setVariableBrick.variableFormula;
    // formula value should be: (1 * (-2)) + (3 / 4) = -1,25
    XCTAssertEqualWithAccuracy([formula interpretDoubleForSprite:nil], -1.25, 0.00001, @"Formula not correctly parsed");
}


@end
