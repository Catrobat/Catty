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

class SceneTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
    }

    func testCopySelectedObjects() {
        app = launchApp()
        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.navigationBars["\(kLocalizedScene) 1"].buttons[kLocalizedEdit].tap()
        waitForElementToAppear(app.buttons[kLocalizedCopyObjects]).tap()
        app.buttons[kLocalizedSelectAllItems].tap()
        app.buttons[kLocalizedCopy].tap()
        XCTAssert(waitForElementToAppear(app.navigationBars["\(kLocalizedScene) 1"]).exists)
        for object in projectObjects {
            XCTAssert(app.tables.staticTexts[object + " (1)"].exists)
        }
    }

    func testUploadProject() {
        app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedIn"])
        tapOnUpload()
        XCTAssert(waitForElementToAppear(app.navigationBars.buttons[kLocalizedUploadProject]).exists)
    }

    func testUploadProjectRedirectLogin() {
        app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut"])
        tapOnUpload()
        XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedLogin]).exists)
    }

    func tapOnUpload() {
        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.navigationBars["\(kLocalizedScene) 1"].buttons[kLocalizedEdit].tap()
        waitForElementToAppear(app.buttons[kLocalizedUploadProject]).tap()
    }
}
