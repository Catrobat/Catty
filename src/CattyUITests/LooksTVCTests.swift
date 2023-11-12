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

class LooksTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testLengthOfLook() {
        let lookName = String(repeating: "a", count: 25)

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedLooks].tap()

        app.tables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedRenameImage])
        alert.buttons["Clear text"].tap()

        let textField = alert.textFields[kLocalizedEnterYourImageNameHere]
        textField.typeText(lookName)
        alert.buttons[kLocalizedOK].tap()

        XCTAssertTrue(app.toolbars.buttons[kLocalizedUserListAdd].exists)

        app.tables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        alert.buttons["Clear text"].tap()
        textField.typeText(lookName + "b")

        alert.buttons[kLocalizedOK].tap()
        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).exists)
    }

    func testLooksCanEnterLooksOfAllMoles() {
        let testElement = kLocalizedLooks

        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        app.tables.staticTexts[kLocalizedContinueProject].tap()

        for object in projectObjects {
            app.staticTexts["\(kLocalizedScene) 1"].tap()
            waitForElementToAppear(app.tables.staticTexts[object]).tap()
            app.tables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].buttons[object].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["\(kLocalizedScene) 1"].tap()

            let projectVC = waitForElementToAppear(app.navigationBars["\(kLocalizedScene) 1"])
            XCTAssert(waitForElementToAppear(projectVC.buttons[kLocalizedMyFirstProject]).exists)
        }
    }
    func testCancelEnterNameDialog() {
        let testElement = kLocalizedLooks
        let testObject = "Mole 1"
        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[testObject].tap()
        app.tables.staticTexts[testElement].tap()
        app.buttons[kLocalizedAdd].tap()
        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        app.tap()
        app.navigationBars.buttons[kLocalizedBack].tap()

        waitForElementToAppear(app.buttons[kLocalizedSaveChanges]).tap()
        waitForElementToAppear(app.alerts[kLocalizedAddImage]).buttons[kLocalizedCancel].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars.buttons[testObject]))
    }

    func testPaintBackButton() {
        let testElement = kLocalizedLooks
        let testObject = "Mole 1"
        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[testObject].tap()
        app.tables.staticTexts[testElement].tap()
        app.buttons[kLocalizedAdd].tap()
        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))
        app.navigationBars.buttons[kLocalizedBack].tap()
        XCTAssertFalse(app.buttons[kLocalizedSaveChanges].exists)

        app.buttons[kLocalizedAdd].tap()
        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))
        app.tap()
        app.navigationBars.buttons[kLocalizedBack].tap()
        XCTAssertTrue(app.buttons[kLocalizedSaveChanges].exists)
    }
}
