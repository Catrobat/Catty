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

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        app = XCUIApplication()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testContinue() {
        app.tables.staticTexts[kLocalizedContinue].tap()

        XCTAssert(app.navigationBars[kLocalizedMyFirstProject].exists)
    }

    func testNew() {
        let testProject = "testProject"

        app.tables.staticTexts[kLocalizedNew].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()

        // go back and try to add project with same name
        app.navigationBars[testProject].buttons[kLocalizedPocketCode].tap()

        app.tables.staticTexts[kLocalizedNew].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].tap()
        app.textFields[kLocalizedEnterYourProjectNameHere].typeText(testProject)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()

        // check if error message is displayed
        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).staticTexts[kLocalizedProjectNameAlreadyExistsDescription].exists)
        app.alerts[kLocalizedPocketCode].buttons[kLocalizedOK].tap()
        app.alerts[kLocalizedNewProject].buttons[kLocalizedCancel].tap()

        // check if gone back to initial screen after pressing cancel button
        XCTAssert(app.tables.staticTexts[kLocalizedNew].exists)
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

        for (projectName, _) in progNamesErrorMsgMap {
            app.tables.staticTexts[kLocalizedNew].tap()
            let alertQuery = app.alerts[kLocalizedNewProject]
            alertQuery.textFields[kLocalizedEnterYourProjectNameHere].tap()
            alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
            alertQuery.buttons[kLocalizedOK].tap()

            let alert = waitForElementToAppear(app.alerts[kLocalizedPocketCode])
            XCTAssert(alert.exists)
            alert.buttons[kLocalizedOK].tap()

            alertQuery.buttons[kLocalizedCancel].tap()
        }
    }

    func testNewCanceled() {
        app.tables.staticTexts[kLocalizedNew].tap()

        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText("testprojectToCancel")
        alertQuery.buttons[kLocalizedCancel].tap()

        XCTAssertTrue(app.navigationBars[kLocalizedPocketCode].exists)
    }

    func testProjects() {
        let projectNames = ["testProject1", "testProject2", "testProject3"]

        app.tables.staticTexts[kLocalizedProjects].tap()

        XCTAssert(app.navigationBars[kLocalizedProjects].exists)

        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()

        let tablesQuery = app.tables
        let newStaticText = tablesQuery.staticTexts[kLocalizedNew]
        let alertQuery = app.alerts[kLocalizedNewProject]
        let enterYourProjectNameHereTextField = alertQuery.textFields[kLocalizedEnterYourProjectNameHere]
        let okButton = alertQuery.buttons[kLocalizedOK]

        for i in 0...2 {
            newStaticText.tap()
            enterYourProjectNameHereTextField.typeText(projectNames[i])
            okButton.tap()
            app.navigationBars[projectNames[i]].buttons[kLocalizedPocketCode].tap()
        }

        tablesQuery.staticTexts[kLocalizedProjects].tap()

        for projectName in projectNames {
            XCTAssert(app.tables.staticTexts[projectName].exists)
        }
    }

    func testHelp() {
        app.tables.staticTexts[kLocalizedHelp].tap()

        XCTAssert(app.navigationBars[kLocalizedHelp].exists)
    }

    func testExplore() {
        app.tables.staticTexts[kLocalizedExplore].tap()

        XCTAssert(app.navigationBars[kLocalizedExplore].exists)
    }

    func testUploadRedirectToLogin() {
        app.navigationBars.buttons["Item"].tap()

        if app.tables.staticTexts[kLocalizedLogout].exists {
            app.tables.staticTexts[kLocalizedLogout].tap()
        } else {
            app.navigationBars.buttons[kLocalizedPocketCode].tap()
        }

        app.tables.staticTexts[kLocalizedUpload].tap()
        XCTAssert(app.navigationBars[kLocalizedLogin].exists)
    }

    func testDebugMode() {
        app.navigationBars.buttons[kLocalizedDebugModeTitle].tap()

        let alertQuery = app.alerts[kLocalizedDebugModeTitle]
        alertQuery.buttons[kLocalizedOK].tap()

        XCTAssert(app.navigationBars[kLocalizedPocketCode].exists)
    }

    func testSettings() {
        app.navigationBars.buttons["Item"].tap()

        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
        app.switches[kLocalizedArduinoBricks].tap()

        app.staticTexts[kLocalizedAboutPocketCode].tap()
        XCTAssert(app.navigationBars[kLocalizedAboutPocketCode].exists)
        app.navigationBars.buttons[kLocalizedSettings].tap()

        app.staticTexts[kLocalizedTermsOfUse].tap()
        XCTAssert(app.navigationBars[kLocalizedTermsOfUse].exists)
        app.navigationBars.buttons[kLocalizedSettings].tap()
        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
    }

    func testArduinoSettings() {
        app.navigationBars.buttons["Item"].tap()

        if app.switches[kLocalizedArduinoBricks].value as! String == "0" {
            app.switches[kLocalizedArduinoBricks].tap()
        }

        app.navigationBars.buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjects].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        findBrickSection(kUIArduinoTitle, in: app)

        XCTAssertTrue(app.navigationBars[kUIArduinoTitle].exists)
    }
}
