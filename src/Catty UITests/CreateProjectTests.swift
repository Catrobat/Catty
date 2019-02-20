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

class CreateProjectTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testCanCreateProjectWithDrawNewImage() {
        let app = XCUIApplication()
        let projectName = "testProject"
        let testObject = "testObject1"

        //Create new Project
        app.tables.staticTexts[kLocalizedNew].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Add new Object
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        app.alerts[kLocalizedAddObject].textFields[kLocalizedEnterYourObjectNameHere].typeText(testObject)
        app.alerts[kLocalizedAddObject].buttons[kLocalizedOK].tap()
        app.buttons[kLocalizedDrawNewImage].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        //Draw image
        app.tap()

        app.navigationBars.buttons[kLocalizedLooks].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedSaveToPocketCode])
        alert.buttons[kLocalizedYes].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        app.staticTexts[testObject].tap()
        app.staticTexts[kLocalizedLooks].tap()
        XCTAssert(app.staticTexts[kLocalizedLook].exists)
        app.navigationBars.buttons[testObject].tap()
        app.navigationBars.buttons[projectName].tap()

        //Add Background
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedBackgrounds].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        //Draw image
        app.tap()

        app.navigationBars.buttons[kLocalizedBackgrounds].tap()
        XCTAssert(app.alerts[kLocalizedSaveToPocketCode].exists)
        app.alerts[kLocalizedSaveToPocketCode].buttons[kLocalizedYes].tap()

        let addImageAlert = waitForElementToAppear(app.alerts[kLocalizedAddImage])
        addImageAlert.buttons[kLocalizedOK].tap()

        XCTAssert(app.staticTexts[kLocalizedLook].exists)
        app.navigationBars.buttons[kLocalizedBackground].tap()
        app.navigationBars.buttons[projectName].tap()

        //Add Scripts to Object
        app.tables.staticTexts[testObject].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        if app.navigationBars[kUIFavouritesTitle].exists {
            app.swipeLeft()
        }
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenProjectStarted].exists)
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        if app.navigationBars[kUIFavouritesTitle].exists {
            app.swipeLeft()
            app.swipeLeft()
            app.swipeLeft()
        } else {
            app.swipeLeft()
            app.swipeLeft()
        }

        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedSetLook].exists)

        //Add Script to Background
        app.navigationBars.buttons[testObject].tap()
        app.navigationBars.buttons[projectName].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        if app.navigationBars[kUIFavouritesTitle].exists {
            app.swipeLeft()
        }
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenProjectStarted].exists)
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        if app.navigationBars[kUIFavouritesTitle].exists {
            app.swipeLeft()
            app.swipeLeft()
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedNextBackground].exists)
    }

    func testCanCreateProjectWithEmojiAndSpecialCharacters() {
        let app = XCUIApplication()
        let projectName = "🙀"
        let helloText = "你好"

        //Create new Project
        app.tables.staticTexts[kLocalizedNew].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Add new Object
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        app.alerts[kLocalizedAddObject].textFields[kLocalizedEnterYourObjectNameHere].typeText(helloText)
        app.alerts[kLocalizedAddObject].buttons[kLocalizedOK].tap()
        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        //Draw image
        app.tap()

        waitForElementToAppear(app.navigationBars.buttons[kLocalizedLooks]).tap()
        XCTAssert(app.alerts[kLocalizedSaveToPocketCode].exists)
        app.alerts[kLocalizedSaveToPocketCode].buttons[kLocalizedYes].tap()

        XCTAssert(app.staticTexts[helloText].exists)
    }
}
