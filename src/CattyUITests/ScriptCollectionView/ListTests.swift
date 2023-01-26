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

import XCTest

class ListTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    private func createProjectAndAddAddToListBrick(name: String) {
        createProject(name: name, in: app)

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedUserListAdd, section: kLocalizedCategoryData, in: app)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        tapOnListPicker(of: kLocalizedUserListAdd, in: app)
        XCTAssert(app.navigationBars[kUIFENewList].exists)
    }

    func testCreateListWithMaxLength() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        tapOnListPicker(of: kLocalizedUserListAdd, in: app)
        XCTAssert(app.navigationBars[kUIFENewList].exists)

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        textField.tap()
        textField.typeText(String(repeating: "i", count: 25))

        app.navigationBars[kUIFENewList].buttons[kUIFEDone].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)
    }

    func testCreateListWithMaxLengthPlusOne() {
        createProjectAndAddAddToListBrick(name: "Test Project")

        tapOnListPicker(of: kLocalizedUserListAdd, in: app)
        XCTAssert(app.navigationBars[kUIFENewList].exists)

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        textField.tap()
        textField.typeText(String(repeating: "i", count: 25 + 1))

        app.navigationBars[kUIFENewList].buttons[kUIFEDone].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedPocketCode]).exists)
    }

    func testCreateAndSelectList() {
        let testLists = ["testList1", "testList2"]

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEData].tap()
        for variable in testLists {
            app.navigationBars.buttons[kLocalizedAdd].tap()

            let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
            textField.tap()
            textField.typeText(variable)

            let switchControl = app.switches.element(matching: .switch, identifier: "formSwitch")
            switchControl.tap()

            app.navigationBars[kUIFENewList].buttons[kUIFEDone].tap()
        }

        app.tables.staticTexts[testLists[1]].tap()
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
        app.buttons[kLocalizedDone].firstMatch.tap()
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        waitForElementToAppear(app.buttons[kUIFEAddNewText]).tap()
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
        app.buttons[kLocalizedDone].firstMatch.tap()
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        waitForElementToAppear(app.buttons[kUIFEData]).tap()
        waitForElementToAppear(app.navigationBars.buttons[kLocalizedAdd]).tap()

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        XCTAssertEqual(textField.value as! String, kLocalizedName)
    }

    func testDeleteListInFormulaEditor() {
        let testLists = ["testList1", "testList2"]

        createProjectAndAddAddToListBrick(name: "Test Project")
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedUserListAdd).tap()

        app.buttons[kLocalizedEditFormula].tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEData].tap()

        for variable in testLists {
            app.navigationBars.buttons[kLocalizedAdd].tap()
            let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
            textField.tap()
            textField.typeText(variable)

            let switchControl = app.switches.element(matching: .switch, identifier: "formSwitch")
            switchControl.tap()

            app.navigationBars[kUIFENewList].buttons[kUIFEDone].tap()
        }

        app.tables.staticTexts[testLists[0]].swipeLeft()
        app.tables.buttons[kLocalizedDelete].tap()

        XCTAssertTrue(app.tables.staticTexts[testLists[1]].exists)
        XCTAssertFalse(app.tables.staticTexts[testLists[0]].exists)
        app.tables.staticTexts[testLists[1]].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" *" + testLists[1] + "* "]).exists)
    }
}
