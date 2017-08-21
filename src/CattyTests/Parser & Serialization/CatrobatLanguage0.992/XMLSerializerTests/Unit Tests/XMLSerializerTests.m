/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "XMLAbstractTest.h"
#import "Program+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializer.h"
#import "CBXMLParser.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Scene.h"

@interface XMLSerializerTests : XMLAbstractTest

@end

@implementation XMLSerializerTests

- (void)testHeader
{
    Program *program = [self getProgramForXML:@"ValidHeader0992"];
    Header *header = program.header;
    BOOL equal = [self isXMLElement:[header xmlElementWithContext:nil] equalToXMLElementForXPath:@"//program/header" inProgramForXML:@"ValidHeader0992"];
    XCTAssertTrue(equal, @"XMLElement invalid!");
}

- (void)testInvalidHeader
{
    Program *program = [self getProgramForXML:@"ValidHeader0992"];
    Header *header = program.header;
    header.programDescription = @"Invalid";
    BOOL equal = [self isXMLElement:[header xmlElementWithContext:nil] equalToXMLElementForXPath:@"//program/header" inProgramForXML:@"ValidHeader0992"];
    XCTAssertFalse(equal, @"GDataXMLElement::isEqualToElement not working correctly!");
}

- (void)testFormulaAndMoveNStepsBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0992"];
    
    XCTAssertEqual(1, [program.scenes count], "Invalid scenes");
    Scene *scene = [program.scenes objectAtIndex:0];
    
    MoveNStepsBrick *brick = (MoveNStepsBrick*)[((Script*)[((SpriteObject*)[scene.objectList objectAtIndex:0]).scriptList objectAtIndex:0]).brickList objectAtIndex:5];
    BOOL equal = [self isXMLElement:[brick xmlElementWithContext:nil] equalToXMLElementForXPath:@"//program/scenes/scene/objectList/object[1]/scriptList/script[1]/brickList/brick[6]" inProgramForXML:@"ValidProgramAllBricks0992"];
    XCTAssertTrue(equal, @"XMLElement invalid!");
}

- (void)testRemoveObjectAndSerializeProgram
{
    CBXMLParserContext *parserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.992f];
    
    Program *referenceProgram = [self getProgramForXML:@"ValidProgram0992"];
    
    XCTAssertEqual(1, [referenceProgram.scenes count], "Invalid scenes");
    Scene *referenceScene = [referenceProgram.scenes objectAtIndex:0];
    
    Program *program = [self getProgramForXML:@"ValidProgram0992"];
    
    XCTAssertEqual(1, [program.scenes count], "Invalid scenes");
    Scene *scene = [program.scenes objectAtIndex:0];
    
    SpriteObject *moleOne = [scene.objectList objectAtIndex:1];
    [scene removeObject:moleOne];
    
    GDataXMLElement *xmlElement = [program xmlElementWithContext:[CBXMLSerializerContext new]];
    XCTAssertNotNil(xmlElement, @"Error during serialization of removed object");
    XCTAssertEqual([scene.objectList count] + 1, [referenceScene.objectList count], @"Object not properly removed");
    XCTAssertFalse([[referenceProgram xmlElementWithContext:[CBXMLSerializerContext new]] isEqualToElement:xmlElement], @"Object not properly removed");
    
    Program *parsedProgram = [parserContext parseFromElement:xmlElement withClass:[Program class]];
    XCTAssertTrue([parsedProgram isEqualToProgram:program], @"Programs are not equal");
}

- (void)testPointedToBrickWithoutSpriteObject
{
    Program *program = [self getProgramForXML:@"PointToBrickWithoutSpriteObject"];
    XCTAssertNotNil(program, @"Program must not be nil!");
    
    XCTAssertEqual(1, [program.scenes count], "Invalid scenes");
    Scene *scene = [program.scenes objectAtIndex:0];

    SpriteObject *moleTwo = [scene.objectList objectAtIndex:1];
    XCTAssertNotNil(moleTwo, @"SpriteObject must not be nil!");
    XCTAssertTrue([moleTwo.name isEqualToString:@"Mole 2"], @"Invalid object name!");

    Script *script = [moleTwo.scriptList objectAtIndex:0];
    XCTAssertNotNil(script, @"Script must not be nil!");

    PointToBrick *pointToBrick = (PointToBrick*)[script.brickList objectAtIndex:7];
    XCTAssertNotNil(pointToBrick, @"PointToBrick must not be nil!");
    
    CBXMLSerializerContext *context = [CBXMLSerializerContext new];
    context.spriteObjectList = scene.objectList;

    BOOL equal = [self isXMLElement:[pointToBrick xmlElementWithContext:context] equalToXMLElementForXPath:@"//program/objectList/object[2]/scriptList/script[1]/brickList/brick[8]" inProgramForXML:@"PointToBrickWithoutSpriteObject"];
    XCTAssertTrue(equal, @"XMLElement invalid!");
}

@end

