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

class BackgroundsTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testScriptsCanEnterScripts() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedProjects].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        XCTAssert(app.navigationBars[kLocalizedScripts].exists)
    }

    func testScriptsCanDeleteAllScriptsViaDelete() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars

        testScriptsCanEnterScripts()

        app.navigationBars.buttons[kLocalizedDelete].tap()
        toolbarsQuery.buttons[kLocalizedSelectAllItems].tap()
        toolbarsQuery.buttons[kLocalizedDelete].tap()

        let yesButton = app.alerts[kLocalizedDeleteTheseBricks].buttons[kLocalizedYes]
        yesButton.tap()
        app.navigationBars.buttons[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.staticTexts["Tap \"+\" to add Script"].exists)
    }

    func testScriptsCanDeleteWhenProjectStartsViaTap() {
        let app = XCUIApplication()

        testScriptsCanEnterScripts()

        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons[kLocalizedDeleteScript].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedDeleteThisScript])
        alert.buttons[kLocalizedYes].tap()

        app.navigationBars.buttons[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.staticTexts["Tap \"+\" to add Script"].exists)
    }

    func testBackgroundsCanEnterBackgrounds() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedContinue].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedBackgrounds].tap()

        XCTAssert(app.navigationBars[kLocalizedBackgrounds].exists)
    }

    func testBackgroundsCanCopyAndDeleteSingleBackgroundViaEditMode() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars

        testBackgroundsCanEnterBackgrounds()

        //copy background
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedCopyLooks].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        toolbarsQuery.buttons[kLocalizedCopy].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)

        //delete background
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedDeleteBackgrounds].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()

        toolbarsQuery.buttons[kLocalizedDelete].tap()

        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)
    }

    func testBackgroundsCanDeleteAllBackgroundsViaEditMode() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars

        testBackgroundsCanEnterBackgrounds()

        //copy background
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedCopyLooks].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        toolbarsQuery.buttons[kLocalizedCopy].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)

        //copy all backgrounds
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedCopyLooks].tap()
        toolbarsQuery.buttons[kLocalizedSelectAllItems].tap()
        toolbarsQuery.buttons[kLocalizedCopy].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (2)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (3)"].exists)

        //delete all backgrounds
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedDeleteBackgrounds].tap()

        toolbarsQuery.buttons[kLocalizedSelectAllItems].tap()
        toolbarsQuery.buttons[kLocalizedDelete].tap()

        XCTAssertEqual(app.tables.cells.count, 0)
    }

    func testBackgroundsCanAbortDeleteAllBackgroundsViaEditMode() {
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars

        testBackgroundsCanEnterBackgrounds()

        //copy background
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedCopyLooks].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        toolbarsQuery.buttons[kLocalizedCopy].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)

        //copy all backgrounds
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedCopyLooks].tap()
        toolbarsQuery.buttons[kLocalizedSelectAllItems].tap()
        toolbarsQuery.buttons[kLocalizedCopy].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (2)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (3)"].exists)

        //delete all backgrounds
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        app.buttons[kLocalizedDeleteBackgrounds].tap()

        toolbarsQuery.buttons[kLocalizedSelectAllItems].tap()
        app.navigationBars.buttons[kLocalizedCancel].tap()

        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (1)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (2)"].exists)
        XCTAssert(app.tables.staticTexts[kLocalizedBackground + " (3)"].exists)
    }

    func testBackgroundsCanDeleteSingleBackgroundViaSwipe() {
        let app = XCUIApplication()
        let tablesQuery = app.tables

        testBackgroundsCanEnterBackgrounds()

        tablesQuery.staticTexts[kLocalizedBackground].swipeLeft()

        XCTAssert(app.buttons[kLocalizedDelete].exists)

        app.buttons[kLocalizedDelete].tap()
        let yesButton = app.alerts[kLocalizedDeleteThisBackground].buttons[kLocalizedYes]
        yesButton.tap()
        XCTAssertFalse(app.tables.staticTexts[kLocalizedBackground].exists)
    }

    func testBackgroundsCanAbortDeleteSingleBackgroundViaSwipe() {
        let app = XCUIApplication()
        let tablesQuery = app.tables

        testBackgroundsCanEnterBackgrounds()

        tablesQuery.staticTexts[kLocalizedBackground].swipeLeft()

        XCTAssert(app.buttons[kLocalizedDelete].exists)

        app.buttons[kLocalizedDelete].tap()
        let yesButton = app.alerts[kLocalizedDeleteThisBackground].buttons[kLocalizedCancel]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts[kLocalizedBackground].exists)
    }

    func testBackgroundsCanShowAndHideDetailsForBackgroundViaEditMode() {
        let app = XCUIApplication()
        testBackgroundsCanEnterBackgrounds()

        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()

        if app.buttons[kLocalizedHideDetails].exists {
            app.buttons[kLocalizedHideDetails].tap()
            app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        }

        app.buttons[kLocalizedShowDetails].tap()

        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()
        XCTAssert(app.buttons[kLocalizedHideDetails].exists)
        app.buttons[kLocalizedHideDetails].tap()
        app.navigationBars[kLocalizedBackgrounds].buttons[kLocalizedEdit].tap()

        XCTAssert(app.buttons[kLocalizedShowDetails].exists)
        app.buttons[kLocalizedCancel].tap()

        XCTAssert(app.navigationBars[kLocalizedBackgrounds].exists)
    }

    func testSoundsCanEnterSounds() {
        let app = XCUIApplication()

        app.tables.staticTexts[kLocalizedProjects].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedSounds].tap()

        XCTAssert(app.navigationBars[kLocalizedSounds].exists)
    }
}
