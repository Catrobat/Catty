/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "GDataXMLElement+CustomExtensions.h"
#import "Pocket_Code-Swift.h"
#import "Scene+CBXMLHandler.h"
#import "CBXMLPositionStack.h"
#import <XCTest/XCTest.h>
#import "Pocket_Code-Swift.h"

@interface SceneXMLHandlerTest : XCTestCase

@property (nonatomic, strong) GDataXMLElement *xmlElement;
@property (nonatomic, strong) CBXMLParserContext *paeserContext;
@property (nonatomic, strong) CBXMLSerializerContext *serializerContext;
@property (nonatomic, strong) Scene *scene;

@end
 
@implementation SceneXMLHandlerTest

- (void)setUp
{
    [super setUp];
    
    self.xmlElement = [GDataXMLElement elementWithName: @"scene"];
    GDataXMLNode *child = [GDataXMLNode elementWithName:@"name"];
    [child setStringValue:@"testScene"];
    [self.xmlElement addChild:child];
    
    self.paeserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.98 andRootElement: [GDataXMLElement new]];
    self.paeserContext.rootElement = self.xmlElement;
    
    self.serializerContext = [[CBXMLSerializerContext alloc] initWithProject:[Project new]];
    self.scene = [[Scene alloc] initWithName:@"testScene"];
}

- (void)testParseFromElementWithOutXmlElementName
{
    self.xmlElement = [[GDataXMLElement alloc] init];
    XCTAssertThrows([Scene parseFromElement:self.xmlElement withContext:self.paeserContext], "The expected node is nil");
}

- (void)testParseFromElementWithOutXmlElementObjectList
{
    XCTAssertThrows([Scene parseFromElement:self.xmlElement withContext:self.paeserContext]);
}

- (void)testParseFromElementWithOutXmlElementObject
{
    GDataXMLElement *child = [GDataXMLElement elementWithName:@"objectList"];
    [self.xmlElement addChild: child];
    Scene *xmlScene = [Scene parseFromElement:self.xmlElement withContext:self.paeserContext];
    XCTAssertTrue([self.scene isEqual:xmlScene]);
    XCTAssertFalse(xmlScene == self.scene);
}

- (void)testParseFromElementWithOneObject
{
    SpriteObject *spriteObject = [[SpriteObject alloc] init];
    spriteObject.name = @"Background";
    [self.scene addObject:spriteObject];
    
    GDataXMLElement *objectList = [GDataXMLElement elementWithName:@"objectList"];
    
    GDataXMLElement *object = [GDataXMLElement elementWithName:@"object"];
    GDataXMLNode *attribute = [GDataXMLNode elementWithName:@"name" stringValue:@"Background"];
    
    GDataXMLElement *lockList = [GDataXMLElement elementWithName:@"lookList"];
    GDataXMLElement *soundList = [GDataXMLElement elementWithName:@"soundList"];
    GDataXMLElement *scriptList = [GDataXMLElement elementWithName:@"scriptList"];
    GDataXMLElement *userData = [GDataXMLElement elementWithName:@"data"];
    
    [object addAttribute:attribute];
    [object addChild:lockList];
    [object addChild:scriptList];
    [object addChild:soundList];
    
    [objectList addChild:object];
    [self.xmlElement addChild:objectList];
    [self.xmlElement addChild:userData];
    
    Scene *xmlScene = [Scene parseFromElement:self.xmlElement withContext:self.paeserContext];
    XCTAssertTrue([self.scene isEqual:xmlScene]);
    XCTAssertFalse(xmlScene == self.scene);
}

- (void)testXmlElementWithContext
{
    self.scene = [[SceneMock alloc] initWithName:@"testMockScene"];
    
    NSString *expectedXml = @"<scene><name>testMockScene</name><objectList><object type=\"SingleSprite\" name=\"testObject\"><lookList/><soundList/><scriptList/><userBricks/><nfcTagList/></object></objectList><data><objectListOfList/><objectVariableList/><userBrickVariableList/></data></scene>";
    
    SpriteObject *object = [[SpriteObject alloc] init];
    object.name = @"testObject";
    
    UserDataContainer *userData = [[UserDataContainer alloc] init];
    
    object.userData = userData;
    
    [self.scene addObject:object];
    
    GDataXMLElement *xmlElement = [self.scene xmlElementWithContext:self.serializerContext];
    
    XCTAssertEqual([xmlElement childCount], 3);
    XCTAssertTrue([[xmlElement XMLString] isEqualToString:expectedXml]);
}

- (void)testXmlElementWithContextWithOutObject
{
    self.scene = [[SceneMock alloc] initWithName:@"testMockScene"];
    NSString *expectedXml = @"<scene><name>testMockScene</name><objectList/><data><objectListOfList/><objectVariableList/><userBrickVariableList/></data></scene>";
    GDataXMLElement *xmlElemet = [self.scene xmlElementWithContext:self.serializerContext];
    
    XCTAssertEqual([xmlElemet childCount], 3);
    XCTAssertTrue([[xmlElemet XMLString] isEqualToString:expectedXml]);
}

@end
