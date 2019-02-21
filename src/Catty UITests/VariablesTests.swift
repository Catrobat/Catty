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

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionVar].exists)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        app.tables.staticTexts[kLocalizedNew].tap()
        app.alerts[kLocalizedNewProject].textFields[kLocalizedEnterYourProjectNameHere].typeText("Test Project")
        XCUIApplication().alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        skipFrequentlyUsedBricks(app)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeDown()

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedUserListAdd + " ").children(matching: .other).element.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedUserListAdd + " ").children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionList].exists)
    }

    func testCreateVariableWithMaxLength() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionVar].exists)

        app.buttons[kUIFEActionVarPro].tap()
        app.alerts[kUIFENewVar].textFields[kLocalizedEnterYourVariableNameHere].typeText(String(repeating: "i", count: 250))
        app.alerts[kUIFENewVar].buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)
    }

    func testCreateVariableWithMaxLengthPlusOne() {
        createNewProjectAndAddSetVariableBrick(name: "Test Project")

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .other).element.tap()
        XCTAssert(app.sheets[kUIFEActionVar].exists)

        app.buttons[kUIFEActionVarPro].tap()
        app.alerts[kUIFENewVar].textFields[kLocalizedEnterYourVariableNameHere].typeText(String(repeating: "i", count: 250 + 1))
        app.alerts[kUIFENewVar].buttons[kLocalizedOK].tap()
        XCTAssert(app.alerts[kLocalizedPocketCode].exists)
    }

    func testCreateAndSelectVariable() {
        let variableName = "testVariable"

        createNewProjectAndAddSetVariableBrick(name: "Test Project")
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFEVariableList].tap()
        app.buttons[kLocalizedNew].tap()
        waitForElementToAppear(app.buttons[kUIFENewVar]).tap()
        waitForElementToAppear(app.buttons[kUIFEActionVarPro]).tap()

        let alert = waitForElementToAppear(app.alerts[kUIFENewVar])
        alert.textFields.firstMatch.typeText(variableName)
        alert.buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDone].tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons[" \"" + variableName + "\" "]).exists)
    }

    private func createNewProjectAndAddSetVariableBrick(name: String) {
        createProject(name: name, in: app)

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        skipFrequentlyUsedBricks(app)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts[kLocalizedSetVariable].tap()
    }
}
