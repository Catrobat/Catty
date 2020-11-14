/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class XMLParserTests0992: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testFlashBrick() {
        let project = self.getProjectForXML(xmlFile: "LedFlashBrick0992")

        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")
        let object = project.scene.object(at: 0)!

        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script

        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")

        var flashBrick = script.brickList.object(at: 0) as! FlashBrick
        XCTAssertEqual(1, flashBrick.flashChoice, "Invalid flash choice")

        flashBrick = script.brickList.object(at: 1) as! FlashBrick
        XCTAssertEqual(0, flashBrick.flashChoice, "Invalid flash choice")
    }

    func testIfThenLogicBeginBrick() {
        let project = self.getProjectForXML(xmlFile: "LogicBricks_0992")

        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")
        let object = project.scene.object(at: 0)!

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
        let project = self.getProjectForXML(xmlFile: "Sensors_0992")

        XCTAssertGreaterThanOrEqual(project.scene.objects().count, 2, "Invalid object list")
        let background = project.scene.object(at: 0)!
        let object = project.scene.object(at: 1)!

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

        XCTAssertEqual(BackgroundNameSensor.tag, backgroundSetVariableBrickName.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(BackgroundNumberSensor.tag, backgroundSetVariableBrickNumber.variableFormula.formulaTree.value, "Invalid sensor")

        let objectSetVariableBrickName = objectScript.brickList.object(at: 0) as! SetVariableBrick
        let objectSetVariableBrickNumber = objectScript.brickList.object(at: 1) as! SetVariableBrick

        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickName.variableFormula.formulaTree.type)
        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickNumber.variableFormula.formulaTree.type)

        XCTAssertEqual(LookNameSensor.tag, objectSetVariableBrickName.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(LookNumberSensor.tag, objectSetVariableBrickNumber.variableFormula.formulaTree.value, "Invalid sensor")

        let objectSetVariableBrickColor = objectScript.brickList.object(at: 2) as! SetVariableBrick
        XCTAssertEqual(ElementType.SENSOR, objectSetVariableBrickColor.variableFormula.formulaTree.type)
        XCTAssertEqual(ColorSensor.tag, objectSetVariableBrickColor.variableFormula.formulaTree.value, "Invalid sensor")
    }

    func testLocationSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_0992")

        XCTAssertGreaterThanOrEqual(project.scene.objects().count, 3, "Invalid object list")
        let object = project.scene.object(at: 2)!

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

        XCTAssertEqual(LatitudeSensor.tag, latitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(LongitudeSensor.tag, longitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(AltitudeSensor.tag, altitudeBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(LocationAccuracySensor.tag, locationAccuracyBrick.variableFormula.formulaTree.value, "Invalid sensor")
    }

    func testScreenTouchSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_0992")

        XCTAssertGreaterThanOrEqual(project.scene.objects().count, 4, "Invalid object list")
        let object = project.scene.object(at: 3)!

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

        XCTAssertEqual(FingerTouchedSensor.tag, fingerTouchedBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(FingerXSensor.tag, fingerXBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(FingerYSensor.tag, fingerYBrick.variableFormula.formulaTree.value, "Invalid sensor")
        XCTAssertEqual(LastFingerIndexSensor.tag, lastFingerIndexBrick.variableFormula.formulaTree.value, "Invalid sensor")
    }

    func testChooseCameraBrick() {
        let project = self.getProjectForXML(xmlFile: "CameraBricks_0992")
        let background = project.scene.object(at: 0)!

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

    func testNumberOfItemsFunction() {
        let project = self.getProjectForXML(xmlFile: "NumberOfItemsInListFunction0992")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(3, script.brickList.count, "Invalid brick list")

        let addItemToUserListBrick = script.brickList.object(at: 2) as! AddItemToUserListBrick
        let formula = addItemToUserListBrick.listFormula

        XCTAssertEqual(formula!.formulaTree.value, "NUMBER_OF_ITEMS")
        XCTAssertEqual(ElementType.FUNCTION, formula!.formulaTree.type)

        XCTAssertEqual(formula!.formulaTree.value as String, "NUMBER_OF_ITEMS")
    }

    func testElementOfListFunction() {
        let project = self.getProjectForXML(xmlFile: "ElementOfListFunction0992")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(1, script.brickList.count, "Invalid brick list")

        let waitBrick = script.brickList.object(at: 0) as! WaitBrick
        let formula = waitBrick.timeToWaitInSeconds

        XCTAssertEqual(ElementType.NUMBER, formula.formulaTree.leftChild.type)
        XCTAssertEqual(formula.formulaTree.leftChild.value, "1")

        XCTAssertEqual(ElementType.USER_LIST, formula.formulaTree.rightChild.type)
        XCTAssertEqual(formula.formulaTree.rightChild.value, "test")

        XCTAssertEqual(formula.formulaTree.value, "LIST_ITEM")
        XCTAssertEqual(ElementType.FUNCTION, formula.formulaTree.type)

        XCTAssertEqual(formula.formulaTree.value as String, "LIST_ITEM")
    }

    func testDeleteItemOfUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "DeleteItemOfUserListBrick0992")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")

        var deleteItemOfUserListBrick = script.brickList.object(at: 2) as! DeleteItemOfUserListBrick
        XCTAssertEqual("testlist", deleteItemOfUserListBrick.userList.name, "Invalid list name")

        var numberValue = self.formulaManager.interpret(deleteItemOfUserListBrick.listFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 2), numberValue, "Invalid list value")

        deleteItemOfUserListBrick = script.brickList.object(at: 3) as! DeleteItemOfUserListBrick
        XCTAssertEqual("testlist", deleteItemOfUserListBrick.userList.name, "Invalid list name")

        numberValue = self.formulaManager.interpret(deleteItemOfUserListBrick.listFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 1), numberValue, "Invalid list value")
    }

    func testInsertItemIntoUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "InsertItemIntoUserListBrick0992")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(2, script.brickList.count, "Invalid brick list")

        var insertItemIntoUserListBrick = script.brickList.object(at: 0) as! InsertItemIntoUserListBrick
        XCTAssertEqual("hallo", insertItemIntoUserListBrick.userList.name, "Invalid list name")

        let numberValue = self.formulaManager.interpret(insertItemIntoUserListBrick.elementFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 55), numberValue, "Invalid list value")

        var indexValue = self.formulaManager.interpret(insertItemIntoUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 1), indexValue, "Invalid list value")

        insertItemIntoUserListBrick = script.brickList.object(at: 1) as! InsertItemIntoUserListBrick
        XCTAssertEqual("hallo", insertItemIntoUserListBrick.userList.name, "Invalid list name")

        let stringValue = self.formulaManager.interpret(insertItemIntoUserListBrick.elementFormula, for: object) as! String
        XCTAssertEqual("test", stringValue, "Invalid list value")

        indexValue = self.formulaManager.interpret(insertItemIntoUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 2), indexValue, "Invalid list value")
    }

    func testReplaceItemInUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "ReplaceItemInUserListBrick0992")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")

        var replaceItemInUserListBrick = script.brickList.object(at: 2) as! ReplaceItemInUserListBrick
        XCTAssertEqual("testlist", replaceItemInUserListBrick.userList.name, "Invalid list name")

        let stringValue = self.formulaManager.interpret(replaceItemInUserListBrick.elementFormula, for: object) as! String
        XCTAssertEqual("hello", stringValue, "Invalid list value")

        var indexValue = self.formulaManager.interpret(replaceItemInUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 1), indexValue, "Invalid list value")

        replaceItemInUserListBrick = script.brickList.object(at: 3) as! ReplaceItemInUserListBrick
        XCTAssertEqual("testlist", replaceItemInUserListBrick.userList.name, "Invalid list name")

        let numberValue = self.formulaManager.interpret(replaceItemInUserListBrick.elementFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 33), numberValue, "Invalid list value")

        indexValue = self.formulaManager.interpret(replaceItemInUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 2), indexValue, "Invalid list value")
    }

    func testDisabledBricks() {
        let project = self.getProjectForXML(xmlFile: "DisabledBricks_0992")
        let object = project.scene.object(at: 0)!
        let startScript = object.scriptList.object(at: 0) as! Script

        let disabledBrick = startScript.brickList.object(at: 0) as! SetVariableBrick
        let enabledBrick = startScript.brickList?.object(at: 1) as! ChangeVariableBrick

        XCTAssertTrue(disabledBrick.isDisabled)
        XCTAssertFalse(enabledBrick.isDisabled)
    }

    func testWhenBackgroundChangesScript() {

        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0992")
        let object = project.allObjects().first!
        let whenBackgroundChangesScript = object.scriptList.object(at: 1) as! Script

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(whenBackgroundChangesScript.isKind(of: WhenBackgroundChangesScript.self), "Invalid script type")
    }

    func testWhenConditionScript() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0992")
        let object = project.allObjects().first!
        let whenConditionScript = object.scriptList.object(at: 2) as! Script

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(whenConditionScript.isKind(of: WhenConditionScript.self), "Invalid script type")
    }

    func testAskBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0992")
        let askBrick = (project.scene.object(at: 1)!.scriptList.object(at: 0) as! Script).brickList.object(at: 1) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(askBrick.isKind(of: AskBrick.self), "Invalid brick type")
    }

    func testSetInstrumentBrick() {
        let availableInstruments = Instrument.allCases
        let project = self.getProjectForXML(xmlFile: "SamplerBricks_0992")
        let object = project.scene.object(at: 0)!
        let startScript = object.scriptList.object(at: 0) as! Script

        XCTAssertEqual(availableInstruments.count, startScript.brickList.count)

        var instruments = Set<Instrument>()

        for brick in startScript.brickList {
            let setInstrumentBrick = brick as! SetInstrumentBrick
            instruments.insert(setInstrumentBrick.instrument)
        }

        XCTAssertEqual(availableInstruments.count, instruments.count)

        for instrument in availableInstruments {
            XCTAssertTrue(instruments.contains(instrument))
        }
    }
}
