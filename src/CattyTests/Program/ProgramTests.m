/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "Program.h"
#import "StartScript.h"
#import "IfThenLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "OrderedMapTable.h"
#import "SetVariableBrick.h"
#import "CBFileManager.h"
#import "AppDelegate.h"
#import "Util.h"
#import "LanguageTranslationDefines.h"

@interface ProgramTests : XCTestCase

@property (nonatomic, strong) Program *program;
@property (nonatomic, strong) CBFileManager *fileManager;

@end

@implementation ProgramTests

- (void)setUp
{
    [super setUp];
    if (! [self.fileManager directoryExists:[Program basePath]]) {
        [self.fileManager createDirectory:[Program basePath]];
    }
}

- (void)tearDown
{
    if (self.program) {
        [ProgramTests removeProject:[self.program projectPath]];
    }
    self.program = nil;
    self.fileManager = nil;
    [super tearDown];
}

- (void)setupForNewProgram
{
    self.program = [Program defaultProgramWithName:kLocalizedNewProgram programID:nil];
}

- (void)testNewProgramIfProjectFolderExists
{
    [self setupForNewProgram];
    XCTAssertTrue([self.fileManager directoryExists:[self.program projectPath]], @"No project folder created for the new project");
}

- (void)testNewProgramIfImagesFolderExists
{
    [self setupForNewProgram];
    NSString *imagesDirName = [NSString stringWithFormat:@"%@%@", [self.program projectPath], kProgramImagesDirName];
    XCTAssertTrue([self.fileManager directoryExists:imagesDirName], @"No images folder created for the new project");
}

- (void)testNewProgramIfSoundsFolderExists
{
    [self setupForNewProgram];
    NSString *soundsDirName = [NSString stringWithFormat:@"%@%@", [self.program projectPath], kProgramSoundsDirName];
    XCTAssertTrue([self.fileManager directoryExists:soundsDirName], @"No sounds folder created for the new project");
}

- (void)testCopyObjectWithIfThenLogicBeginBrick
{
    NSString *objectName = @"newObject";
    NSString *copiedObjectName = @"copiedObject";
    
    [self setupForNewProgram];
    
    SpriteObject *object = [SpriteObject new];
    object.name = objectName;
    
    IfThenLogicBeginBrick *ifThenLogicBeginBrick = [IfThenLogicBeginBrick new];
    ifThenLogicBeginBrick.ifCondition = [[Formula alloc] initWithDouble:2];
    
    IfThenLogicEndBrick *ifThenLogicEndBrick = [IfThenLogicEndBrick new];
    ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick;
    ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick;
    
    StartScript *script = [StartScript new];
    [script.brickList addObjectsFromArray:@[ifThenLogicBeginBrick, ifThenLogicEndBrick]];
    [object.scriptList addObject:script];
    [self.program.objectList addObject:object];
    
    NSUInteger initialObjectSize = self.program.objectList.count;
    
    SpriteObject *copiedObject = [self.program copyObject:object withNameForCopiedObject:copiedObjectName];
    XCTAssertEqual(1, copiedObject.scriptList.count);
    
    NSArray<SpriteObject*> *objectList = self.program.objectList;
    XCTAssertEqual(initialObjectSize + 1, objectList.count);
    XCTAssertTrue([objectList[initialObjectSize].name isEqualToString:copiedObjectName]);
    
    XCTAssertEqual(2, copiedObject.scriptList[0].brickList.count);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[0] isKindOfClass:[IfThenLogicBeginBrick class]]);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[1] isKindOfClass:[IfThenLogicEndBrick class]]);
    
    IfThenLogicBeginBrick *beginBrick = (IfThenLogicBeginBrick*) copiedObject.scriptList[0].brickList[0];
    IfThenLogicEndBrick *endBrick = (IfThenLogicEndBrick*) copiedObject.scriptList[0].brickList[1];
    
    XCTAssertEqual(endBrick, beginBrick.ifEndBrick);
    XCTAssertEqual(beginBrick, endBrick.ifBeginBrick);
    XCTAssertNotEqual(ifThenLogicEndBrick, beginBrick.ifEndBrick);
    XCTAssertNotEqual(ifThenLogicBeginBrick, endBrick.ifBeginBrick);
}

