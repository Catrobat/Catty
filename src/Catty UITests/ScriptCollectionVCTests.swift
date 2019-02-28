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

class ScriptCollectionVCTests: XCTestCase, UITestProtocol {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
        app = XCUIApplication()
    }

    func testCopyIfLogicBeginBrick() {
        createProject(name: "testProject", in: app)
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        waitForElementToAppear(app.toolbars.buttons[kLocalizedUserListAdd]).tap()
        skipFrequentlyUsedBricks(app)

        XCTAssertTrue(app.navigationBars[kUIControlTitle].exists)

        let startCoord = app.collectionViews.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -500)); // scroll to bottom
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)

        for cellIndex in 0...app.collectionViews.cells.count {
            let cell = app.collectionViews.cells.element(boundBy: cellIndex)
            if cell.staticTexts.count == 2 && cell.staticTextBeginsWith(kLocalizedIfBegin).exists && cell.staticTextBeginsWith(kLocalizedIfBeginSecondPart).exists {
                cell.tap()
            }
        }

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)

        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.sheets[kLocalizedEditBrick].exists)

        let copyButton = app.sheets[kLocalizedEditBrick].buttons.element(boundBy: 1)
        XCTAssertEqual(kLocalizedCopyBrick, copyButton.label)
        copyButton.tap()

        XCTAssertEqual(5, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTextBeginsWith(kLocalizedIfBeginSecondPart).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedEndIf].exists)
    }

    func testLengthOfBroadcastMessage() {
        let message = String(repeating: "a", count: 250)

        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        skipFrequentlyUsedBricks(app)

        app.collectionViews.staticTexts[kLocalizedBroadcast].tap()
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
        XCTAssert(app.alerts[kLocalizedPocketCode].exists)
    }

    func testWaitBrick() {
        createProject(name: "testProject", in: app)
        XCUIApplication().tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        skipFrequentlyUsedBricks(app)

        app.collectionViews.staticTextBeginsWith(kLocalizedWait).tap()
        app.collectionViews.cells.otherElements.containing(NSPredicate(format: "label CONTAINS %@", kLocalizedWait)).children(matching: .button).element.tap()

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

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        skipFrequentlyUsedBricks(app)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts[kLocalizedSetVariable].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedSetVariable).children(matching: .button).element.tap()

        app.buttons[kUIFEAddNewText].tap()
        app.alerts[kUIFENewText].buttons[kLocalizedOK].tap()

        app.buttons[kLocalizedDone].tap()
        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedScripts]).exists)
    }

}
