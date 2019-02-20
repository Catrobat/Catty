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

class ObjectTVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testScriptsCanEnterScriptsOfAllMoles() {
        let app = XCUIApplication()
        let appTables = app.tables
        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        appTables.staticTexts[kLocalizedContinue].tap()

        //check every mole for script
        for object in projectObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[kLocalizedScripts].tap()
            XCTAssert(app.navigationBars[kLocalizedScripts].buttons[object].exists)
            app.navigationBars[kLocalizedScripts].buttons[object].tap()
            app.navigationBars[object].buttons[kLocalizedMyFirstProject].tap()
            XCTAssert(app.navigationBars[kLocalizedMyFirstProject].exists)
        }
    }

    func testScriptsCanDeleteBrickSetSizeTo() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the SetSizeTo brick
        app.collectionViews.cells.element(boundBy: 1).staticTexts["Set size to "].tap()
        app.buttons[kLocalizedDeleteBrick].tap()

        //Check if Forever brick is now where SetSizeTo was before
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedForever].exists)
    }

    func testScriptsCanDeleteBrickLoop() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the EndOfLoop
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons[kLocalizedDeleteLoop].tap()

        //Check if deleted successful
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedShow].exists)
    }

    func testScriptsCanCopyForeverBrick() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //copy the Forever brick
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons[kLocalizedCopyBrick].tap()

        //Check if copied successfull
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedEndOfLoop].exists)
    }

    func testScriptsCanDeleteWhenProjectStartedBrick() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the WhenProjectStartedBrick
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons[kLocalizedDeleteScript].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedDeleteThisScript])
        alert.buttons[kLocalizedYes].tap()

        //Check if deltetd successful
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenTapped].exists)
    }

    func testScriptsCanDeleteWaitBrick() {
        let app = XCUIApplication()
        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.element(boundBy: 4).staticTexts["Wait "].tap()
        app.buttons[kLocalizedDeleteBrick].tap()
        app.swipeDown()
        XCTAssert(app.staticTexts[kLocalizedShow].exists)

    }

    func testLooksCanEnterSingleLook() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedLooks].tap()

        XCTAssert(app.navigationBars[kLocalizedLooks].exists)
    }

    func testCopyObjectWithIfBricks() {
        let app = XCUIApplication()
        let projectName = "testProject"
        let objectName = "testObject"
        let copiedObjectName = objectName + " (1)"

        app.tables.staticTexts[kLocalizedNew].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        // Add new Object
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        app.alerts[kLocalizedAddObject].textFields[kLocalizedEnterYourObjectNameHere].typeText(objectName)
        app.alerts[kLocalizedAddObject].buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDrawNewImage].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        // Draw image
        app.tap()
        app.navigationBars.buttons[kLocalizedLooks].tap()

        waitForElementToAppear(app.alerts[kLocalizedSaveToPocketCode]).buttons[kLocalizedYes].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        waitForElementToAppear(app.tables.staticTexts[objectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        waitForElementToAppear(app.toolbars.buttons[kLocalizedUserListAdd]).tap()
        if app.navigationBars[kUIFavouritesTitle].exists {
            app.swipeLeft()
        }

        XCTAssertTrue(app.navigationBars[kLocalizedControl].exists)

        let startCoord = app.collectionViews.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -500)); // scroll to bottom
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)

        for cellIndex in 0...app.collectionViews.cells.count {
            let cell = app.collectionViews.cells.element(boundBy: cellIndex)
            if cell.staticTexts.count == 2 && cell.staticTexts["If "].exists && cell.staticTexts[" is true then"].exists {
                cell.tap()
            }
        }

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)

        app.navigationBars.buttons[objectName].tap()
        app.navigationBars.buttons[projectName].tap()

        // Copy object
        app.tables.staticTexts[objectName].swipeLeft()
        app.buttons[kLocalizedMore].tap()

        let sheet = app.sheets[kLocalizedEditObject]
        XCTAssertTrue(sheet.exists)

        sheet.buttons[kLocalizedCopy].tap()

        app.navigationBars.buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts[copiedObjectName].tap()

        app.staticTexts[kLocalizedScripts].tap()
        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)
    }
}
