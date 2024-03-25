/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class VariableTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    private func createNewProjectAndAddSetVariableBrick(name: String) {
        createProject(name: name, in: app)
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedSetVariable, section: kLocalizedCategoryData, in: app)
    }

    func testDontShowVariablePickerWhenNoVariablesDefinedForObject() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        tapOnVariablePicker(of: kLocalizedSetVariable, in: app)
        XCTAssert(app.navigationBars[kUIFENewVar].exists)
    }

    func testCreateVariableWithMaxLength() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")
        tapOnVariablePicker(of: kLocalizedSetVariable, in: app)
        XCTAssert(app.navigationBars[kUIFENewVar].exists)

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        textField.tap()
        textField.typeText(String(repeating: "i", count: 25))
        app.navigationBars[kUIFENewVar].buttons[kUIFEDone].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)
    }

    func testCreateVariableWithMaxLengthPlusOne() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        tapOnVariablePicker(of: kLocalizedSetVariable, in: app)
        XCTAssert(app.navigationBars[kUIFENewVar].exists)

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        textField.tap()
        textField.typeText(String(repeating: "i", count: 25 + 1))
        app.navigationBars[kUIFENewVar].buttons[kUIFEDone].tap()

        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).exists)
    }

    func testCreateAndSelectVariable() {
        let testVariables = ["testVariable1", "testVariable2"]

        createNewProjectAndAddSetVariableBrick(name: "Test Project")
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEData].tap()
        for variable in testVariables {
            app.navigationBars.buttons[kLocalizedAdd].tap()

            let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
            textField.tap()
            textField.typeText(variable)
            app.navigationBars[kUIFENewVar].buttons[kUIFEDone].tap()
        }

        app.tables.staticTexts[testVariables[1]].tap()
        XCTAssertTrue(waitForElementToAppear(app.buttons[" \"" + testVariables[1] + "\" "]).exists)
    }

    func testEditMarkedTextVariableInFormularEditor() {
        let projectName = "Test Project"
        let testVariable = "TestVariable"

        createNewProjectAndAddSetVariableBrick(name: projectName)
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEAddNewText].tap()
        let alert = waitForElementToAppear(app.alerts[kUIFENewText])
        alert.textFields.firstMatch.typeText(testVariable)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].firstMatch.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        waitForElementToAppear(app.buttons[kUIFEAddNewText]).tap()
        XCTAssertEqual(alert.textFields.firstMatch.value as! String, testVariable)
    }

    func testCreateVariableWithMarkedText() {
        let projectName = "Test Project"
        let testVariable = "TestVariable"

        createNewProjectAndAddSetVariableBrick(name: projectName)
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEAddNewText].tap()
        let newTextAlert = waitForElementToAppear(app.alerts[kUIFENewText])
        newTextAlert.textFields.firstMatch.typeText(testVariable)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].firstMatch.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        waitForElementToAppear(app.buttons[kUIFEData]).tap()
        waitForElementToAppear(app.navigationBars.buttons[kLocalizedAdd]).tap()

        let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
        XCTAssertEqual(textField.value as! String, kLocalizedName)
    }

    func testDeleteVariableInFormulaEditor() {
        let testVariables = ["testVariable1", "testVariable2"]

        createNewProjectAndAddSetVariableBrick(name: "Test Project")
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEData].tap()

        for variable in testVariables {
            app.navigationBars.buttons[kLocalizedAdd].tap()

            let textField = app.textFields.element(matching: .textField, identifier: "formTextField")
            textField.tap()
            textField.typeText(variable)
            app.navigationBars[kUIFENewVar].buttons[kUIFEDone].tap()
        }

        app.tables.staticTexts[testVariables[0]].swipeLeft()
        app.tables.buttons[kLocalizedDelete].tap()

        XCTAssertTrue(app.tables.staticTexts[testVariables[1]].exists)
        XCTAssertFalse(app.tables.staticTexts[testVariables[0]].exists)
        app.tables.staticTexts[testVariables[1]].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" \"" + testVariables[1] + "\" "]).exists)
    }
}
