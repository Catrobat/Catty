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

class LooksTVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testLengthOfLook() {
        let app = XCUIApplication()
        let appTables = app.tables
        let lookName = String(repeating: "a", count: 250)

        appTables.staticTexts[kLocalizedContinue].tap()
        appTables.staticTexts["Mole 1"].tap()
        appTables.staticTexts[kLocalizedLooks].tap()

        appTables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedRenameImage])
        alert.buttons["Clear text"].tap()

        let textField = alert.textFields[kLocalizedEnterYourImageNameHere]
        textField.typeText(lookName)
        alert.buttons[kLocalizedOK].tap()

        XCTAssertTrue(app.toolbars.buttons[kLocalizedUserListAdd].exists)

        appTables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        alert.buttons["Clear text"].tap()
        textField.typeText(lookName + "b")
        alert.buttons[kLocalizedOK].tap()
    }

    func testLooksCanEnterLooksOfAllMoles() {
        let app = XCUIApplication()
        let appTables = app.tables

        let testElement = kLocalizedLooks

        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        appTables.staticTexts[kLocalizedContinue].tap()

        for object in projectObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].buttons[object].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons[kLocalizedMyFirstProject].tap()

            let projectVC = waitForElementToAppear(app.navigationBars[kLocalizedMyFirstProject])
            XCTAssert(projectVC.buttons[kLocalizedPocketCode].exists)
        }
    }
}
