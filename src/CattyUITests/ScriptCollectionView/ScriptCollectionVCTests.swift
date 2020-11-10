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

class ScriptCollectionVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
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
        let message = String(repeating: "a", count: 250)

        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedBroadcast, section: kLocalizedCategoryControl, in: app)

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedBroadcast).children(matching: .other).element.tap()

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons[kLocalizedDone].tap()

        let alert = app.alerts[kLocalizedNewMessage]
        alert.textFields[kLocalizedEnterYourMessageHere].typeText(message)
        alert.buttons[kLocalizedOK].tap()

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedBroadcast).children(matching: .other).element.tap()

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons[kLocalizedDone].tap()

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
        app.buttons[kLocalizedSensorLoudness].tap()
        app.buttons[kLocalizedDone].tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedScripts]).exists)
    }

    func testEmptyStringInFormulaEditor() {
        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedSetVariable, section: kLocalizedCategoryVariable, in: app)

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()

        app.buttons[kUIFEAddNewText].tap()
        app.alerts[kUIFENewText].buttons[kLocalizedOK].tap()

        app.buttons[kLocalizedDone].tap()
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
    
    func testMoveABrickWithMoveMode() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.element(boundBy: 5).tap()
        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)

        let moveButton = app.sheets[kLocalizedEditBrick].buttons[kLocalizedMoveBrick]
        print(moveButton.label)
        XCTAssertEqual(kLocalizedMoveBrick, moveButton.label)
        moveButton.tap()

        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedSetSizeTo, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedForever].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedPlaceAt].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTextBeginsWith(kLocalizedWait, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 5).staticTexts[kLocalizedShow].exists)

        app.collectionViews.cells.element(boundBy: 4).press(forDuration: 1.0, thenDragTo: app.collectionViews.cells.element(boundBy: 2))
        app.collectionViews.cells.element(boundBy: 5).press(forDuration: 1.0, thenDragTo: app.collectionViews.cells.element(boundBy: 3))

        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedSetSizeTo, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedForever].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedShow].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedPlaceAt].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 5).staticTextBeginsWith(kLocalizedWait, ignoreLeadingWhiteSpace: true).exists)
    }

    func testMoveABrickWitouthMoveMode() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedSetSizeTo, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedForever].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedPlaceAt].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTextBeginsWith(kLocalizedWait, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 5).staticTexts[kLocalizedShow].exists)

        app.collectionViews.cells.element(boundBy: 5).press(forDuration: 1.0, thenDragTo: app.collectionViews.cells.element(boundBy: 3))

        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedSetSizeTo, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedForever].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedShow].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedPlaceAt].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 5).staticTextBeginsWith(kLocalizedWait, ignoreLeadingWhiteSpace: true).exists)
    }
}
