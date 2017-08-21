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
#import "FlashBrick.h"
#import "Scene.h"

@interface XMLParserTests0992 : XMLAbstractTest

@end

@implementation XMLParserTests0992

- (void)testFlashBrick
{
    Program *program = [self getProgramForXML:@"LedFlashBrick0992"];
    
    XCTAssertEqual(1, [program.scenes count], "Invalid scenes");
    Scene *scene = [program.scenes objectAtIndex:0];
    
    XCTAssertEqual(1, [scene.objectList count], "Invalid object list");
    SpriteObject *object = [scene.objectList objectAtIndex:0];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    Script *script = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    FlashBrick *flashBrick = (FlashBrick*)[script.brickList objectAtIndex:0];
    XCTAssertEqual(1, flashBrick.flashChoice, @"Invalid flash choice");
    
    flashBrick = (FlashBrick*)[script.brickList objectAtIndex:1];
    XCTAssertEqual(0, flashBrick.flashChoice, @"Invalid flash choice");
}

- (void)testLedBrick
{
    Program *program = [self getProgramForXML:@"LedFlashBrick0992"];
    
    XCTAssertEqual(1, [program.scenes count], "Invalid scenes");
    Scene *scene = [program.scenes objectAtIndex:0];
    
    XCTAssertEqual(1, [scene.objectList count], "Invalid object list");
    SpriteObject *object = [scene.objectList objectAtIndex:0];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    Script *script = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    FlashBrick *flashBrick = (FlashBrick*)[script.brickList objectAtIndex:2];
    XCTAssertEqual(1, flashBrick.flashChoice, @"Invalid flash choice");
    
    flashBrick = (FlashBrick*)[script.brickList objectAtIndex:3];
    XCTAssertEqual(0, flashBrick.flashChoice, @"Invalid flash choice");
}

@end

