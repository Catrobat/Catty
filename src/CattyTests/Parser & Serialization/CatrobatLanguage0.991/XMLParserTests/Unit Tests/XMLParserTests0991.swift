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

import XCTest

@testable import Pocket_Code

class XMLParserTests0991: XMLAbstractTest {
    var formulaManager: FormulaManager = FormulaManager()
    
     func testFlashBrick() {
        let program = self.getProgramForXML(xmlFile: "LedFlashBrick0991")
    
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        let object = program.objectList.object(at: 0) as! SpriteObject
    
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script
        
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
    
        var flashBrick = script.brickList.object(at: 0) as! FlashBrick
        XCTAssertEqual(1, flashBrick.flashChoice, "Invalid flash choice")
    
        flashBrick = script.brickList.object(at: 1) as! FlashBrick
        XCTAssertEqual(0, flashBrick.flashChoice, "Invalid flash choice")
    }
    
    func testLedBrick() {
        let program = self.getProgramForXML(xmlFile: "LedFlashBrick0991")
        
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        let object = program.objectList.object(at: 0) as! SpriteObject
        
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script
        
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
        
        var flashBrick = script.brickList.object(at: 2) as! FlashBrick
        XCTAssertEqual(1, flashBrick.flashChoice, "Invalid flash choice")
        
        flashBrick = script.brickList.object(at: 3) as! FlashBrick
        XCTAssertEqual(0, flashBrick.flashChoice, "Invalid flash choice")
    }
    
    func testIfThenLogicBeginBrick() {
        let program = self.getProgramForXML(xmlFile: "LogicBricks_0991")
    
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        let object = program.objectList.object(at: 0) as! SpriteObject

        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script

        XCTAssertEqual(8, script.brickList.count, "Invalid brick list")
    
        // tests for IfThenLogicBeginBrick
        let ifThenLogicBeginBrick = script.brickList.object(at: 0) as! IfThenLogicBeginBrick
        let ifThenLogicEndBrick = script.brickList.object(at: 2) as! IfThenLogicEndBrick
    
        XCTAssertNotNil(ifThenLogicBeginBrick, "IfThenLogicBeginBrick not found at index 0.")
    
        // check if condition is not null
        XCTAssertNotNil(ifThenLogicBeginBrick.ifCondition.formulaTree, "Invalid Formula for If Condition")
    
    
        // check if end brick exists and is correctly paired
        XCTAssertNotNil(ifThenLogicEndBrick, "IfThenLogicEndBrick not found at index 2.")
        XCTAssertNotNil(ifThenLogicBeginBrick.ifEndBrick, "No associated If End brick for if brick.")
        XCTAssertEqual(ifThenLogicEndBrick, ifThenLogicBeginBrick.ifEndBrick, "If End brick in script and that associated to if brick do not match.")
        XCTAssertEqual(ifThenLogicBeginBrick, ifThenLogicBeginBrick.ifEndBrick.ifBeginBrick, "If Begin brick associated to If End brick does not match.")
    
        // tests for IfLogicBeginBrick
        let ifLogicBeginBrick = script.brickList.object(at: 3) as! IfLogicBeginBrick
        let ifLogicElseBrick = script.brickList.object(at: 5) as! IfLogicElseBrick
        let ifLogicEndBrick = script.brickList.object(at: 7) as! IfLogicEndBrick
    
        XCTAssertNotNil(ifLogicBeginBrick, "IfThenLogicBeginBrick not found at index 0.")
        XCTAssertNotNil(ifLogicElseBrick, "IfThenLogicBeginBrick not found at index 0.")
        XCTAssertNotNil(ifLogicEndBrick, "IfThenLogicBeginBrick not found at index 0.")
    
    
        // check if condition is not null
        XCTAssertNotNil(ifLogicBeginBrick.ifCondition.formulaTree, "Invalid Formula for If Condition")
        
        
        // check if else and end brick exists and is correctly paired
        XCTAssertNotNil(ifLogicBeginBrick.ifElseBrick, "No associated If Else brick for if brick.")
        XCTAssertNotNil(ifLogicBeginBrick.ifEndBrick, "No associated If End brick for if brick.")
        
        XCTAssertEqual(ifLogicBeginBrick.ifElseBrick, ifLogicElseBrick, "If Else brick in script and that associated to if brick do not match.")
        XCTAssertEqual(ifLogicBeginBrick.ifEndBrick, ifLogicEndBrick, "If End brick in script and that associated to if brick do not match.")
        
        XCTAssertEqual(ifLogicEndBrick.ifElseBrick, ifLogicElseBrick, "IfLogicElseBrick associated to IfLogicEndBrick does not match.")
        XCTAssertEqual(ifLogicEndBrick.ifBeginBrick, ifLogicBeginBrick, "IfLogicBeginBrick associated to IfLogicEndBrick does not match.")
        
        XCTAssertEqual(ifLogicElseBrick.ifBeginBrick, ifLogicBeginBrick, "IfLogicBeginBrick associated to IfLogicElseBrick does not match.")
        XCTAssertEqual(ifLogicElseBrick.ifEndBrick, ifLogicEndBrick, "IfLogicEndBrick associated to IfLogicElseBrick does not match.")
    }
    
