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

class ListTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithoutAnimations()
    }

    private func createProjectAndAddAddToListBrick(name: String) {
        createProject(name: name, in: app)

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedUserListAdd, section: kLocalizedCategoryData, in: app)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.identifierTextBeginsWith(kLocalizedUserListAdd).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionList].exists)
    }

    func testCreateListWithMaxLength() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.identifierTextBeginsWith(kLocalizedUserListAdd).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionList].exists)

        app.buttons[kUIFEActionVarPro].tap()
        app.alerts[kUIFENewList].textFields[kLocalizedEnterYourListNameHere].typeText(String(repeating: "i", count: 250))
        app.alerts[kUIFENewList].buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)
    }

    func testCreateListWithMaxLengthPlusOne() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.identifierTextBeginsWith(kLocalizedUserListAdd).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionList].exists)

        app.buttons[kUIFEActionVarPro].tap()
        app.alerts[kUIFENewList].textFields[kLocalizedEnterYourListNameHere].typeText(String(repeating: "i", count: 250 + 1))
        app.alerts[kUIFENewList].buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedPocketCode]).exists)
    }

    func testCreateAndSelectList() {
        let listName = "TestList"

        createProjectAndAddAddToListBrick(name: "Test Project")

        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEVariableList].tap()
        app.buttons[kLocalizedNew].tap()
        waitForElementToAppear(app.buttons[kUIFENewList]).tap()
        waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()

        let alert = waitForElementToAppear(app.alerts[kUIFENewList])
        alert.textFields.firstMatch.typeText(listName)
        alert.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" *" + listName + "* "]).exists)
    }

    func testCreateVariableAndTapChooseButton() {
        let listName = "TestList"

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEVariableList].tap()
        app.buttons[kLocalizedNew].tap()
        waitForElementToAppear(app.buttons[kUIFENewList]).tap()
        waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()

        let alert = waitForElementToAppear(app.alerts[kUIFENewList])
        alert.textFields.firstMatch.typeText(listName)
        alert.buttons[kLocalizedOK].tap()

        app.buttons["del active"].tap()
        app.buttons[kUIFEVariableList].tap()
        app.buttons["Lists"].tap()
        app.buttons[kUIFETake].tap()
        app.buttons[kUIFEDone].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" *" + listName + "* "]).exists)
    }

    func testCreateListAndTapSelectedRowInPickerView() {
        let testLists = ["testList1", "testList2"]

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        for variable in testLists {
            app.buttons[kUIFEVariableList].tap()
            app.buttons[kLocalizedNew].tap()
            waitForElementToAppear(app.buttons[kUIFENewList]).tap()
            waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()

            let alert = waitForElementToAppear(app.alerts[kUIFENewList])
            alert.textFields.firstMatch.typeText(variable)
            alert.buttons[kLocalizedOK].tap()
        }

        app.buttons["del active"].tap()
        app.buttons[kUIFEVariableList].tap()
        app.buttons["Lists"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: testLists[1])
        app.pickerWheels[testLists[1]].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" *" + testLists[1] + "* "]).exists)
    }

    func testEditMarkedTextListInFormularEditor() {
        let listName = "TestList"

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEAddNewText].tap()
        let alert = waitForElementToAppear(app.alerts[kUIFENewText])
        alert.textFields.firstMatch.typeText(listName)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        app.buttons[kUIFEAddNewText].tap()
        XCTAssertEqual(alert.textFields.firstMatch.value as! String, listName)
    }

    func testCreateListWithMarkedText() {
        let listName = "TestList"

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEAddNewText].tap()
        let newTextAlert = waitForElementToAppear(app.alerts[kUIFENewText])
        newTextAlert.textFields.firstMatch.typeText(listName)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        app.buttons[kUIFEVariableList].tap()
        app.buttons[kUIFEVar].tap()
        waitForElementToAppear(app.buttons[kUIFENewList]).tap()
        waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()
        let newVarAlert = waitForElementToAppear(app.alerts[kUIFENewList])
        XCTAssertEqual(newVarAlert.textFields.firstMatch.value as! String, "")
    }

    func testDeleteListInFormulaEditor() {
        let testLists = ["testList1", "testList2"]

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        for variable in testLists {
            app.buttons[kUIFEVariableList].tap()
            app.buttons[kLocalizedNew].tap()
            waitForElementToAppear(app.buttons[kUIFENewList]).tap()
            waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()

            let alert = waitForElementToAppear(app.alerts[kUIFENewList])
            alert.textFields.firstMatch.typeText(variable)
            alert.buttons[kLocalizedOK].tap()
        }

        app.buttons["del active"].tap()
        app.buttons[kUIFEVariableList].tap()
        app.buttons["Lists"].tap()
        app.scrollViews.firstMatch.buttons["Delete"].tap()
        app.buttons[kUIFETake].tap()
        app.buttons[kUIFEDone].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" *" + testLists[1] + "* "]).exists)
    }
}
