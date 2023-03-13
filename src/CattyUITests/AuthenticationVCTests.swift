/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class AuthenticationVCTests: XCTestCase {

    let testUsername = "testUsername"
    let testEmail = "test@user.com"
    let testPassword = "testPassword"

    func testLogin() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut"])
        app.tables.staticTexts[kLocalizedUploadProject].tap()
        XCTAssert(app.navigationBars[kLocalizedLogin].exists)

        app.buttons[kLocalizedLogin].tap()
        XCTAssert(app.staticTexts[kLocalizedLoginUsernameNecessary].exists)

        app.alerts.firstMatch.tap()
        app.textFields[kLocalizedUsername].tap()
        app.textFields[kLocalizedUsername].typeText(testUsername)
        app.images.firstMatch.tap()
        app.buttons[kLocalizedLogin].tap()
        XCTAssert(app.staticTexts[kLocalizedLoginPasswordNotValid].exists)
    }

    func testRegister() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut"])
        app.tables.staticTexts[kLocalizedUploadProject].tap()
        XCTAssert(app.navigationBars[kLocalizedLogin].exists)

        app.buttons[kLocalizedRegister].tap()
        XCTAssert(app.navigationBars[kLocalizedRegister].exists)

        app.buttons[kLocalizedDone].tap()
        XCTAssert(app.staticTexts[kLocalizedLoginUsernameNecessary].exists)

        app.alerts.firstMatch.tap()
        app.textFields[kLocalizedUsername].tap()
        app.textFields[kLocalizedUsername].typeText(testUsername)
        app.images.firstMatch.tap()
        app.buttons[kLocalizedDone].tap()
        XCTAssert(app.staticTexts[kLocalizedLoginEmailNotValid].exists)

        app.alerts.firstMatch.tap()
        app.textFields[kLocalizedEmail].tap()
        app.textFields[kLocalizedEmail].typeText(testEmail)
        app.images.firstMatch.tap()
        app.buttons[kLocalizedDone].tap()
        XCTAssert(app.staticTexts[kLocalizedLoginPasswordNotValid].exists)

        app.alerts.firstMatch.tap()
        app.secureTextFields[kLocalizedPassword].tap()
        app.secureTextFields[kLocalizedPassword].typeText(testPassword)
        app.images.firstMatch.tap()
        app.buttons[kLocalizedDone].tap()
        XCTAssert(app.staticTexts[kLocalizedRegisterPasswordConfirmationNoMatch].exists)
    }

    func testTextFieldResponder() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut"])
        app.tables.staticTexts[kLocalizedUploadProject].tap()
        XCTAssert(app.navigationBars[kLocalizedLogin].exists)

        app.textFields[kLocalizedUsername].tap()
        app.textFields[kLocalizedUsername].typeText("\n")
        app.secureTextFields[kLocalizedPassword].typeText("\n")
        XCTAssert(app.staticTexts[kLocalizedLoginUsernameNecessary].exists)

        app.alerts.firstMatch.tap()
        app.buttons[kLocalizedRegister].tap()
        XCTAssert(app.navigationBars[kLocalizedRegister].exists)

        app.textFields[kLocalizedUsername].tap()
        app.textFields[kLocalizedUsername].typeText("\n")
        app.textFields[kLocalizedEmail].typeText("\n")
        app.secureTextFields[kLocalizedPassword].typeText("\n")
        app.secureTextFields[kLocalizedConfirmPassword].typeText("\n")
        XCTAssert(app.staticTexts[kLocalizedLoginUsernameNecessary].exists)
    }

    func testUsernamePropagation() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["setUserLoggedOut", "-username", testUsername])
        app.tables.staticTexts[kLocalizedUploadProject].tap()
        XCTAssert(app.navigationBars[kLocalizedLogin].exists)
        XCTAssert(app.textFields[testUsername].exists)

        app.buttons[kLocalizedRegister].tap()
        XCTAssert(app.textFields[testUsername].exists)
    }
}