    func testObjectLookSensors() {
        let program = self.getProgramForXML(xmlFile: "Sensors_0991")
    
        XCTAssertTrue(program.objectList.count >= 2, "Invalid object list")
        let background = program.objectList.object(at: 0) as! SpriteObject
        let object = program.objectList.object(at: 1) as! SpriteObject
    
        XCTAssertEqual(1, background.scriptList.count, "Invalid script list")
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
    
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        let objectScript = object.scriptList.object(at: 0) as! Script
    
        XCTAssertEqual(2, backgroundScript.brickList.count, "Invalid brick list")
        XCTAssertEqual(3, objectScript.brickList.count, "Invalid brick list")
    
        let backgroundSetVariableBrickName = backgroundScript.brickList.object(at: 0) as! SetVariableBrick
        let backgroundSetVariableBrickNumber = backgroundScript.brickList.object(at: 1) as! SetVariableBrick
        
        XCTAssertEqual(ElementType.SENSOR, backgroundSetVariableBrickName.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, backgroundSetVariableBrickNumber.variableFormula.formulaTree.type)
    
        XCTAssertTrue(BackgroundNameSensor.tag == backgroundSetVariableBrickName.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(BackgroundNumberSensor.tag == backgroundSetVariableBrickNumber.variableFormula.formulaTree.value, "Invalid sensor")
        
        let objectSetVariableBrickName = objectScript.brickList.object(at: 0) as! SetVariableBrick
        let objectSetVariableBrickNumber = objectScript.brickList.object(at: 1) as! SetVariableBrick
        
        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickName.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickNumber.variableFormula.formulaTree.type)
        
        XCTAssertTrue(LookNameSensor.tag == objectSetVariableBrickName.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(LookNumberSensor.tag == objectSetVariableBrickNumber.variableFormula.formulaTree.value, "Invalid sensor")
        
        let objectSetVariableBrickColor = objectScript.brickList.object(at: 2) as! SetVariableBrick
        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickColor.variableFormula.formulaTree.type)
        XCTAssertTrue(ColorSensor.tag == objectSetVariableBrickColor.variableFormula.formulaTree.value, "Invalid sensor")
    }
    
