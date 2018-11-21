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

#import "XMLAbstractTest.h"
#import "Program+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializer.h"
#import "CBXMLParser.h"
#import "FlashBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "PreviousLookBrick.h"
#import "RepeatUntilBrick.h"
#import "SetBackgroundBrick.h"
#import "SpeakAndWaitBrick.h"
#import "CameraBrick.h"
#import "ChooseCameraBrick.h"
#import "SayBubbleBrick.h"
#import "ThinkBubbleBrick.h"
#import "SayForBubbleBrick.h"
#import "ThinkForBubbleBrick.h"
#import "AddItemToUserListBrick.h"
#import "DeleteItemOfUserListBrick.h"
#import "ReplaceItemInUserListBrick.h"
#import "InsertItemIntoUserListBrick.h"
#import "Pocket_Code-Swift.h"

@interface XMLParserTests0991 : XMLAbstractTest
@property (nonatomic, strong) FormulaManager *formulaManager;
@end

@implementation XMLParserTests0991

- (void)setUp
{
    self.formulaManager = [FormulaManager new];
}

- (void)testFlashBrick
{
    Program *program = [self getProgramForXML:@"LedFlashBrick0991"];
    
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
    Program *program = [self getProgramForXML:@"LedFlashBrick0991"];
    
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

- (void)testIfThenLogicBeginBrick
{
    Program *program = [self getProgramForXML:@"LogicBricks_0991"];
    
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    SpriteObject *object = [program.objectList objectAtIndex:0];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    Script *script = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(8, [script.brickList count], "Invalid brick list");
    
    // tests for IfThenLogicBeginBrick
    IfThenLogicBeginBrick *ifThenLogicBeginBrick = (IfThenLogicBeginBrick*)[script.brickList objectAtIndex:0];
    IfThenLogicEndBrick *ifThenLogicEndBrick = (IfThenLogicEndBrick*)[script.brickList objectAtIndex:2];
    
    XCTAssertNotNil(ifThenLogicBeginBrick, "IfThenLogicBeginBrick not found at index 0.");
    
    
    // check if condition is not null
    XCTAssertNotNil(ifThenLogicBeginBrick.ifCondition.formulaTree, "Invalid Formula for If Condition");
    
    
    // check if end brick exists and is correctly paired
    XCTAssertNotNil(ifThenLogicEndBrick, "IfThenLogicEndBrick not found at index 2.");
    XCTAssertNotNil(ifThenLogicBeginBrick.ifEndBrick, "No associated If End brick for if brick.");
    XCTAssertEqual(ifThenLogicEndBrick, ifThenLogicBeginBrick.ifEndBrick, "If End brick in script and that associated to if brick do not match.");
    XCTAssertEqual(ifThenLogicBeginBrick, ifThenLogicBeginBrick.ifEndBrick.ifBeginBrick, "If Begin brick associated to If End brick does not match.");
    
    // tests for IfLogicBeginBrick
    IfLogicBeginBrick *ifLogicBeginBrick = (IfLogicBeginBrick*)[script.brickList objectAtIndex:3];
    IfLogicElseBrick *ifLogicElseBrick = (IfLogicElseBrick*)[script.brickList objectAtIndex:5];
    IfLogicEndBrick *ifLogicEndBrick = (IfLogicEndBrick*)[script.brickList objectAtIndex:7];
    
    XCTAssertNotNil(ifLogicBeginBrick, "IfThenLogicBeginBrick not found at index 0.");
    XCTAssertNotNil(ifLogicElseBrick, "IfThenLogicBeginBrick not found at index 0.");
    XCTAssertNotNil(ifLogicEndBrick, "IfThenLogicBeginBrick not found at index 0.");
    
    
    // check if condition is not null
    XCTAssertNotNil(ifLogicBeginBrick.ifCondition.formulaTree, "Invalid Formula for If Condition");
    
    
    // check if else and end brick exists and is correctly paired
    XCTAssertNotNil(ifLogicBeginBrick.ifElseBrick, "No associated If Else brick for if brick.");
    XCTAssertNotNil(ifLogicBeginBrick.ifEndBrick, "No associated If End brick for if brick.");
    
    XCTAssertEqual(ifLogicBeginBrick.ifElseBrick, ifLogicElseBrick, "If Else brick in script and that associated to if brick do not match.");
    XCTAssertEqual(ifLogicBeginBrick.ifEndBrick, ifLogicEndBrick, "If End brick in script and that associated to if brick do not match.");
    
    XCTAssertEqual(ifLogicEndBrick.ifElseBrick, ifLogicElseBrick, "IfLogicElseBrick associated to IfLogicEndBrick does not match.");
    XCTAssertEqual(ifLogicEndBrick.ifBeginBrick, ifLogicBeginBrick, "IfLogicBeginBrick associated to IfLogicEndBrick does not match.");
    
    XCTAssertEqual(ifLogicElseBrick.ifBeginBrick, ifLogicBeginBrick, "IfLogicBeginBrick associated to IfLogicElseBrick does not match.");
    XCTAssertEqual(ifLogicElseBrick.ifEndBrick, ifLogicEndBrick, "IfLogicEndBrick associated to IfLogicElseBrick does not match.");
}

- (void)testObjectLookSensors
{
    Program *program = [self getProgramForXML:@"Sensors_0991"];
    
    XCTAssertTrue([program.objectList count] >= 2, "Invalid object list");
    SpriteObject *background = [program.objectList objectAtIndex:0];
    SpriteObject *object = [program.objectList objectAtIndex:1];
    
    XCTAssertEqual(1, [background.scriptList count], "Invalid script list");
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    Script *objectScript = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(2, [backgroundScript.brickList count], "Invalid brick list");
    XCTAssertEqual(3, [objectScript.brickList count], "Invalid brick list");
    
    SetVariableBrick *backgroundSetVariableBrickName = (SetVariableBrick*)[backgroundScript.brickList objectAtIndex:0];
    SetVariableBrick *backgroundSetVariableBrickNumber = (SetVariableBrick*)[backgroundScript.brickList objectAtIndex:1];
    
    XCTAssertEqual(SENSOR, backgroundSetVariableBrickName.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, backgroundSetVariableBrickNumber.variableFormula.formulaTree.type);
    
    XCTAssertTrue([BackgroundNameSensor.tag isEqualToString:backgroundSetVariableBrickName.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([BackgroundNumberSensor.tag isEqualToString: backgroundSetVariableBrickNumber.variableFormula.formulaTree.value], "Invalid sensor");
    
    SetVariableBrick *objectSetVariableBrickName = (SetVariableBrick*)[objectScript.brickList objectAtIndex:0];
    SetVariableBrick *objectSetVariableBrickNumber = (SetVariableBrick*)[objectScript.brickList objectAtIndex:1];
    
    XCTAssertEqual(SENSOR, objectSetVariableBrickName.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, objectSetVariableBrickNumber.variableFormula.formulaTree.type);
    
    XCTAssertTrue([LookNameSensor.tag isEqualToString: objectSetVariableBrickName.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([LookNumberSensor.tag isEqualToString: objectSetVariableBrickNumber.variableFormula.formulaTree.value], "Invalid sensor");
    
    SetVariableBrick *objectSetVariableBrickColor = (SetVariableBrick*)[objectScript.brickList objectAtIndex:2];
    XCTAssertEqual(SENSOR, objectSetVariableBrickColor.variableFormula.formulaTree.type);
    XCTAssertTrue([ColorSensor.tag isEqualToString: objectSetVariableBrickColor.variableFormula.formulaTree.value], "Invalid sensor");
}

- (void)testPreviousLookBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 26, "Invalid brick list");
    
    Brick *previousLookBrick = [backgroundScript.brickList objectAtIndex:26];
    XCTAssertTrue([previousLookBrick isKindOfClass:[PreviousLookBrick class]], "Invalid brick type");
}

- (void)testRepeatUntilBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 27, "Invalid brick list");
    
    Brick *repeatUntilBrick = [backgroundScript.brickList objectAtIndex:27];
    XCTAssertTrue([repeatUntilBrick isKindOfClass:[RepeatUntilBrick class]], "Invalid brick type");
}

- (void)testSetBackgroundBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 29, "Invalid brick list");
    
    Brick *brick = [backgroundScript.brickList objectAtIndex:29];
    XCTAssertTrue([brick isKindOfClass:[SetBackgroundBrick class]], "Invalid brick type");
    
    SetBackgroundBrick *setBackgroundBrick = (SetBackgroundBrick*)brick;
    XCTAssertTrue(setBackgroundBrick.look != nil, "Invalid look");
}

