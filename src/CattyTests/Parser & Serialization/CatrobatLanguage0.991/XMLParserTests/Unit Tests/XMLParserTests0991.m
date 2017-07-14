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
#import "IfThenLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "PreviousLookBrick.h"

@interface XMLParserTests0991 : XMLAbstractTest

@end

@implementation XMLParserTests0991

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
    Program *program = [self getProgramForXML:@"ObjectLookSensors_0991"];
    
    XCTAssertEqual(2, [program.objectList count], "Invalid object list");
    SpriteObject *background = [program.objectList objectAtIndex:0];
    SpriteObject *object = [program.objectList objectAtIndex:1];
    
    XCTAssertEqual(1, [background.scriptList count], "Invalid script list");
    XCTAssertEqual(1, [object.scriptList count], "Invalid script list");
    
    Script *backgroundScript = [object.scriptList objectAtIndex:0];
    Script *objectScript = [object.scriptList objectAtIndex:0];
    
    XCTAssertEqual(2, [backgroundScript.brickList count], "Invalid brick list");
    XCTAssertEqual(2, [objectScript.brickList count], "Invalid brick list");
    
    SetVariableBrick *backgroundSetVariableBrickName = (SetVariableBrick*)[backgroundScript.brickList objectAtIndex:0];
    SetVariableBrick *backgroundSetVariableBrickNumber = (SetVariableBrick*)[backgroundScript.brickList objectAtIndex:1];
    
    XCTAssertEqual(SENSOR, backgroundSetVariableBrickName.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, backgroundSetVariableBrickNumber.variableFormula.formulaTree.type);
    
    // Uncomment
    //XCTAssertEqual([[SensorManager class] stringForSensor:OBJECT_BACKGROUND_NAME], backgroundSetVariableBrickName.variableFormula.formulaTree.value);
    //XCTAssertEqual([[SensorManager class] stringForSensor:OBJECT_BACKGROUND_NUMBER], backgroundSetVariableBrickNumber.variableFormula.formulaTree.value);
    
    SetVariableBrick *objectSetVariableBrickName = (SetVariableBrick*)[objectScript.brickList objectAtIndex:0];
    SetVariableBrick *objectSetVariableBrickNumber = (SetVariableBrick*)[objectScript.brickList objectAtIndex:1];
    
    XCTAssertEqual(SENSOR, objectSetVariableBrickName.variableFormula.formulaTree.type);
    XCTAssertEqual(SENSOR, objectSetVariableBrickNumber.variableFormula.formulaTree.type);
    
    // Uncomment
    //XCTAssertEqual([[SensorManager class] stringForSensor:OBJECT_LOOK_NAME], objectSetVariableBrickName.variableFormula.formulaTree.value);
    //XCTAssertEqual([[SensorManager class] stringForSensor:OBJECT_LOOK_NUMBER], objectSetVariableBrickNumber.variableFormula.formulaTree.value);
}

- (void)testPreviousLookBrick
{
    Program *program = [self getProgramForXML:@"ValidProgramAllBricks0991"];
    SpriteObject *background = [program.objectList objectAtIndex:0];
    
    Script *backgroundScript = [background.scriptList objectAtIndex:0];
    XCTAssertTrue([backgroundScript.brickList count] >= 26, "Invalid brick list");
    
    Brick *previousLookBrick = (PreviousLookBrick*)[backgroundScript.brickList objectAtIndex:26];
    XCTAssertTrue([previousLookBrick isKindOfClass:[PreviousLookBrick class]], "Invalid brick type");
}

@end

