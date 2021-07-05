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

import XCTest

@testable import Pocket_Code

final class XMLParserTests098: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp( ) {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testFlashBrick() {
        let project = self.getProjectForXML(xmlFile: "LedFlashBrick098")

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

    func testLedBrick() {
        let project = self.getProjectForXML(xmlFile: "LedFlashBrick098")

        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")
        let object = project.scene.object(at: 0)!

        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")
        let script = object.scriptList.object(at: 0) as! Script

        XCTAssertEqual(4, script.brickList.count, "Invalid brick list")

        var flashBrick = script.brickList.object(at: 2) as! FlashBrick
        XCTAssertEqual(1, flashBrick.flashChoice, "Invalid flash choice")

        flashBrick = script.brickList.object(at: 3) as! FlashBrick
        XCTAssertEqual(0, flashBrick.flashChoice, "Invalid flash choice")
    }

    func testAddItemToUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "AddItemToUserListBrick098")
        XCTAssertEqual(1, project.scene.objects().count, "Invalid object list")

        let object = project.scene.object(at: 0)!
        XCTAssertEqual(1, object.scriptList.count, "Invalid script list")

        let script = object.scriptList.object(at: 0) as! Script
        XCTAssertEqual(2, script.brickList.count, "Invalid brick list")

        var addItemToUserListBrick = script.brickList.object(at: 0) as! AddItemToUserListBrick
        XCTAssertEqual("programList", addItemToUserListBrick.userList.name, "Invalid list name")

        let numberValue = self.formulaManager.interpret(addItemToUserListBrick.listFormula, for: object) as! NSNumber

        XCTAssertEqual(NSNumber(value: 66), numberValue, "Invalid list value")

        addItemToUserListBrick = script.brickList.object(at: 1) as! AddItemToUserListBrick
        XCTAssertEqual("objectList", addItemToUserListBrick.userList.name, "Invalid list name")

        let stringValue = self.formulaManager.interpret(addItemToUserListBrick.listFormula, for: object) as! String
        XCTAssertEqual("hallo", stringValue, "Invalid list value")
    }

    func testDeleteItemOfUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "DeleteItemOfUserListBrick098")
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
        let project = self.getProjectForXML(xmlFile: "InsertItemIntoUserListBrick098")
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
        XCTAssertEqual(NSNumber(value: 1), indexValue, "Invalid index value")

        insertItemIntoUserListBrick = script.brickList.object(at: 1) as! InsertItemIntoUserListBrick
        XCTAssertEqual("hallo", insertItemIntoUserListBrick.userList.name, "Invalid list name")

        let stringValue = self.formulaManager.interpret(insertItemIntoUserListBrick.elementFormula, for: object) as! String
        XCTAssertEqual("test", stringValue, "Invalid list value")

        indexValue = self.formulaManager.interpret(insertItemIntoUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 2), indexValue, "Invalid index value")
    }

    func testReplaceItemInUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "ReplaceItemInUserListBrick098")
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
        XCTAssertEqual(NSNumber(value: 1), indexValue, "Invalid index value")

        replaceItemInUserListBrick = script.brickList.object(at: 3) as! ReplaceItemInUserListBrick
        XCTAssertEqual("testlist", replaceItemInUserListBrick.userList.name, "Invalid list name")

        let numberValue = self.formulaManager.interpret(replaceItemInUserListBrick.elementFormula, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 33), numberValue, "Invalid list value")

        indexValue = self.formulaManager.interpret(replaceItemInUserListBrick.index, for: object) as! NSNumber
        XCTAssertEqual(NSNumber(value: 2), indexValue, "Invalid index value")
    }
}