- (void)testSpeakAndWaitBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 30, "Invalid brick list");
    
    Brick *brick = [backgroundScript.brickList objectAtIndex:30];
    XCTAssertTrue([brick isKindOfClass:[SpeakAndWaitBrick class]], "Invalid brick type");
    
    SpeakAndWaitBrick *speakAndWaitBrick = (SpeakAndWaitBrick*)brick;
    XCTAssertTrue(speakAndWaitBrick.formula != nil, "Invalid formula");
}

- (void)testLocationSensors
{
    Program *program = [self getProgramForXML:@"Sensors_0991"];
    
    XCTAssertTrue([program.objectList count] >= 3, "Invalid object list");
    SpriteObject *object = [program.objectList objectAtIndex:2];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    SetVariableBrick *latitudeBrick = (SetVariableBrick*)[script.brickList objectAtIndex:0];
    SetVariableBrick *longitudeBrick = (SetVariableBrick*)[script.brickList objectAtIndex:1];
    SetVariableBrick *altitudeBrick = (SetVariableBrick*)[script.brickList objectAtIndex:2];
    SetVariableBrick *locationAccuracyBrick = (SetVariableBrick*)[script.brickList objectAtIndex:3];
    
    XCTAssertEqual(SENSOR, latitudeBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, longitudeBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, altitudeBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, locationAccuracyBrick.variableFormula.formulaTree.type);
    
    XCTAssertTrue([LatitudeSensor.tag isEqualToString:latitudeBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([LongitudeSensor.tag isEqualToString:longitudeBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([AltitudeSensor.tag isEqualToString:altitudeBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([LocationAccuracySensor.tag isEqualToString:locationAccuracyBrick.variableFormula.formulaTree.value], "Invalid sensor");
}

- (void)testScreenTouchSensors
{
    Program *program = [self getProgramForXML:@"Sensors_0991"];
    
    XCTAssertTrue([program.objectList count] >= 4, "Invalid object list");
    SpriteObject *object = [program.objectList objectAtIndex:3];
    
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    SetVariableBrick *fingerTouchedBrick = (SetVariableBrick*)[script.brickList objectAtIndex:0];
    SetVariableBrick *fingerXBrick = (SetVariableBrick*)[script.brickList objectAtIndex:1];
    SetVariableBrick *fingerYBrick = (SetVariableBrick*)[script.brickList objectAtIndex:2];
    SetVariableBrick *lastFingerIndexBrick = (SetVariableBrick*)[script.brickList objectAtIndex:3];
    
    XCTAssertEqual(SENSOR, fingerTouchedBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, fingerXBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, fingerYBrick.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, lastFingerIndexBrick.variableFormula.formulaTree.type);
    
    XCTAssertTrue([FingerTouchedSensor.tag isEqualToString:fingerTouchedBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([FingerXSensor.tag isEqualToString:fingerXBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([FingerYSensor.tag isEqualToString:fingerYBrick.variableFormula.formulaTree.value], "Invalid sensor");
    XCTAssertTrue([LastFingerIndexSensor.tag isEqualToString:lastFingerIndexBrick.variableFormula.formulaTree.value], "Invalid sensor");
}

- (void)testCameraBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 33, "Invalid brick list");
    
    Brick *cameraBrick = [backgroundScript.brickList objectAtIndex:31];
    XCTAssertTrue([cameraBrick isKindOfClass:[CameraBrick class]], "Invalid brick type");
    XCTAssertTrue([(CameraBrick*)cameraBrick isEnabled], "Invalid brick option");
    
    cameraBrick = [backgroundScript.brickList objectAtIndex:32];
    XCTAssertTrue([cameraBrick isKindOfClass:[CameraBrick class]], "Invalid brick type");
    XCTAssertFalse([(CameraBrick*)cameraBrick isEnabled], "Invalid brick option");
}

- (void)testChooseCameraBrick
{
    Program *program = [self getProgramForXML:@"CameraBricks_0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [backgroundScript.brickList count]);
    
    Brick *cameraBrick = [backgroundScript.brickList objectAtIndex:0];
    XCTAssertTrue([cameraBrick isKindOfClass:[ChooseCameraBrick class]]);
    XCTAssertEqual(0, [(ChooseCameraBrick*)cameraBrick cameraPosition]);
    
    cameraBrick = [backgroundScript.brickList objectAtIndex:1];
    XCTAssertTrue([cameraBrick isKindOfClass:[ChooseCameraBrick class]]);
    XCTAssertEqual(1, [(ChooseCameraBrick*)cameraBrick cameraPosition]);
    
    cameraBrick = [backgroundScript.brickList objectAtIndex:2];
    XCTAssertTrue([cameraBrick isKindOfClass:[ChooseCameraBrick class]]);
    XCTAssertEqual(0, [(ChooseCameraBrick*)cameraBrick cameraPosition]);
    
    cameraBrick = [backgroundScript.brickList objectAtIndex:3];
    XCTAssertTrue([cameraBrick isKindOfClass:[ChooseCameraBrick class]]);
    XCTAssertEqual(1, [(ChooseCameraBrick*)cameraBrick cameraPosition]);
}

- (void)testSayBubbleBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 34, "Invalid brick list");
    
    Brick *sayBubbleBrick = [backgroundScript.brickList objectAtIndex:33];
    XCTAssertTrue([sayBubbleBrick isKindOfClass:[SayBubbleBrick class]], "Invalid brick type");
    XCTAssertNotNil(((SayBubbleBrick*)sayBubbleBrick).formula, "Invalid formula");
}

- (void)testThinkBubbleBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 35, "Invalid brick list");
    
    Brick *thinkBubbleBrick = [backgroundScript.brickList objectAtIndex:34];
    XCTAssertTrue([thinkBubbleBrick isKindOfClass:[ThinkBubbleBrick class]], "Invalid brick type");
    XCTAssertNotNil(((ThinkBubbleBrick*)thinkBubbleBrick).formula, "Invalid formula");
}

- (void)testSayForBubbleBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 36, "Invalid brick list");
    
    Brick *sayForBubbleBrick = [backgroundScript.brickList objectAtIndex:35];
    XCTAssertTrue([sayForBubbleBrick isKindOfClass:[SayForBubbleBrick class]], "Invalid brick type");
    XCTAssertNotNil(((SayForBubbleBrick*)sayForBubbleBrick).stringFormula, "Invalid formula");
    XCTAssertNotNil(((SayForBubbleBrick*)sayForBubbleBrick).intFormula, "Invalid formula");
}

- (void)testThinkForBubbleBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 37, "Invalid brick list");
    
    Brick *thinkForBubbleBrick = [backgroundScript.brickList objectAtIndex:36];
    XCTAssertTrue([thinkForBubbleBrick isKindOfClass:[ThinkForBubbleBrick class]], "Invalid brick type");
    XCTAssertNotNil(((ThinkForBubbleBrick*)thinkForBubbleBrick).stringFormula, "Invalid formula");
    XCTAssertNotNil(((ThinkForBubbleBrick*)thinkForBubbleBrick).intFormula, "Invalid formula");
}

- (void)testAddItemToUserListBrick
{
    Program *program = [self getProgramForXML:@"AddItemToUserListBrick0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(2, [script.brickList count], "Invalid brick list");
    
    AddItemToUserListBrick *addItemToUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:0];
    XCTAssertEqualObjects(@"programList", addItemToUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[self.formulaManager interpret:addItemToUserListBrick.listFormula forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:66], numberValue, @"Invalid list value");
    
    addItemToUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:1];
    XCTAssertEqualObjects(@"objectList", addItemToUserListBrick.userList.name, @"Invalid list name");
    
    NSString* stringValue = (NSString*)[self.formulaManager interpret:addItemToUserListBrick.listFormula forSpriteObject:object];
    XCTAssertEqualObjects(@"hallo", stringValue, @"Invalid list value");
}