- (void)testCopyObjectWithIfTLogicBeginBrick
{
    NSString *objectName = @"newObject";
    NSString *copiedObjectName = @"copiedObject";
    
    [self setupForNewProgram];
    
    SpriteObject *object = [SpriteObject new];
    object.name = objectName;
    
    IfLogicBeginBrick *ifLogicBeginBrick = [IfLogicBeginBrick new];
    ifLogicBeginBrick.ifCondition = [[Formula alloc] initWithDouble:1];
    
    IfLogicElseBrick *ifLogicElseBrick = [IfLogicElseBrick new];
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    
    IfLogicEndBrick *ifLogicEndBrick = [IfLogicEndBrick new];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    
    StartScript *script = [StartScript new];
    [script.brickList addObjectsFromArray:@[ifLogicBeginBrick, ifLogicElseBrick, ifLogicEndBrick]];
    [object.scriptList addObject:script];
    [self.program.objectList addObject:object];
    
    NSUInteger initialObjectSize = self.program.objectList.count;
    
    SpriteObject *copiedObject = [self.program copyObject:object withNameForCopiedObject:copiedObjectName];
    XCTAssertEqual(1, copiedObject.scriptList.count);
    
    NSArray<SpriteObject*> *objectList = self.program.objectList;
    XCTAssertEqual(initialObjectSize + 1, objectList.count);
    XCTAssertTrue([objectList[initialObjectSize].name isEqualToString:copiedObjectName]);
    
    XCTAssertEqual(3, copiedObject.scriptList[0].brickList.count);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[0] isKindOfClass:[IfLogicBeginBrick class]]);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[1] isKindOfClass:[IfLogicElseBrick class]]);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[2] isKindOfClass:[IfLogicEndBrick class]]);
    
    IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick*) copiedObject.scriptList[0].brickList[0];
    IfLogicElseBrick *elseBrick = (IfLogicElseBrick*) copiedObject.scriptList[0].brickList[1];
    IfLogicEndBrick *endBrick = (IfLogicEndBrick*) copiedObject.scriptList[0].brickList[2];
    
    XCTAssertEqual(endBrick, beginBrick.ifEndBrick);
    XCTAssertEqual(elseBrick, beginBrick.ifElseBrick);
    XCTAssertEqual(elseBrick, endBrick.ifElseBrick);
    XCTAssertEqual(beginBrick, elseBrick.ifBeginBrick);
    XCTAssertEqual(endBrick, elseBrick.ifEndBrick);
    XCTAssertEqual(beginBrick, endBrick.ifBeginBrick);
    
    XCTAssertNotEqual(ifLogicEndBrick, beginBrick.ifEndBrick);
    XCTAssertNotEqual(ifLogicElseBrick, beginBrick.ifElseBrick);
    XCTAssertNotEqual(ifLogicElseBrick, endBrick.ifElseBrick);
    XCTAssertNotEqual(ifLogicBeginBrick, elseBrick.ifBeginBrick);
    XCTAssertNotEqual(ifLogicEndBrick, elseBrick.ifEndBrick);
    XCTAssertNotEqual(ifLogicBeginBrick, endBrick.ifBeginBrick);
}

- (void)testCopyObjectWithObjectVariable
{
    [self setupForNewProgram];
    
    SpriteObject *object = [SpriteObject new];
    object.name = @"newObject";
    [self.program.objectList addObject:object];
    
    UserVariable *variable = [UserVariable new];
    variable.name = @"userVariable";
    [self.program.variables addObjectVariable:variable forObject:object];
    
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    setVariableBrick.userVariable = variable;
    
    StartScript *script = [StartScript new];
    [script.brickList addObjectsFromArray:@[setVariableBrick]];
    [object.scriptList addObject:script];
    
    NSUInteger initialObjectSize = self.program.objectList.count;
    NSUInteger initialVariableSize = self.program.variables.allVariables.count;
    
    SpriteObject *copiedObject = [self.program copyObject:object withNameForCopiedObject:@"copiedObject"];
    XCTAssertEqual(1, copiedObject.scriptList.count);
    
    NSArray<SpriteObject*> *objectList = self.program.objectList;
    XCTAssertEqual(initialObjectSize + 1, objectList.count);
    XCTAssertEqual(initialVariableSize + 1, self.program.variables.allVariables.count);
    XCTAssertTrue([objectList[initialObjectSize].name isEqualToString:copiedObject.name]);
    
    XCTAssertEqual(1, copiedObject.scriptList[0].brickList.count);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[0] isKindOfClass:[SetVariableBrick class]]);
    
    SetVariableBrick *copiedSetVariableBrick = (SetVariableBrick*) copiedObject.scriptList[0].brickList[0];
    XCTAssertNotNil(copiedSetVariableBrick.userVariable);
    XCTAssertNotEqual(variable, copiedSetVariableBrick.userVariable);
    XCTAssertTrue([variable.name isEqualToString:copiedSetVariableBrick.userVariable.name]);
}

- (void)testCopyObjectWithObjectList
{
    [self setupForNewProgram];
    
    SpriteObject *object = [SpriteObject new];
    object.name = @"newObject";
    [self.program.objectList addObject:object];
    
    UserVariable *list = [UserVariable new];
    list.name = @"userList";
    list.isList = YES;
    [self.program.variables addObjectList:list forObject:object];
    
    SetVariableBrick *setVariableBrick = [SetVariableBrick new];
    setVariableBrick.userVariable = list;
    
    StartScript *script = [StartScript new];
    [script.brickList addObjectsFromArray:@[setVariableBrick]];
    [object.scriptList addObject:script];
    
    NSUInteger initialObjectSize = self.program.objectList.count;
    NSUInteger initialListSize = self.program.variables.allLists.count;
    
    SpriteObject *copiedObject = [self.program copyObject:object withNameForCopiedObject:@"copiedObject"];
    XCTAssertEqual(1, copiedObject.scriptList.count);
    
    NSArray<SpriteObject*> *objectList = self.program.objectList;
    XCTAssertEqual(initialObjectSize + 1, objectList.count);
    XCTAssertEqual(initialListSize + 1, self.program.variables.allLists.count);
    XCTAssertTrue([objectList[initialObjectSize].name isEqualToString:copiedObject.name]);
    
    XCTAssertEqual(1, copiedObject.scriptList[0].brickList.count);
    XCTAssertTrue([copiedObject.scriptList[0].brickList[0] isKindOfClass:[SetVariableBrick class]]);
    
    SetVariableBrick *copiedSetVariableBrick = (SetVariableBrick*) copiedObject.scriptList[0].brickList[0];
    XCTAssertNotNil(copiedSetVariableBrick.userVariable);
    XCTAssertNotEqual(list, copiedSetVariableBrick.userVariable);
    XCTAssertTrue([list.name isEqualToString:copiedSetVariableBrick.userVariable.name]);
}

#pragma mark - getters and setters
- (CBFileManager*)fileManager {
    return [CBFileManager sharedManager];
}

+ (void)removeProject:(NSString*)projectPath
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    if ([fileManager directoryExists:projectPath])
        [fileManager deleteDirectory:projectPath];
    [Util setLastProgramWithName:nil programID:nil];
}

@end
