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
#import "AddItemToUserListBrick.h"
#import "DeleteItemOfUserListBrick.h"
#import "InsertItemIntoUserListBrick.h"


@interface XMLParserTests098 : XMLAbstractTest

@end

@implementation XMLParserTests098

- (void)testFlashBrick
{
    Program *program = [self getProgramForXML:@"LedFlashBrick098"];
    
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    SpriteObject *object = [program.objectList objectAtIndex:0];
    
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
    Program *program = [self getProgramForXML:@"LedFlashBrick098"];
    
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    SpriteObject *object = [program.objectList objectAtIndex:0];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    Script *script = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    FlashBrick *flashBrick = (FlashBrick*)[script.brickList objectAtIndex:2];
    XCTAssertEqual(1, flashBrick.flashChoice, @"Invalid flash choice");
    
    flashBrick = (FlashBrick*)[script.brickList objectAtIndex:3];
    XCTAssertEqual(0, flashBrick.flashChoice, @"Invalid flash choice");
}

- (void)testAddItemToUserListBrick
{
    Program *program = [self getProgramForXML:@"AddItemToUserListBrick098"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(2, [script.brickList count], "Invalid brick list");
    
    AddItemToUserListBrick *addItemToUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:0];
    XCTAssertEqualObjects(@"programList", addItemToUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[addItemToUserListBrick.listFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:66], numberValue, @"Invalid list value");
    
    addItemToUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:1];
    XCTAssertEqualObjects(@"objectList", addItemToUserListBrick.userList.name, @"Invalid list name");
    
    NSString* stringValue = (NSString*)[addItemToUserListBrick.listFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects(@"hallo", stringValue, @"Invalid list value");
}

- (void)testDeleteItemOfUserListBrick
{
    Program *program = [self getProgramForXML:@"DeleteItemOfUserListBrick098"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    DeleteItemOfUserListBrick *deleteItemOfUserListBrick = (DeleteItemOfUserListBrick*)[script.brickList objectAtIndex:2];
    XCTAssertEqualObjects(@"testlist", deleteItemOfUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[deleteItemOfUserListBrick.listFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:2], numberValue, @"Invalid list value");
    
    deleteItemOfUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:3];
    XCTAssertEqualObjects(@"testlist", deleteItemOfUserListBrick.userList.name, @"Invalid list name");
    
    numberValue = (NSNumber*)[deleteItemOfUserListBrick.listFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:1], numberValue, @"Invalid list value");
}

- (void)testInsertItemIntoUserListBrick
{
    Program *program = [self getProgramForXML:@"InsertItemIntoUserListBrick098"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(2, [script.brickList count], "Invalid brick list");
    
    InsertItemIntoUserListBrick *insertItemIntoUserListBrick = (InsertItemIntoUserListBrick*)[script.brickList objectAtIndex:0];
    XCTAssertEqualObjects(@"hallo", insertItemIntoUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[insertItemIntoUserListBrick.elementFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:55], numberValue, @"Invalid list value");
    
    NSNumber* indexValue = (NSNumber*)[insertItemIntoUserListBrick.index interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:1], indexValue, @"Invalid index value");
    
    insertItemIntoUserListBrick = (InsertItemIntoUserListBrick*)[script.brickList objectAtIndex:1];
    XCTAssertEqualObjects(@"hallo", insertItemIntoUserListBrick.userList.name, @"Invalid list name");
    
    NSString* stringValue = (NSString*)[insertItemIntoUserListBrick.elementFormula interpretVariableDataForSprite:object];
    XCTAssertEqualObjects(@"test", stringValue, @"Invalid list value");

    
    indexValue = (NSNumber*)[insertItemIntoUserListBrick.index interpretVariableDataForSprite:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:2], indexValue, @"Invalid index value");
    
}

@end