- (void)testNumberOfItemsFunction
{
    Program *program = [self getProgramForXML:@"NumberOfItemsInListFunction0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(3, [script.brickList count], "Invalid brick list");
    
    AddItemToUserListBrick *addItemToUserListBrick = (AddItemToUserListBrick*)[script.brickList objectAtIndex:2];
    Formula *formula = addItemToUserListBrick.listFormula;
    
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"NUMBER_OF_ITEMS"]);
    XCTAssertEqual(FUNCTION, formula.formulaTree.type);
    
    XCTAssertTrue([(NSString*)formula.formulaTree.value isEqualToString:@"NUMBER_OF_ITEMS"]);
}

- (void)testElementOfListFunction
{
    Program *program = [self getProgramForXML:@"ElementOfListFunction0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(1, [script.brickList count], "Invalid brick list");
    
    WaitBrick *waitBrick = (WaitBrick*)[script.brickList objectAtIndex:0];
    Formula *formula = waitBrick.timeToWaitInSeconds;
    
    XCTAssertEqual(NUMBER, formula.formulaTree.leftChild.type);
    XCTAssertTrue([formula.formulaTree.leftChild.value isEqualToString:@"1"]);
    
    XCTAssertEqual(USER_LIST, formula.formulaTree.rightChild.type);
    XCTAssertTrue([formula.formulaTree.rightChild.value isEqualToString:@"test"]);
    
    XCTAssertTrue([formula.formulaTree.value isEqualToString:@"LIST_ITEM"]);
    XCTAssertEqual(FUNCTION, formula.formulaTree.type);
    
    XCTAssertTrue([(NSString*)formula.formulaTree.value isEqualToString:@"LIST_ITEM"]);
}

- (void)testDeleteItemOfUserListBrick
{
    Program *program = [self getProgramForXML:@"DeleteItemOfUserListBrick0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    DeleteItemOfUserListBrick *deleteItemOfUserListBrick = (DeleteItemOfUserListBrick*)[script.brickList objectAtIndex:2];
    XCTAssertEqualObjects(@"testlist", deleteItemOfUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[self.formulaManager interpret:deleteItemOfUserListBrick.listFormula forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:2], numberValue, @"Invalid list value");
    
    deleteItemOfUserListBrick = (DeleteItemOfUserListBrick*)[script.brickList objectAtIndex:3];
    XCTAssertEqualObjects(@"testlist", deleteItemOfUserListBrick.userList.name, @"Invalid list name");
    
    numberValue = (NSNumber*)[self.formulaManager interpret:deleteItemOfUserListBrick.listFormula forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:1], numberValue, @"Invalid list value");
}

- (void)testInsertItemIntoUserListBrick
{
    Program *program = [self getProgramForXML:@"InsertItemIntoUserListBrick0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(2, [script.brickList count], "Invalid brick list");
    
    InsertItemIntoUserListBrick *insertItemIntoUserListBrick = (InsertItemIntoUserListBrick*)[script.brickList objectAtIndex:0];
    XCTAssertEqualObjects(@"hallo", insertItemIntoUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[self.formulaManager interpret:insertItemIntoUserListBrick.elementFormula forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:55], numberValue, @"Invalid list value");
    
    NSNumber* indexValue = (NSNumber*)[self.formulaManager interpret:insertItemIntoUserListBrick.index forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:1], indexValue, @"Invalid index value");
    
    insertItemIntoUserListBrick = (InsertItemIntoUserListBrick*)[script.brickList objectAtIndex:1];
    XCTAssertEqualObjects(@"hallo", insertItemIntoUserListBrick.userList.name, @"Invalid list name");
    
    NSString* stringValue = (NSString*)[self.formulaManager interpret:insertItemIntoUserListBrick.elementFormula forSpriteObject:object];
    XCTAssertEqualObjects(@"test", stringValue, @"Invalid list value");
    
    
    indexValue = (NSNumber*)[self.formulaManager interpret:insertItemIntoUserListBrick.index forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:2], indexValue, @"Invalid index value");
    
}

