/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class CreateProgramTVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProgram()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCanCreateProgramWithDrawNewImage() {
        let app = XCUIApplication()
        let programName = "testProgram"

        //Create new Program
        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Program"]
        alertQuery.textFields["Enter your program name here..."].typeText(programName)
        app.alerts["New Program"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[programName]))

        //Add new Object
        app.toolbars.buttons["Add"].tap()
        app.alerts["Add object"].textFields["Enter your object name here..."].typeText("testObject1")
        app.alerts["Add object"].buttons["OK"].tap()
        app.buttons["Draw new image"].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars["Pocket Paint"]))

        //Draw image
        app.tap()

        app.navigationBars.buttons["Looks"].tap()

        let alert = waitForElementToAppear(app.alerts["Save to PocketCode"])
        alert.buttons["Yes"].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[programName]))

        app.staticTexts["testObject1"].tap()
        app.staticTexts["Looks"].tap()
        XCTAssert(app.staticTexts["look"].exists)
        app.navigationBars.buttons["testObject1"].tap()
        app.navigationBars.buttons[programName].tap()

        //Add Background
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        app.toolbars.buttons["Add"].tap()
        app.buttons["Draw new image"].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars["Pocket Paint"]))

        //Draw image
        app.tap()

        app.navigationBars.buttons["Backgrounds"].tap()
        XCTAssert(app.alerts["Save to PocketCode"].exists)
        app.alerts["Save to PocketCode"].buttons["Yes"].tap()

        let addImageAlert = waitForElementToAppear(app.alerts["Add image"])
        addImageAlert.buttons["OK"].tap()

        XCTAssert(app.staticTexts["look"].exists)
        app.navigationBars.buttons["Background"].tap()
        app.navigationBars.buttons["testProgram"].tap()

        //Add Scripts to Object
        app.tables.staticTexts["testObject1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()
        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["When program started"].exists)
        app.toolbars.buttons["Add"].tap()

        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
            app.swipeLeft()
            app.swipeLeft()
        } else {
            app.swipeLeft()
            app.swipeLeft()
        }

        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts["Switch to look"].exists)

        //Add Script to Background
        app.navigationBars.buttons["testObject1"].tap()
        app.navigationBars.buttons["testProgram"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()
        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["When program started"].exists)
        app.toolbars.buttons["Add"].tap()
        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
            app.swipeLeft()
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts["Next background"].exists)
    }
}
