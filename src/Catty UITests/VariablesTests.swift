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

import XCTest

class VariablesTests: XCTestCase, UITestProtocol {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
        app = XCUIApplication()
    }

    func testDontShowVariablePickerWhenNoVariablesDefinedForObject() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        app.tables.staticTexts["New"].tap()
        app.alerts["New Project"].textFields["Enter your project name here..."].typeText("Test Project")
        XCUIApplication().alerts["New Project"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        skipFrequentlyUsedBricks(app)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeDown()

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Add ").children(matching: .other).element.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Add ").children(matching: .other).element.tap()
        XCTAssert(app.sheets["List type"].exists)
    }

    func testCreateVariableWithMaxLength() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)

        app.buttons["for all objects"].tap()
        app.alerts["New Variable"].textFields["Enter your variable name here..."].typeText(String(repeating: "i", count: 250))
        app.alerts["New Variable"].buttons["OK"].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts["When project started"]).exists)
    }

    func testCreateVariableWithMaxLengthPlusOne() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)

        app.buttons["for all objects"].tap()
        app.alerts["New Variable"].textFields["Enter your variable name here..."].typeText(String(repeating: "i", count: 250 + 1))
        app.alerts["New Variable"].buttons["OK"].tap()
        XCTAssert(app.alerts["Pocket Code"].exists)
    }

    func testCreateAndSelectVariable() {
        let variableName = "testVariable"

        createNewProjectAndAddSetVariableBrick(name: "Test Project")
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons["Cancel"]).exists)

        app.buttons["Var/List"].tap()
        app.buttons["New"].tap()
        waitForElementToAppear(app.buttons["New Variable"]).tap()
        waitForElementToAppear(app.buttons["for all objects"]).tap()

        let alert = waitForElementToAppear(app.alerts["New Variable"])
        alert.textFields.firstMatch.typeText(variableName)
        alert.buttons["OK"].tap()
        app.buttons["Done"].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" \"" + variableName + "\" "]).exists)
    }

    private func createNewProjectAndAddSetVariableBrick(name: String) {
        createProject(name: name, in: app)

        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        skipFrequentlyUsedBricks(app)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts["Set variable"].tap()
    }
    func testEditMarkedTextVariableInFormularEditor() {
        let projectName = "Test Project"
        let testVariable = "TestVariable"

        createNewProjectAndAddSetVariableBrick(name: projectName)
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons["ABC"].tap()
        let alert = waitForElementToAppear(app.alerts[kUIFENewText])
        alert.textFields.firstMatch.typeText(testVariable)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        app.buttons["ABC"].tap()
        XCTAssertEqual(alert.textFields.firstMatch.value as! String, testVariable)
    }
    func testCreateVariableWithMarkedText() {
        let projectName = "Test Project"
        let testVariable = "TestVariable"

        createNewProjectAndAddSetVariableBrick(name: projectName)
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons["ABC"].tap()
        let newTextAlert = waitForElementToAppear(app.alerts[kUIFENewText])
        newTextAlert.textFields.firstMatch.typeText(testVariable)
        app.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        app.buttons[kUIFEVariableList].tap()
        app.buttons[kUIFEVar].tap()
        waitForElementToAppear(app.buttons[kUIFENewVar]).tap()
        waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()
        let newVarAlert = waitForElementToAppear(app.alerts[kUIFENewVar])
        XCTAssertEqual(newVarAlert.textFields.firstMatch.value as! String, "")
    }
}
