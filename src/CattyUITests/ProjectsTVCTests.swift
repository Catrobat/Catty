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

class ProjectsTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
    }

    func testCanAddNewProject() {
        let testProject = "testProject"

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        let alertQuery = waitForElementToAppear(app.alerts[kLocalizedNewProject])
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)

        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[testProject]).exists)

        app.navigationBars.buttons[kLocalizedProjects].tap()
        XCTAssert(app.tables.staticTexts[testProject].exists)
    }

    func testCanCancelAddNewProject() {
        let testProject = "testProject"

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)

        app.alerts[kLocalizedNewProject].buttons[kLocalizedCancel].tap()
        XCTAssertFalse(app.tables.staticTexts[testProject].exists)
        XCTAssert(app.navigationBars[kLocalizedProjects].exists)
    }

    func testCanCancelEdit() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedEdit].tap()
        XCTAssert(app.buttons[kLocalizedCancel].exists)
        app.buttons[kLocalizedCancel].tap()
        XCTAssert(app.navigationBars[kLocalizedProjects].exists)
    }

    func testCanCancelMoreActionSheetMenu() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].swipeLeft()
        XCTAssert(app.buttons[kLocalizedMore].exists)

        app.buttons[kLocalizedMore].tap()
        XCTAssert(app.buttons[kLocalizedCancel].exists)
        app.buttons[kLocalizedCancel].tap()
        XCTAssert(!app.buttons[kLocalizedCancel].exists)
    }

    func testCanCopyMyFirstProject() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        copyProject(name: kLocalizedMyFirstProject, newName: "My second project")

        XCTAssert(app.tables.cells.count == 2)
        XCTAssert(app.tables.staticTexts["My second project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedProjects]).exists)

        XCTAssert(app.tables.cells.count == 2)
        XCTAssert(app.tables.staticTexts["My second project"].exists)
    }

    func testCanCancelCopyMyFirstProject() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].swipeLeft()
        XCTAssert(app.buttons[kLocalizedMore].exists)

        app.buttons[kLocalizedMore].tap()
        XCTAssert(app.buttons[kLocalizedCopy].exists)
        app.buttons[kLocalizedCopy].tap()

        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedCopyProject]).exists)
        let alertQuery = app.alerts[kLocalizedCopyProject]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText("My second project")
        XCTAssert(alertQuery.buttons[kLocalizedCancel].exists)
        alertQuery.buttons[kLocalizedCancel].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts[kLocalizedMyFirstProject].exists)

        // go back and forth to force reload table view!!
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedProjects]).exists)

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts[kLocalizedMyFirstProject].exists)
    }

    func testCanRenameMyFirstProject() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].swipeLeft()
        XCTAssert(app.buttons[kLocalizedMore].exists)

        app.buttons[kLocalizedMore].tap()
        XCTAssert(app.buttons[kLocalizedRename].exists)
        app.buttons[kLocalizedRename].tap()

        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedRenameProject]).exists)
        let alertQuery = app.alerts[kLocalizedRenameProject]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText("My renamed project")
        XCTAssert(alertQuery.buttons[kLocalizedOK].exists)
        alertQuery.buttons[kLocalizedOK].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed project"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedProjects]).exists)

        // check again
        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed project"].exists)
    }

    func testCanCancelRenameMyFirstProject() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].swipeLeft()
        XCTAssert(app.buttons[kLocalizedMore].exists)

        app.buttons[kLocalizedMore].tap()
        XCTAssert(app.buttons[kLocalizedRename].exists)
        app.buttons[kLocalizedRename].tap()

        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedRenameProject]).exists)
        let alertQuery = app.alerts[kLocalizedRenameProject]
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText("My renamed project")
        XCTAssert(alertQuery.buttons[kLocalizedCancel].exists)
        alertQuery.buttons[kLocalizedCancel].tap()

        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts[kLocalizedMyFirstProject].exists)

        // go back and forth to force reload table view!!
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedProjects]).exists)

        // check again
        XCTAssert(app.tables.cells.count == 1)
        XCTAssert(app.tables.staticTexts[kLocalizedMyFirstProject].exists)
    }

    func testBulkDeleteProjects() {
        let copyProjectName = kLocalizedMyFirstProject
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        waitForElementToAppear(app.navigationBars[kLocalizedProjects]).buttons[kLocalizedEdit].tap()

        if !app.buttons[kLocalizedHideDetails].exists {
            app.buttons[kLocalizedShowDetails].tap()
        } else {
            app.buttons[kLocalizedCancel].tap()
        }

        for num in 1..<8 {
            copyProject(name: copyProjectName, newName: copyProjectName + String(num))
        }

        waitForElementToAppear(app.navigationBars[kLocalizedProjects]).buttons[kLocalizedEdit].tap()
        waitForElementToAppear(app.buttons[kLocalizedDeleteProjects]).tap()
        waitForElementToAppear(app.buttons[kLocalizedSelectAllItems]).tap()
        waitForElementToAppear(app.buttons[kLocalizedDelete]).tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedProjects]).exists)
        XCTAssert(app.tables.cells.count == 1)
    }

    private func copyProject(name: String, newName: String) {
        let tablesQuery = app.tables
        tablesQuery.staticTexts[name].swipeLeft()
        XCTAssert(app.buttons[kLocalizedMore].exists)

        app.buttons[kLocalizedMore].tap()
        waitForElementToAppear(app.buttons[kLocalizedCopy]).tap()

        let alertQuery = waitForElementToAppear(app.alerts[kLocalizedCopyProject])
        XCTAssert(alertQuery.buttons["Clear text"].exists)
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(newName)
        XCTAssert(alertQuery.buttons[kLocalizedOK].exists)
        alertQuery.buttons[kLocalizedOK].tap()
    }
}
