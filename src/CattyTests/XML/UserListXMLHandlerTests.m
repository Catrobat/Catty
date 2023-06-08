/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
#import "UserList+CBXMLHandler.h"
#import "CBXMLPositionStack.h"
#import <XCTest/XCTest.h>
#import "Pocket_Code-Swift.h"

@interface UserListXMLHandlerTests : XCTestCase

@property (nonatomic, strong) GDataXMLElement *xmlElement;
@property (nonatomic, strong) CBXMLParserContext *paeserContext;
@property (nonatomic, strong) CBXMLSerializerContext *serializerContext;
@property (nonatomic, strong) UserList *userList;
@property (nonatomic, strong) UserVariable *userVariable;

@end
 
@implementation UserListXMLHandlerTests

- (void)setUp
{
    [super setUp];
    
    self.xmlElement = [GDataXMLElement elementWithName: @"userList"];
    GDataXMLNode *child = [GDataXMLNode elementWithName:@"name"];
    [child setStringValue:@"testUserList"];
    [self.xmlElement addChild:child];
    
    self.paeserContext = [[CBXMLParserContext alloc] initWithLanguageVersion:0.991 andRootElement: [GDataXMLElement new]];
    
    self.serializerContext = [[CBXMLSerializerContext alloc] initWithProject:[Project new]];

    self.userList = [[UserList alloc] initWithName: @"testUserList"];
    self.userVariable = [[UserVariable alloc] initWithName: @"testUserListOfTypeUserVariable"];
}

- (void)testParseFromElementWithOutXmlElimentName
{
    self.xmlElement = [[GDataXMLElement alloc] init];
    XCTAssertThrows([UserList parseFromElement:self.xmlElement withContext:self.paeserContext], "The expected node is nil");
}

- (void)testParseFromElementUserListDoesNotExistsInContext
{
    UserList *userListToComapare = [UserList parseFromElement:self.xmlElement withContext:self.paeserContext];
    
    XCTAssertFalse(userListToComapare == self.userList);
    XCTAssertTrue([self.userList isEqual:userListToComapare]);
}

- (void)testParseFromElementUserListExistsInContext
{
    NSArray *userListArray = [[NSArray alloc] initWithObjects: self.userList, nil];
    [self.paeserContext.programListOfLists setArray:userListArray];
    
    UserList *userListToComapare2 = [UserList parseFromElement:self.xmlElement withContext:self.paeserContext];
    
    XCTAssertTrue(userListToComapare2 == self.userList);
    XCTAssertTrue([self.userList isEqual: userListToComapare2]);
}

- (void)testParseFromElementUserListExistsInSpriteObject
{
    SpriteObject *object = [SpriteObject alloc];
    [object.userData addList:self.userList];
    
    self.paeserContext.spriteObject = object;
    
    XCTAssertThrows([UserList parseFromElement:self.xmlElement withContext:self.paeserContext], "Given SpriteObject has no name");
    
    object.name = @"spriteObject";
    self.paeserContext.spriteObject = object;
    
    UserList *userListToComapare3 = [UserList parseFromElement:self.xmlElement withContext:self.paeserContext];
    
    XCTAssertTrue(userListToComapare3 == self.userList);
    XCTAssertTrue([self.userList isEqual: userListToComapare3]);
}

- (void)testXmlElementWithContext
{
    NSMutableArray *userListArray = [[NSMutableArray alloc] initWithObjects: self.userList,nil];
    for(UserList *list in userListArray) {
        [self.serializerContext.project.userData addList:list];
    }
    
    GDataXMLElement *xmlElement = [self.userList xmlElementWithContext:self.serializerContext];
    NSString *expectedXMLString = [NSString stringWithFormat:@"<userList><name>testUserList</name></userList>"];
    
    XCTAssertTrue([[xmlElement XMLString] isEqualToString: expectedXMLString]);
}

- (void)testXmlElementWithContextWithObjectListAlreadySerialized
{
    NSMutableArray *userListArray = [[NSMutableArray alloc] initWithObjects: self.userVariable, nil];
    for(UserList *list in userListArray) {
        [self.serializerContext.project.userData addList:list];
    }
    
    SpriteObject *object = [SpriteObject alloc];
    object.name = @"spriteObject";
    self.serializerContext.spriteObject = object;
    
    CBXMLPositionStack *destinationPositionStack = [[CBXMLPositionStack alloc] init];
    [destinationPositionStack pushXmlElementName:@"newXmlElement"];
    
    CBXMLPositionStack *sourcePositionStack = [[CBXMLPositionStack alloc] init];
    [destinationPositionStack pushXmlElementName:@"xmlElement"];
    
    self.serializerContext.currentPositionStack = sourcePositionStack;
    
    NSMutableDictionary *userListDict = [[NSMutableDictionary alloc] init];
    [userListDict setValue:destinationPositionStack forKey:@"testUserList"];
    
    [self.serializerContext.spriteObjectNameUserListOfListsPositions setObject:userListDict forKey:@"spriteObject"];
    
    GDataXMLElement *xmlElement = [self.userList xmlElementWithContext:self.serializerContext];
    NSString *expectedXMLString = [NSString stringWithFormat:@"<userList reference=%c""../newXmlElement/xmlElement%c""/>",'"','"'];
    
    XCTAssertTrue([[xmlElement XMLString] isEqualToString: expectedXMLString]);
}

- (void)testXmlElementWithContextWithObjectListNotAlreadySerialized
{
    NSMutableArray *userListArray = [[NSMutableArray alloc] initWithObjects: self.userVariable, nil];
    for(UserList *list in userListArray) {
        [self.serializerContext.project.userData addList:list];
    }
    
    SpriteObject *object = [SpriteObject alloc];
    object.name = @"spriteObject";
    self.serializerContext.spriteObject = object;
    
    GDataXMLElement *xmlElement = [self.userList xmlElementWithContext:self.serializerContext];
    NSString *expectedXMLString = [NSString stringWithFormat:@"<userList><name>testUserList</name></userList>"];
    
    XCTAssertTrue([[xmlElement XMLString] isEqualToString: expectedXMLString]);
}

- (void)testXmlElementWithContextWithAlreadySerializedList
{
    NSMutableArray *userListArray = [[NSMutableArray alloc] initWithObjects: self.userList, nil];
    for(UserList *list in userListArray) {
        [self.serializerContext.project.userData addList:list];
    }
    
    CBXMLPositionStack *destinationPositionStack = [[CBXMLPositionStack alloc] init];
    [destinationPositionStack pushXmlElementName:@"newXmlElement"];
    
    CBXMLPositionStack *sourcePositionStack = [[CBXMLPositionStack alloc] init];
    [destinationPositionStack pushXmlElementName:@"xmlElement"];
    
    self.serializerContext.currentPositionStack = sourcePositionStack;
    [self.serializerContext.projectUserListNamePositions setObject:destinationPositionStack forKey: @"testUserList"];
    
    GDataXMLElement *xmlElement = [self.userList xmlElementWithContext:self.serializerContext];
    
    NSString *expectedXMLString = [NSString stringWithFormat:@"<userList reference=%c""../newXmlElement/xmlElement%c""/>",'"','"'];
    XCTAssertTrue([[xmlElement XMLString] isEqualToString: expectedXMLString]);
}
@end
