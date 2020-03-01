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

class CreateProjectTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
    }

    func testCanCreateProjectWithDrawNewImage() {
        let projectName = "testProject"
        let testObject = "testObject1"

        //Create new Project
        app.tables.staticTexts[kLocalizedNewProject].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        addObjectAndDrawNewImage(name: testObject, in: app)

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))
        app.staticTexts[testObject].tap()
        app.staticTexts[kLocalizedLooks].tap()

        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedLookFilename]).exists)
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

        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedLookFilename]).exists)
        app.navigationBars.buttons[kLocalizedBackground].tap()
        app.navigationBars.buttons[projectName].tap()

        //Add Scripts to Object
        app.tables.staticTexts[testObject].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedWhenProjectStarted, section: kLocalizedCategoryControl, in: app)
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenProjectStarted].exists)

        addBrick(label: kLocalizedSetLook, section: kLocalizedCategoryLook, in: app)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedSetLook].exists)

        //Add Script to Background
        app.navigationBars.buttons[testObject].tap()
        app.navigationBars.buttons[projectName].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBrick(label: kLocalizedWhenProjectStarted, section: kLocalizedCategoryControl, in: app)
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenProjectStarted].exists)

        addBrick(label: kLocalizedNextBackground, section: kLocalizedCategoryLook, in: app)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedNextBackground].exists)
    }

    func testCanCreateProjectWithEmojiAndSpecialCharacters() {
        let projectName = "🙀"
        let helloText = "你好"

        //Create new Project
        app.tables.staticTexts[kLocalizedNewProject].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        addObjectAndDrawNewImage(name: helloText, in: app)

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))
        XCTAssert(app.staticTexts[helloText].exists)
    }
}
