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

class ProgramsTVCTests: XCTestCase, UITestProtocol {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProgram()

        app = XCUIApplication()
    }

    func testCanAddNewProgram() {
        app.tables.staticTexts["Programs"].tap()
        app.toolbars.buttons["Add"].tap()

        let alertQuery = waitForElementToAppear(app.alerts["New Program"])
        alertQuery.textFields["Enter your program name here..."].typeText("testProgram")

        app.alerts["New Program"].buttons["OK"].tap()

        XCTAssert(waitForElementToAppear(app.navigationBars["testProgram"]).exists)

        app.navigationBars.buttons["Programs"].tap()

        XCTAssert(app.tables.staticTexts["testProgram"].exists)
    }

    func testCanCancelAddNewProgram() {
        app.tables.staticTexts["Programs"].tap()
        app.toolbars.buttons["Add"].tap()

        let alertQuery = app.alerts["New Program"]
        alertQuery.textFields["Enter your program name here..."].typeText("testProgram")

        app.alerts["New Program"].buttons["Cancel"].tap()

        XCTAssert(app.navigationBars["Programs"].exists)
    }

    func testCanCancelEdit() {
        app.tables.staticTexts["Programs"].tap()
        app.navigationBars["Programs"].buttons["Edit"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(app.navigationBars["Programs"].exists)
    }

    func testCanCancelMoreActionSheetMenu() {
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(!app.buttons["Cancel"].exists)
    }

    func testCanCopyMyFirstProgram() {
        app.tables.staticTexts["Programs"].tap()

        copyProgram(name: "My first program", newName: "My second program")

        XCTAssert(app.tables.staticTexts.count == 2)
        XCTAssert(app.tables.staticTexts["My second program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Programs"]).exists)

        XCTAssert(app.tables.staticTexts.count == 2)
        XCTAssert(app.tables.staticTexts["My second program"].exists)
    }

    func testCanCancelCopyMyFirstProgram() {
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Copy"].exists)
        app.buttons["Copy"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Copy program"]).exists)
        let alertQuery = app.alerts["Copy program"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your program name here..."].typeText("My second program")
        XCTAssert(alertQuery.buttons["Cancel"].exists)
        alertQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Programs"]).exists)

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)
    }

    func testCanRenameMyFirstProgram() {
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Rename Program"]).exists)
        let alertQuery = app.alerts["Rename Program"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your program name here..."].typeText("My renamed program")
        XCTAssert(alertQuery.buttons["OK"].exists)
        alertQuery.buttons["OK"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Programs"]).exists)

        // check again
        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed program"].exists)
    }

    func testCanCancelRenameMyFirstProgram() {
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Rename Program"]).exists)
        let alertQuery = app.alerts["Rename Program"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your program name here..."].typeText("My renamed program")
        XCTAssert(alertQuery.buttons["Cancel"].exists)
        alertQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Programs"]).exists)

        // check again
        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)
    }

    func testBulkDeletePrograms() {
        let copyProgramName = "My first program"
        app.tables.staticTexts["Programs"].tap()
        waitForElementToAppear(app.navigationBars["Programs"]).buttons["Edit"].tap()

        if !app.buttons["Hide Details"].exists {
            app.buttons["Show Details"].tap()
        } else {
            app.buttons["Cancel"].tap()
        }

        for num in 1..<8 {
            copyProgram(name: copyProgramName, newName: copyProgramName + String(num))
        }

        waitForElementToAppear(app.navigationBars["Programs"]).buttons["Edit"].tap()
        waitForElementToAppear(app.buttons["Delete Programs"]).tap()
        waitForElementToAppear(app.buttons["Select All"]).tap()
        waitForElementToAppear(app.buttons["Delete"]).tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars["Programs"]).exists)
        XCTAssert(app.tables.cells.count == 1)
    }

    private func copyProgram(name: String, newName: String) {
        let tablesQuery = app.tables
        tablesQuery.staticTexts[name].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        waitForElementToAppear(app.buttons["Copy"]).tap()

        let alertQuery = waitForElementToAppear(app.alerts["Copy program"])
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your program name here..."].typeText(newName)
        XCTAssert(alertQuery.buttons["OK"].exists)
        alertQuery.buttons["OK"].tap()
    }
}