- (void)testReplaceItemInUserListBrick
{
    Program *program = [self getProgramForXML:@"ReplaceItemInUserListBrick0991"];
    XCTAssertEqual(1, [program.objectList count], "Invalid object list");
    
    SpriteObject *object = [program.objectList objectAtIndex:0];
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *script = [object.scriptList objectAtIndex:0];
    XCTAssertEqual(4, [script.brickList count], "Invalid brick list");
    
    ReplaceItemInUserListBrick *replaceItemInUserListBrick = (ReplaceItemInUserListBrick*)[script.brickList objectAtIndex:2];
    XCTAssertEqualObjects(@"testlist", replaceItemInUserListBrick.userList.name, @"Invalid list name");
    
    NSString* stringValue = (NSString*)[self.formulaManager interpret:replaceItemInUserListBrick.elementFormula forSpriteObject:object];
    XCTAssertEqualObjects(@"hello", stringValue, @"Invalid list value");
    
    NSNumber* indexValue = (NSNumber*)[self.formulaManager interpret:replaceItemInUserListBrick.index forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:1], indexValue, @"Invalid index value");
    
    replaceItemInUserListBrick = (ReplaceItemInUserListBrick*)[script.brickList objectAtIndex:3];
    XCTAssertEqualObjects(@"testlist", replaceItemInUserListBrick.userList.name, @"Invalid list name");
    
    NSNumber* numberValue = (NSNumber*)[self.formulaManager interpret:replaceItemInUserListBrick.elementFormula forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithFloat:33], numberValue, @"Invalid list value");
    
    indexValue = (NSNumber*)[self.formulaManager interpret:replaceItemInUserListBrick.index forSpriteObject:object];
    XCTAssertEqualObjects([NSNumber numberWithInt:2], indexValue, @"Invalid index value");
}

- (void)testBroadcastScript
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *object = [program.objectList objectAtIndex:1];
    Script *broadcastScript = [object.scriptList objectAtIndex:0];
    XCTAssertTrue([broadcastScript isKindOfClass:[BroadcastScript class]], "Invalid script type");
}

- (void)testWhenScript
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *object = [program.objectList objectAtIndex:1];
    Script *whenScript = [object.scriptList objectAtIndex:1];
    XCTAssertTrue([whenScript isKindOfClass:[WhenScript class]], "Invalid script type");
}

- (void)testWhenTouchDownScript
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *object = [program.objectList objectAtIndex:1];
    Script *whenTouchDownScript = [object.scriptList objectAtIndex:2];
    XCTAssertTrue([whenTouchDownScript isKindOfClass:[WhenTouchDownScript class]], "Invalid script type");
}

@end

