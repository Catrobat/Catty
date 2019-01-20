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

class PocketCodeMainScreenTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testContinue() {
        restoreDefaultProject()

        let app = XCUIApplication()
        app.tables.staticTexts["Continue"].tap()

        XCTAssert(app.navigationBars["My first project"].exists)
    }

    func testNew() {
        let app = XCUIApplication()

        app.tables.staticTexts["New"].tap()
        app.textFields["Enter your project name here..."].tap()
        app.textFields["Enter your project name here..."].typeText("testProject")
        app.alerts["New Project"].buttons["OK"].tap()

        // check if worked to create new Project
        //XCTAssert(app.navigationBars["testProject"].exists)

        // go back and try to add project with same name
        app.navigationBars["testProject"].buttons["Pocket Code"].tap()

        app.tables.staticTexts["New"].tap()
        app.textFields["Enter your project name here..."].tap()
        app.textFields["Enter your project name here..."].typeText("testProject")
        app.alerts["New Project"].buttons["OK"].tap()

        // check if error message is displayed
        XCTAssert(waitForElementToAppear(app.alerts["Pocket Code"]).staticTexts["A project with the same name already exists, try again."].exists)
        app.alerts["Pocket Code"].buttons["OK"].tap()
        app.alerts["New Project"].buttons["Cancel"].tap()

        // check if gone back to initial screen after pressing cancel button
        XCTAssert(app.tables.staticTexts["New"].exists)
    }

    func testNewInvalidNames() {
        let progNamesErrorMsgMap = ["": "No input. Please enter at least 1 character.",
                                    "i am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am "
                                        + "tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo "
                                        + "looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooog": "The input is too long. Please enter maximal 250 character(s).",
                                    ".": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "/": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "./": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "\\": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~/": "Only special characters are not allowed. Please enter at least 1 other character."]

        let app = XCUIApplication()

        for (projectName, _) in progNamesErrorMsgMap {
            app.tables.staticTexts["New"].tap()
            let alertQuery = app.alerts["New Project"]
            alertQuery.textFields["Enter your project name here..."].tap()
            alertQuery.textFields["Enter your project name here..."].typeText(projectName)
            alertQuery.buttons["OK"].tap()

            let alert = waitForElementToAppear(app.alerts["Pocket Code"])
            XCTAssert(alert.exists)
            alert.buttons["OK"].tap()

            alertQuery.buttons["Cancel"].tap()
        }
    }

    func testNewCanceled() {
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()

        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText("testprojectToCancel")
        alertQuery.buttons["Cancel"].tap()

        XCTAssertTrue(app.navigationBars["Pocket Code"].exists)
    }

    func testProjects() {
        let projectNames = ["testProject1", "testProject2", "testProject3"]

        let app = XCUIApplication()
        app.tables.staticTexts["Projects"].tap()

        XCTAssert(app.navigationBars["Projects"].exists)

        app.navigationBars["Projects"].buttons["Pocket Code"].tap()

        let tablesQuery = app.tables
        let newStaticText = tablesQuery.staticTexts["New"]
        let alertQuery = app.alerts["New Project"]
        let enterYourProjectNameHereTextField = alertQuery.textFields["Enter your project name here..."]
        let okButton = alertQuery.buttons["OK"]

        for i in 0...2 {
            newStaticText.tap()
            enterYourProjectNameHereTextField.typeText(projectNames[i])
            okButton.tap()
            app.navigationBars[projectNames[i]].buttons["Pocket Code"].tap()
        }

        tablesQuery.staticTexts["Projects"].tap()

        for projectName in projectNames {
            XCTAssert(app.tables.staticTexts[projectName].exists)
        }
    }

    func testHelp() {
        let app = XCUIApplication()
        app.tables.staticTexts["Help"].tap()

        XCTAssert(app.navigationBars["Help"].exists)
    }

    func testExplore() {
        let app = XCUIApplication()
        app.tables.staticTexts["Explore"].tap()

        XCTAssert(app.navigationBars["Explore"].exists)
    }

    func testUploadRedirectToLogin() {
        let app = XCUIApplication()

        app.navigationBars.buttons["Item"].tap()
        if app.tables.staticTexts["Logout"].exists {
            app.tables.staticTexts["Logout"].tap()
        } else {
            app.navigationBars.buttons["Pocket Code"].tap()
        }

        app.tables.staticTexts["Upload"].tap()
        XCTAssert(app.navigationBars["Login"].exists)
    }

    func testDebugMode() {
        let app = XCUIApplication()
        app.navigationBars.buttons["Debug mode"].tap()

        let alertQuery = app.alerts["Debug mode"]
        alertQuery.buttons["OK"].tap()

        XCTAssert(app.navigationBars["Pocket Code"].exists)
    }

    func testSettings() {
        let app = XCUIApplication()
        app.navigationBars.buttons["Item"].tap()

        app.switches["Use Arduino bricks"].tap()
        app.navigationBars.buttons["Pocket Code"].tap()
        app.tables.staticTexts["Projects"].tap()
        app.tables.staticTexts["My first project"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["Set Arduino digital pin "].exists)
        app.navigationBars.buttons["Cancel"].tap()
        app.navigationBars.buttons["Mole 1"].tap()
        app.navigationBars.buttons["My first project"].tap()
        app.navigationBars.buttons["Projects"].tap()
        app.navigationBars.buttons["Pocket Code"].tap()
        app.navigationBars.buttons["Item"].tap()
        app.switches["Use Arduino bricks"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)

        app.staticTexts["About Pocket Code"].tap()
        XCTAssert(app.navigationBars["About Pocket Code"].exists)
        app.navigationBars.buttons["Settings"].tap()

        app.staticTexts["Terms of Use and Services"].tap()
        XCTAssert(app.navigationBars["Terms of Use and Services"].exists)
        app.navigationBars.buttons["Settings"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
    }
}
