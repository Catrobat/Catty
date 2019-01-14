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

class ProjectsTVCTests: XCTestCase, UITestProtocol {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()

        app = XCUIApplication()
    }

    func testCanAddNewProject() {
        app.tables.staticTexts["Projects"].tap()
        app.toolbars.buttons["Add"].tap()

        let alertQuery = waitForElementToAppear(app.alerts["New Project"])
        alertQuery.textFields["Enter your project name here..."].typeText("testProject")

        app.alerts["New Project"].buttons["OK"].tap()

        XCTAssert(waitForElementToAppear(app.navigationBars["testProject"]).exists)

        app.navigationBars.buttons["Projects"].tap()

        XCTAssert(app.tables.staticTexts["testProject"].exists)
    }

    func testCanCancelAddNewProject() {
        app.tables.staticTexts["Projects"].tap()
        app.toolbars.buttons["Add"].tap()

        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText("testProject")

        app.alerts["New Project"].buttons["Cancel"].tap()

        XCTAssert(app.navigationBars["Projects"].exists)
    }

    func testCanCancelEdit() {
        app.tables.staticTexts["Projects"].tap()
        app.navigationBars["Projects"].buttons["Edit"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(app.navigationBars["Projects"].exists)
    }

    func testCanCancelMoreActionSheetMenu() {
        app.tables.staticTexts["Projects"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first project"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(!app.buttons["Cancel"].exists)
    }

    func testCanCopyMyFirstProject() {
        app.tables.staticTexts["Projects"].tap()

        copyProject(name: "My first project", newName: "My second project")

        XCTAssert(app.tables.cells.count == 2)
        XCTAssert(app.tables.staticTexts["My second project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Projects"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Projects"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Projects"]).exists)

        XCTAssert(app.tables.cells.count == 2)
        XCTAssert(app.tables.staticTexts["My second project"].exists)
    }

    func testCanCancelCopyMyFirstProject() {
        app.tables.staticTexts["Projects"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first project"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Copy"].exists)
        app.buttons["Copy"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Copy project"]).exists)
        let alertQuery = app.alerts["Copy project"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your project name here..."].typeText("My second project")
        XCTAssert(alertQuery.buttons["Cancel"].exists)
        alertQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My first project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Projects"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Projects"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Projects"]).exists)

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My first project"].exists)
    }

    func testCanRenameMyFirstProject() {
        app.tables.staticTexts["Projects"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first project"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Rename Project"]).exists)
        let alertQuery = app.alerts["Rename Project"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your project name here..."].typeText("My renamed project")
        XCTAssert(alertQuery.buttons["OK"].exists)
        alertQuery.buttons["OK"].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Projects"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Projects"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Projects"]).exists)

        // check again
        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed project"].exists)
    }

    func testCanCancelRenameMyFirstProject() {
        app.tables.staticTexts["Projects"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first project"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(waitForElementToAppear(app.alerts["Rename Project"]).exists)
        let alertQuery = app.alerts["Rename Project"]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your project name here..."].typeText("My renamed project")
        XCTAssert(alertQuery.buttons["Cancel"].exists)
        alertQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My first project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Projects"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Projects"].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["Projects"]).exists)

        // check again
        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My first project"].exists)
    }

    func testBulkDeleteProjects() {
        let copyProjectName = "My first project"
        app.tables.staticTexts["Projects"].tap()
        waitForElementToAppear(app.navigationBars["Projects"]).buttons["Edit"].tap()

        if !app.buttons["Hide Details"].exists {
            app.buttons["Show Details"].tap()
        } else {
            app.buttons["Cancel"].tap()
        }

        for num in 1..<8 {
            copyProject(name: copyProjectName, newName: copyProjectName + String(num))
        }

        waitForElementToAppear(app.navigationBars["Projects"]).buttons["Edit"].tap()
        waitForElementToAppear(app.buttons["Delete Projects"]).tap()
        waitForElementToAppear(app.buttons["Select All"]).tap()
        waitForElementToAppear(app.buttons["Delete"]).tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars["Projects"]).exists)
        XCTAssert(app.tables.cells.count == 1)
    }

    private func copyProject(name: String, newName: String) {
        let tablesQuery = app.tables
        tablesQuery.staticTexts[name].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        waitForElementToAppear(app.buttons["Copy"]).tap()

        let alertQuery = waitForElementToAppear(app.alerts["Copy project"])
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your project name here..."].typeText(newName)
        XCTAssert(alertQuery.buttons["OK"].exists)
        alertQuery.buttons["OK"].tap()
    }
}
