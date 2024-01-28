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

class TrustedDomainTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp(with: XCTestCase.defaultLaunchArguments + ["-useWebRequestBrick", "true"])
    }

    func testAddAndDeleteTrustedDomain() {
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        XCTAssert(app.staticTexts[kLocalizedWebAccess].exists)
        app.staticTexts[kLocalizedTrustedDomains].tap()
        XCTAssertTrue(waitForElementToAppear(app.navigationBars[kLocalizedWebAccess]).exists)

        let url = "https://www.test.com"
        let numberOfTrustedDomains = app.tables.cells.count

        XCTAssertFalse(app.staticTexts[url].exists)
        XCTAssertTrue(app.navigationBars.buttons[kLocalizedAdd].exists)
        app.navigationBars.buttons[kLocalizedAdd].tap()

        app.textFields.element.typeText(url)
        XCTAssertTrue(app.alerts.element.buttons[kLocalizedAdd].exists)
        app.alerts.element.buttons[kLocalizedAdd].tap()

        XCTAssertTrue(app.staticTexts[url].exists)
        XCTAssertEqual(app.tables.cells.count, numberOfTrustedDomains + 1)

        app.staticTexts[url].swipeLeft()

        XCTAssertTrue(app.buttons[kLocalizedDelete].exists)
        app.buttons[kLocalizedDelete].tap()

        XCTAssertEqual(app.tables.cells.count, numberOfTrustedDomains)
    }
}
