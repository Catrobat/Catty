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

class ScriptCollectionVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testCopyIfLogicBeginBrick() {
        createProject(name: "testProject", in: app)
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        XCTAssertEqual(0, app.collectionViews.cells.count)

        addBrick(labels: [kLocalizedIfBegin, kLocalizedIfBeginSecondPart], section: kLocalizedCategoryControl, in: app)

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)

        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)

        let copyButton = app.sheets[kLocalizedEditBrick].buttons[kLocalizedCopyBrick]

        XCTAssertEqual(kLocalizedCopyBrick, copyButton.label)
        copyButton.tap()

        XCTAssertEqual(5, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTextBeginsWith(kLocalizedIfBeginSecondPart, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedEndIf].exists)
    }

    func testLengthOfBroadcastMessage() {
        let message = String(repeating: "a", count: 25)

        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedBroadcast, section: kLocalizedCategoryEvent, in: app)
        tapOnMessagePicker(of: kLocalizedBroadcast, in: app)

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons[kLocalizedDone].firstMatch.tap()

        let alert = app.alerts[kLocalizedNewMessage]
        alert.textFields[kLocalizedEnterYourMessageHere].typeText(message)
        alert.buttons[kLocalizedOK].tap()

        tapOnMessagePicker(of: kLocalizedBroadcast, in: app)

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons[kLocalizedDone].firstMatch.tap()

        alert.textFields[kLocalizedEnterYourMessageHere].typeText(message + "b")
        alert.buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).exists)
    }

    func testWaitBrick() {
        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedWait, section: kLocalizedCategoryControl, in: app)

        app.collectionViews.cells.otherElements.identifierTextBeginsWith(kLocalizedWait).children(matching: .button).element.tap()
        XCTAssertTrue(waitForElementToAppear(app.buttons[kLocalizedCancel]).exists)

        app.buttons[kUIFESensor].tap()
        app.tables.staticTexts[kLocalizedSensorLoudness].tap()
        app.buttons[kLocalizedDone].firstMatch.tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedScripts]).exists)
    }

    func testEmptyStringInFormulaEditor() {
        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedSetVariable, section: kLocalizedCategoryData, in: app)

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()

        app.buttons[kUIFEAddNewText].tap()
        app.alerts[kUIFENewText].buttons[kLocalizedOK].tap()

        app.buttons[kLocalizedDone].firstMatch.tap()
        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedScripts]).exists)
    }

    func testEditBrickButtonDisableOrEnable() {
        createProject(name: "testProject", in: app)
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        XCTAssertEqual(0, app.collectionViews.cells.count)

        addBrick(label: kLocalizedHide, section: kLocalizedCategoryLook, in: app)

        XCTAssertEqual(2, app.collectionViews.cells.count)
        app.collectionViews.cells.element(boundBy: 1).tap()

        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)

        let disableButton = app.sheets[kLocalizedEditBrick].buttons[kLocalizedDisableBrick]
        XCTAssertTrue(disableButton.exists)

        disableButton.tap()
        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)

        let enableButton = app.sheets[kLocalizedEditBrick].buttons[kLocalizedEnableBrick]
        XCTAssertTrue(enableButton.exists)
        enableButton.tap()

        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)
        XCTAssertTrue(disableButton.exists)
    }
}
