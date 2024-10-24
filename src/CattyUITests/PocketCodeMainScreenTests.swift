/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class PocketCodeMainScreenTests: XCTestCase {

    public static let settingsButtonLabel = "Settings"
    public static let accountButtonLabel = "Account"

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
    }

    func testContinue() {
        app = launchApp()
        app.tables.staticTexts[kLocalizedContinueProject].tap()

        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedMyFirstProject]).exists)
    }

    func testNew() {
        app = launchApp()
        let testProject = "testProject"

        app.tables.staticTexts[kLocalizedNewProject].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedNewProject].tap()

        // go back and try to add project with same name
        app.navigationBars[testProject].buttons[kLocalizedPocketCode].tap()

        app.tables.staticTexts[kLocalizedNewProject].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedNewProject].tap()

        // check if error message is displayed
        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).staticTexts[kLocalizedProjectNameAlreadyExistsDescription].exists)
        app.alerts[kLocalizedPocketCode].buttons[kLocalizedOK].tap()
        app.alerts[kLocalizedNewProject].buttons[kLocalizedCancel].tap()

        // check if gone back to initial screen after pressing cancel button
        XCTAssert(app.tables.staticTexts[kLocalizedNewProject].exists)
    }

    func testNewInvalidNames() {
        app = launchApp()
        let progNamesErrorMsgMap = ["": "No input. Please enter at least 1 character.",
                                    String(repeating: "i", count: 25 + 1): "The input is too long. Please enter maximal 25 character(s).",
                                    ".": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "/": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "./": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "\\": "Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~/": "Only special characters are not allowed. Please enter at least 1 other character."]

        for (projectName, _) in progNamesErrorMsgMap {
            app.tables.staticTexts[kLocalizedNewProject].tap()
            let alertQuery = waitForElementToAppear(app.alerts[kLocalizedNewProject])
            waitForElementToAppear(alertQuery.textFields[kLocalizedEnterYourProjectNameHere]).tap()
            waitForElementToAppear(alertQuery.textFields[kLocalizedEnterYourProjectNameHere]).typeText(projectName)
            waitForElementToAppear(alertQuery.buttons[kLocalizedNewProject]).tap()

            let alert = waitForElementToAppear(app.alerts[kLocalizedPocketCode])
            XCTAssert(alert.exists)

            alert.buttons[kLocalizedOK].tap()
            alertQuery.buttons[kLocalizedCancel].tap()
        }
    }

    func testNewCanceled() {
        app = launchApp()
        app.tables.staticTexts[kLocalizedNewProject].tap()

        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText("testprojectToCancel")
        alertQuery.buttons[kLocalizedCancel].tap()

        XCTAssertTrue(app.navigationBars[kLocalizedPocketCode].exists)
    }

    func testProjects() {
        app = launchApp()
        let projectNames = ["testProject1", "testProject2"]

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        XCTAssert(app.navigationBars[kLocalizedProjects].exists)

        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()

        let tablesQuery = app.tables
        let newStaticText = tablesQuery.staticTexts[kLocalizedNewProject]
        let alertQuery = app.alerts[kLocalizedNewProject]
        let enterYourProjectNameHereTextField = alertQuery.textFields[kLocalizedEnterYourProjectNameHere]
        let projectButton = alertQuery.buttons[kLocalizedNewProject]

        for projectName in projectNames {
            newStaticText.tap()
            enterYourProjectNameHereTextField.typeText(projectName)
            projectButton.tap()
            app.navigationBars[projectName].buttons[kLocalizedPocketCode].tap()
        }

        tablesQuery.staticTexts[kLocalizedProjectsOnDevice].tap()

        for projectName in projectNames {
            XCTAssert(app.tables.staticTexts[projectName].exists)
        }
    }

    func testHelp() {
        app = launchApp()
        app.tables.staticTexts[kLocalizedHelp].tap()

        XCTAssert(app.navigationBars[kLocalizedHelp].exists)
    }

    func testExplore() {
        app = launchApp()
        app.tables.staticTexts[kLocalizedCatrobatCommunity].tap()

        XCTAssert(app.navigationBars[kLocalizedCatrobatCommunity].exists)
    }

    func testUpload() {
        app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedIn"])
        app.tables.staticTexts[kLocalizedUploadProject].tap()

        XCTAssert(waitForElementToAppear(app.navigationBars.buttons[kLocalizedUploadProject]).exists)
    }

    func testUploadRedirectToLogin() {
        app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut"])
        app.tables.staticTexts[kLocalizedUploadProject].tap()

        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedLogin]).exists)
    }

    func testAccountMenu() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedIn"])
        app.navigationBars.buttons[PocketCodeMainScreenTests.accountButtonLabel].tap()
        XCTAssert(app.staticTexts["testUsername"].exists)
        XCTAssert(app.buttons[kLocalizedLogout].exists)

        app.buttons[kLocalizedLogout].tap()
        XCTAssertFalse(app.staticTexts["testUsername"].exists)
        XCTAssertFalse(app.buttons[kLocalizedLogout].exists)

        app.navigationBars.buttons[PocketCodeMainScreenTests.accountButtonLabel].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedLogin]).exists)
    }
}
