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
        restoreDefaultProgram()
    }

    func testScriptsCanEnterScriptsOfAllMoles() {
        let app = XCUIApplication()
        let appTables = app.tables
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        appTables.staticTexts["Continue"].tap()

        //check every mole for script
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts["Scripts"].tap()
            XCTAssert(app.navigationBars["Scripts"].buttons[object].exists)
            app.navigationBars["Scripts"].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].exists)
        }
    }

    func testScriptsCanDeleteBrickSetSizeTo() {
        let app = XCUIApplication()

        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()

        //delete the SetSizeTo brick
        app.collectionViews.cells.element(boundBy: 1).staticTexts["Set size to"].tap()
        app.buttons["Delete Brick"].tap()

        //Check if Forever brick is now where SetSizeTo was before
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts["Forever"].exists)
    }

    func testScriptsCanDeleteBrickLoop() {
        let app = XCUIApplication()

        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()

        //delete the EndOfLoop
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons["Delete Loop"].tap()

        //Check if deleted successful
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts["Show"].exists)
    }

    func testScriptsCanCopyForeverBrick() {
        let app = XCUIApplication()

        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()

        //copy the Forever brick
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons["Copy Brick"].tap()

        //Check if copied successfull
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts["End of Loop"].exists)
    }

    func testScriptsCanDeleteWhenProgramStartedBrick() {
        let app = XCUIApplication()

        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()

        //delete the WhenProgramStartedBrick
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons["Delete Script"].tap()

        let alert = waitForElementToAppear(app.alerts["Delete this Script?"])
        alert.buttons["Yes"].tap()

        //Check if deltetd successful
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["When tapped"].exists)
    }

    func testScriptsCanDeleteWaitBrick() {
        let app = XCUIApplication()
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()

        app.collectionViews.cells.element(boundBy: 4).staticTexts["Wait"].tap()
        app.buttons["Delete Brick"].tap()
        app.swipeDown()
        XCTAssert(app.staticTexts["Show"].exists)

    }

    func testLooksCanEnterSingleLook() {
        let app = XCUIApplication()

        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Looks"].tap()

        XCTAssert(app.navigationBars["Looks"].exists)
    }

    func testCopyObjectWithIfBricks() {
        let app = XCUIApplication()
        let programName = "testProgram"
        let objectName = "testObject"
        let copiedObjectName = objectName + " (1)"

        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Program"]
        alertQuery.textFields["Enter your program name here..."].typeText(programName)
        app.alerts["New Program"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[programName]))

        // Add new Object
        app.toolbars.buttons["Add"].tap()
        app.alerts["Add object"].textFields["Enter your object name here..."].typeText(objectName)
        app.alerts["Add object"].buttons["OK"].tap()
        app.buttons["Draw new image"].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars["Pocket Paint"]))

        // Draw image
        app.tap()
        app.navigationBars.buttons["Looks"].tap()

        waitForElementToAppear(app.alerts["Save to PocketCode"]).buttons["Yes"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[programName]))

        waitForElementToAppear(app.tables.staticTexts[objectName]).tap()
        waitForElementToAppear(app.staticTexts["Scripts"]).tap()

        waitForElementToAppear(app.toolbars.buttons["Add"]).tap()
        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }

        XCTAssertTrue(app.navigationBars["Control"].exists)

        let startCoord = app.collectionViews.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -500)); // scroll to bottom
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)

        for cellIndex in 0...app.collectionViews.cells.count {
            let cell = app.collectionViews.cells.element(boundBy: cellIndex)
            if cell.staticTexts.count == 2 && cell.staticTexts["If"].exists && cell.staticTexts[" is true then"].exists {
                cell.tap()
            }
        }

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts["End If"].exists)

        app.navigationBars.buttons[objectName].tap()
        app.navigationBars.buttons[programName].tap()

        // Copy object
        app.tables.staticTexts[objectName].swipeLeft()
        app.buttons["More"].tap()

        let sheet = app.sheets["Edit Object"]
        XCTAssertTrue(sheet.exists)

        sheet.buttons["Copy"].tap()

        app.navigationBars.buttons["Pocket Code"].tap()
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts[copiedObjectName].tap()

        app.staticTexts["Scripts"].tap()
        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts["End If"].exists)
    }
}
