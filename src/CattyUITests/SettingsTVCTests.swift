/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class SettingsTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testSettings() {
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
        app.switches[kLocalizedArduinoBricks].tap()
        app.switches[kLocalizedSendCrashReports].tap()

        app.staticTexts[kLocalizedAboutPocketCode].tap()
        XCTAssert(app.navigationBars[kLocalizedAboutPocketCode].exists)
        app.navigationBars.buttons[kLocalizedSettings].tap()

        app.staticTexts[kLocalizedTermsOfUse].tap()
        XCTAssert(app.navigationBars[kLocalizedTermsOfUse].exists)
        app.navigationBars.buttons[kLocalizedSettings].tap()
        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
    }

    func testArduinoSettings() {
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        if app.switches[kLocalizedArduinoBricks].value as! String == "0" {
            app.switches[kLocalizedArduinoBricks].tap()
        }

        app.navigationBars.buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        findBrickSection(kLocalizedCategoryArduino, in: app)

        XCTAssertTrue(app.navigationBars[kLocalizedCategoryArduino].exists)
    }
}