    func testPreviousLookBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
    
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 26, "Invalid brick list")
    
        let previousLookBrick = backgroundScript.brickList.object(at: 26) as! Brick
        XCTAssertTrue(previousLookBrick.isKind(of: PreviousLookBrick.self), "Invalid brick type")
    }
    
    func testRepeatUntilBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 27, "Invalid brick list")
        
        let previousLookBrick = backgroundScript.brickList.object(at: 27) as! Brick
        XCTAssertTrue(previousLookBrick.isKind(of: RepeatUntilBrick.self), "Invalid brick type")
    }
    
    func testSetBackgroundBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject

        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 29, "Invalid brick list")
    
        let brick = backgroundScript.brickList.object(at: 29) as! Brick
        XCTAssertTrue(brick.isKind(of: SetBackgroundBrick.self), "Invalid brick type")
   
        let setBackgroundBrick = brick as! SetBackgroundBrick
        XCTAssertTrue(setBackgroundBrick.look != nil, "Invalid look");
    }
    
    func testSpeakAndWaitBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 30, "Invalid brick list")
    
        let brick = backgroundScript.brickList.object(at: 30) as! Brick
        XCTAssertTrue(brick.isKind(of: SpeakAndWaitBrick.self), "Invalid brick type")
    
        let speakAndWaitBrick = brick as! SpeakAndWaitBrick
        XCTAssertTrue(speakAndWaitBrick.formula != nil, "Invalid formula")
    }
    
    func testLocationSensors() {
        let program = self.getProgramForXML(xmlFile: "Sensors_0991")
    
        XCTAssertTrue(program.objectList.count >= 3, "Invalid object list")
        let object = program.objectList.object(at: 2) as! SpriteObject
    
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
    
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
    
        let latitudeBrick = script.brickList.object(at: 0) as! SetVariableBrick
        let longitudeBrick = script.brickList.object(at: 1) as! SetVariableBrick
        let altitudeBrick = script.brickList.object(at: 2) as! SetVariableBrick
        let locationAccuracyBrick = script.brickList.object(at: 3) as! SetVariableBrick
    
        XCTAssertEqual(ElementType.SENSOR, latitudeBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, longitudeBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, altitudeBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, locationAccuracyBrick.variableFormula.formulaTree.type)

        XCTAssertTrue(LatitudeSensor.tag == latitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(LongitudeSensor.tag == longitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(AltitudeSensor.tag == altitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(LocationAccuracySensor.tag == locationAccuracyBrick.variableFormula.formulaTree.value, "Invalid sensor")
    }
    
    func testScreenTouchSensors() {
        let program = self.getProgramForXML(xmlFile: "Sensors_0991")
        
        XCTAssertTrue(program.objectList.count >= 4, "Invalid object list")
        let object = program.objectList.object(at: 3) as! SpriteObject
        
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
        
        let fingerTouchedBrick = script.brickList.object(at: 0) as! SetVariableBrick
        let fingerXBrick = script.brickList.object(at: 1) as! SetVariableBrick
        let fingerYBrick = script.brickList.object(at: 2) as! SetVariableBrick
        let lastFingerIndexBrick = script.brickList.object(at: 3) as! SetVariableBrick
        
        XCTAssertEqual(ElementType.SENSOR, fingerTouchedBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, fingerXBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, fingerYBrick.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, lastFingerIndexBrick.variableFormula.formulaTree.type)
        
        XCTAssertTrue(FingerTouchedSensor.tag == fingerTouchedBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(FingerXSensor.tag == fingerXBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(FingerYSensor.tag == fingerYBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertTrue(LastFingerIndexSensor.tag == lastFingerIndexBrick.variableFormula.formulaTree.value, "Invalid sensor")
    }
    
    func testCameraBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
    
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 33, "Invalid brick list")
    
        var cameraBrick = backgroundScript.brickList.object(at: 31) as! Brick
        XCTAssertTrue(cameraBrick.isKind(of: CameraBrick.self), "Invalid brick type")
        XCTAssertTrue((cameraBrick as! CameraBrick).isEnabled(), "Invalid brick option")
    
        cameraBrick = backgroundScript.brickList.object(at: 32) as! Brick
        XCTAssertTrue(cameraBrick.isKind(of: CameraBrick.self), "Invalid brick type")
        XCTAssertFalse((cameraBrick as! CameraBrick).isEnabled(), "Invalid brick option")
    }
    
    func testChooseCameraBrick() {
        let program = self.getProgramForXML(xmlFile: "CameraBricks_0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
    
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertEqual(backgroundScript.brickList.count, 4, "Invalid brick list")
    
        var backCamera = backgroundScript.brickList.object(at: 0) as! Brick
        XCTAssertTrue(backCamera.isKind(of: ChooseCameraBrick.self), "Invalid brick type")
        XCTAssertEqual(0, (backCamera as! ChooseCameraBrick).cameraPosition, "Invalid cameraPosition")
        
        backCamera = backgroundScript.brickList.object(at: 1) as! Brick
        XCTAssertTrue(backCamera.isKind(of: ChooseCameraBrick.self), "Invalid brick type")
        XCTAssertEqual(1, (backCamera as! ChooseCameraBrick).cameraPosition, "Invalid cameraPosition")
        
        backCamera = backgroundScript.brickList.object(at: 2) as! Brick
        XCTAssertTrue(backCamera.isKind(of: ChooseCameraBrick.self), "Invalid brick type")
        XCTAssertEqual(0, (backCamera as! ChooseCameraBrick).cameraPosition, "Invalid cameraPosition")
        
        backCamera = backgroundScript.brickList.object(at: 3) as! Brick
        XCTAssertTrue(backCamera.isKind(of: ChooseCameraBrick.self), "Invalid brick type")
        XCTAssertEqual(1, (backCamera as! ChooseCameraBrick).cameraPosition, "Invalid cameraPosition")
    }
    
    func testSayBubbleBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 34, "Invalid brick list")
    
        let sayBubbleBrick = backgroundScript.brickList.object(at: 33) as! Brick
        XCTAssertTrue(sayBubbleBrick.isKind(of: SayBubbleBrick.self), "Invalid brick type")
        XCTAssertNotNil((sayBubbleBrick as! SayBubbleBrick).formula, "Invalid formula")
    }
    
    func testThinkBubbleBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 35, "Invalid brick list")
        
        let thinkBubbleBrick = backgroundScript.brickList.object(at: 34) as! Brick
        XCTAssertTrue(thinkBubbleBrick.isKind(of: ThinkBubbleBrick.self), "Invalid brick type")
        XCTAssertNotNil((thinkBubbleBrick as! ThinkBubbleBrick).formula, "Invalid formula")
    }
    
    func testSayForBubbleBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 36, "Invalid brick list")
        
        let sayForBubbleBrick = backgroundScript.brickList.object(at: 35) as! Brick
        XCTAssertTrue(sayForBubbleBrick.isKind(of: SayForBubbleBrick.self), "Invalid brick type")
        XCTAssertNotNil((sayForBubbleBrick as! SayForBubbleBrick).stringFormula, "Invalid formula")
        XCTAssertNotNil((sayForBubbleBrick as! SayForBubbleBrick).intFormula, "Invalid formula")
    }
    
    func testThinkForBubbleBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 37, "Invalid brick list")
        
        let thinkForBubbleBrick = backgroundScript.brickList.object(at: 36) as! Brick
        XCTAssertTrue(thinkForBubbleBrick.isKind(of: ThinkForBubbleBrick.self), "Invalid brick type")
        XCTAssertNotNil((thinkForBubbleBrick as! ThinkForBubbleBrick).stringFormula, "Invalid formula")
        XCTAssertNotNil((thinkForBubbleBrick as! ThinkForBubbleBrick).intFormula, "Invalid formula")
    }
    
    func testAddItemToUserListBrick() {
        let program = self.getProgramForXML(xmlFile: "AddItemToUserListBrick0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
    
        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
    
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(2, script.brickList.count, "Invalid brick list")
    
        var addItemToUserListBrick = script.brickList.object(at: 0) as! AddItemToUserListBrick
        XCTAssertEqual("programList", addItemToUserListBrick.userList.name, "Invalid list name")
    
        let numberValue = self.formulaManager.interpret(addItemToUserListBrick.listFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 66), numberValue, "Invalid list value")
    
        addItemToUserListBrick = script.brickList.object(at: 1) as! AddItemToUserListBrick
        XCTAssertEqual("objectList", addItemToUserListBrick.userList.name, "Invalid list name")
    
        let stringValue = self.formulaManager.interpret(addItemToUserListBrick.listFormula, for: object) as! String
        XCTAssertEqual("hallo", stringValue, "Invalid list value")
    }
    
    func testWaitUntilBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let background = program.objectList.object(at: 0) as! SpriteObject
        
        let backgroundScript = background.scriptList.object(at: 0) as! Script
        XCTAssertTrue(backgroundScript.brickList.count >= 41, "Invalid brick list")
        
        let waitUntilBrick = backgroundScript.brickList.object(at: 40) as! Brick
        XCTAssertTrue(waitUntilBrick.isKind(of: WaitUntilBrick.self), "Invalid brick type")
        let numberValue = self.formulaManager.interpret((waitUntilBrick as! WaitUntilBrick).waitCondition, for: background) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 1), numberValue, "Invalid list value")
    }
    
    func testNumberOfItemsFunction() {
        let program = self.getProgramForXML(xmlFile: "NumberOfItemsInListFunction0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        
        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(3, script.brickList.count, "Invalid brick list")
        
        let addItemToUserListBrick = script.brickList.object(at: 2) as! AddItemToUserListBrick
        let formula = addItemToUserListBrick.listFormula;
    
        XCTAssertTrue(formula!.formulaTree.value == "NUMBER_OF_ITEMS")
        XCTAssertEqual(ElementType.FUNCTION, formula!.formulaTree.type)
    
        XCTAssertTrue(formula!.formulaTree.value as String == "NUMBER_OF_ITEMS")
    }
    
    func testElementOfListFunction() {
        let program = self.getProgramForXML(xmlFile: "ElementOfListFunction0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")

        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
    
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(1, script.brickList.count, "Invalid brick list")
    
        let waitBrick = script.brickList.object(at: 0) as! WaitBrick
        let formula = waitBrick.timeToWaitInSeconds
    
        XCTAssertEqual(ElementType.NUMBER, formula.formulaTree.leftChild.type)
        XCTAssertTrue(formula.formulaTree.leftChild.value == "1")
    
        XCTAssertEqual(ElementType.USER_LIST, formula.formulaTree.rightChild.type);
        XCTAssertTrue(formula.formulaTree.rightChild.value == "test")
    
        XCTAssertTrue(formula.formulaTree.value == "LIST_ITEM")
        XCTAssertEqual(ElementType.FUNCTION, formula.formulaTree.type)
    
        XCTAssertTrue(formula.formulaTree.value as String == "LIST_ITEM")
    }
    
    func testDeleteItemOfUserListBrick() {
        let program = self.getProgramForXML(xmlFile: "DeleteItemOfUserListBrick0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        
        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
    
        var deleteItemOfUserListBrick = script.brickList.object(at: 2) as! DeleteItemOfUserListBrick
        XCTAssertEqual("testlist", deleteItemOfUserListBrick.userList.name, "Invalid list name")
    
        var numberValue = self.formulaManager.interpret(deleteItemOfUserListBrick.listFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 2), numberValue, "Invalid list value")
    
        deleteItemOfUserListBrick = script.brickList.object(at: 3) as! DeleteItemOfUserListBrick
        XCTAssertEqual("testlist", deleteItemOfUserListBrick.userList.name, "Invalid list name");
    
        numberValue = self.formulaManager.interpret(deleteItemOfUserListBrick.listFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 1), numberValue, "Invalid list value")
    }
    
    func testInsertItemIntoUserListBrick() {
        let program = self.getProgramForXML(xmlFile: "InsertItemIntoUserListBrick0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        
        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(2, script.brickList.count, "Invalid brick list")
    
        var insertItemIntoUserListBrick = script.brickList.object(at: 0) as! InsertItemIntoUserListBrick
        XCTAssertEqual("hallo", insertItemIntoUserListBrick.userList.name, "Invalid list name")
    
        let numberValue = self.formulaManager.interpret(insertItemIntoUserListBrick.elementFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 55), numberValue, "Invalid list value")
    
        var indexValue = self.formulaManager.interpret(insertItemIntoUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 1), indexValue, "Invalid list value")
    
        insertItemIntoUserListBrick = script.brickList.object(at: 1) as! InsertItemIntoUserListBrick
        XCTAssertEqual("hallo", insertItemIntoUserListBrick.userList.name, "Invalid list name")
    
        let stringValue = self.formulaManager.interpret(insertItemIntoUserListBrick.elementFormula, for: object) as! String
        XCTAssertEqual("test", stringValue, "Invalid list value")
    
        indexValue = self.formulaManager.interpret(insertItemIntoUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(integerLiteral: 2), indexValue, "Invalid list value")
    }
    
    func testReplaceItemInUserListBrick() {
        let program = self.getProgramForXML(xmlFile: "ReplaceItemInUserListBrick0991")
        XCTAssertEqual(1, program.objectList.count, "Invalid object list")
        
        let object = program.objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        
        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")
        
        var replaceItemInUserListBrick = script.brickList.object(at: 2) as! ReplaceItemInUserListBrick
        XCTAssertEqual("testlist", replaceItemInUserListBrick.userList.name, "Invalid list name")
    
        let stringValue = self.formulaManager.interpret(replaceItemInUserListBrick.elementFormula, for: object) as! String
        XCTAssertEqual("hello", stringValue, "Invalid list value");
    
        var indexValue = self.formulaManager.interpret(replaceItemInUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(integerLiteral: 1), indexValue, "Invalid list value")
    
        replaceItemInUserListBrick = script.brickList.object(at: 3) as! ReplaceItemInUserListBrick
        XCTAssertEqual("testlist", replaceItemInUserListBrick.userList.name, "Invalid list name")
    
        let numberValue = self.formulaManager.interpret(replaceItemInUserListBrick.elementFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(floatLiteral: 33), numberValue, "Invalid list value")
    
        indexValue = self.formulaManager.interpret(replaceItemInUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(integerLiteral: 2), indexValue, "Invalid list value")
    }
    
    func testBroadcastScript() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let object = program.objectList.object(at: 1) as! SpriteObject
        let broadcastScript = object.scriptList.object(at: 0) as! Script
        XCTAssertTrue(broadcastScript.isKind(of: BroadcastScript.self), "Invalid script type")
    }
    
    func testWhenScript() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let object = program.objectList.object(at: 1) as! SpriteObject
        let whenScript = object.scriptList.object(at: 1) as! Script
        XCTAssertTrue(whenScript.isKind(of: WhenScript.self), "Invalid script type")
    }
    
    func testWhenTouchDownScript() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let object = program.objectList.object(at: 1) as! SpriteObject
        let whenTouchDownScript = object.scriptList.object(at: 2) as! Script
        XCTAssertTrue(whenTouchDownScript.isKind(of: WhenTouchDownScript.self), "Invalid script type")
    }
}
